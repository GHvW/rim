# typed: true
require_relative "list"
# require "sorbet-runtime"

class BinomialTree
    # extend T::Sig
    include Comparable

    attr_reader :data, :rank, :tree_list

    # (A, Int, LinkedList) -> BinomialTree
    def initialize(data, rank, tree_list = List.new)
        @data = data # must have <=> defined
        @rank = rank
        @tree_list = tree_list
    end

    # BinomialTree(self) -> BinomialTree -> Bool
    # sig { params(other: BinomialTree)}
    def <=>(other)
        @data <=> other.data
    end

    # BinomialTree(self) -> BinomialTree -> BinomialTree
    # sig { params(other: BinomialTree).returns(BinomialTree) }
    def link(other)
        if self <= other # min heap? Elem.leq?
            return BinomialTree.new(@data, @rank + 1, @tree_list.cons(other))
        end

        BinomialTree.new(other.data, other.rank + 1, other.tree_list.cons(self))
    end

    def inspect()
        { :data => @data, :rank => @rank, :tree_list => @tree_list }.inspect()
    end
end


class BinomialHeap

    # (BinomialTree, List BinomialTree) -> List BinomialTree
    @@insert_node = ->(tree, tree_list) {
        if tree_list.empty?
            return List.new.cons(tree)
        end

        x_xs = tree_list.x_xs()
        x = x_xs[:x]
        xs = x_xs[:xs]

        if tree.rank < x.rank
            return tree_list.cons(tree)
        end

        @@insert_node.(tree.link(x), xs)
    }

    # (BinomialTree, Binomialtree) -> BinomialTree
    @@meld_trees = ->(bh1, bh2) {
        if bh1.empty?
            return bh2
        end

        if bh2.empty?
            return bh1
        end

        bh1_x_xs = bh1.x_xs()
        x1 = bh1_x_xs[:x]
        xs1 = bh1_x_xs[:xs]

        bh2_x_xs = bh2.x_xs()
        x2 = bh2_x_xs[:x]
        xs2 = bh2_x_xs[:xs]

        if x1.rank < x2.rank
            return @@meld_trees.(xs1, bh2).cons(x1)
        elseif x2.rank < x1.rank
            return @@meld_trees.(bh1, xs2).cons(x2)
        end 

        @insert_node.(x1.link(x2), @@meld_trees.(xs1, xs2))
    }

    attr_reader :trees

    # List BinomialTree -> BinomialHeap
    def initialize(trees = List.new)
        @trees = trees
    end

    def empty?
        @trees.nil?
    end

    # BinomialHeap(self) -> BinomialHeap
    def insert(data)
        BinomialHeap.new(@@insert_node.(BinomialTree.new(data, 0), @trees))
    end

    # BinomialHeap(self) -> A
    def find_min()
        @trees.min()&.data
    end

    # binomialheap(self) -> {a, binomialheap}
    def pop_min()
        min_node = @trees.min()

        { 
            :item => min_node.data, 
            :remaining => Binomialheap.new(
                @@meld_trees.(
                    @trees.filter { |tree| tree != min_node }, 
                    min_node.tree_list.reverse())) 
        }
    end

    # binomialheap(self) -> binomialheap -> binomialheap
    def meld(other) # -> binomialheap
        binomialheap.new(@@meld_trees.(self.trees, other.trees))
    end

    # BinomialBeap(self) -> (A -> B) -> ()
    def each
        forest = self
        if !forest.empty?
            min_next = pop_min()
            yield min_next[:item]
            forest = min_next[:remaining]
        end
    end

    def inspect()
        @trees.inspect()
    end
end