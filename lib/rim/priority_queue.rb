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

    # (List BinomialTree, List Binomialtree) -> List BinomialTree
    @@meld_trees = ->(ts1, ts2) {
        if ts1.empty?
            return ts2
        end

        if ts2.empty?
            return ts1
        end

        ts1_x_xs = ts1.x_xs()
        x1 = ts1_x_xs[:x]
        xs1 = ts1_x_xs[:xs]

        ts2_x_xs = ts2.x_xs()
        x2 = ts2_x_xs[:x]
        xs2 = ts2_x_xs[:xs]

        if x1.rank < x2.rank
            return @@meld_trees.(xs1, ts2).cons(x1)
        elseif x2.rank < x1.rank
            return @@meld_trees.(ts1, xs2).cons(x2)
        end 

        @@insert_node.(x1.link(x2), @@meld_trees.(xs1, xs2))
    }

    attr_reader :trees

    # List BinomialTree -> BinomialHeap
    def initialize(trees = List.new)
        @trees = trees
    end

    def empty?
        @trees.empty?
    end

    # BinomialHeap(self) -> BinomialHeap
    def insert(data)
        BinomialHeap.new(@@insert_node.(BinomialTree.new(data, 0), @trees))
    end

    # BinomialHeap(self) -> A
    def find_min()
        @trees.min()&.data
    end

    # BinomialHeap(self) -> {A, BinomialHeap}
    def pop_min()
        # get_min = ->(forest) {
        #     if forest.empty?
        #         return nil
        #     end

        #     t_ts = forest.x_xs()
        #     tree = t_ts[:x]
        #     tree_list = t_ts[:xs]

        #     if tree_list.empty?
        #         return { :node => tree , :remaining => List.new }
        #     end
             
        #     val = get_min.(tree_list).x_xs()
        #     tree_ = val[:x]
        #     tree_list_ = val[:xs]

        #     if tree <=tree_
        #         return { :node => tree, :remaining => tree_list }
        #     end 

        #     { :node => tree_, tree_list_.cons(tree) }
        # }
        
        # item_remain = get_min.(@trees)
        # tree = item_remain[:node]
        # remaining_trees = item_remain[:remaining]

        # @@meld_trees.(tree.children.reverse(), remaining_trees)

        min_node = @trees.min()

        remaining = BinomialHeap.new(
            @@meld_trees.(min_node.tree_list.reverse(),
                @trees
                    .select { |node| node != min_node }
                    .reduce(List.new) { |list, node| list.cons(node) } # needed until implement to_list on Enumerable
                    .reverse()))

        { :node => min_node, :remaining => remaining }
    end

    # BinomialHeap(self) -> BinomialHeap -> BinomialHeap
    def meld(other)
        BinomialHeap.new(@@meld_trees.(self.trees, other.trees))
    end

    # BinomialBeap(self) -> (A -> B) -> ()
    def each
        forest = self
        while !forest.empty?
            min_next = forest.pop_min()
            yield min_next[:node].data
            forest = min_next[:remaining]
        end
    end

    def inspect()
        @trees.inspect()
    end
end