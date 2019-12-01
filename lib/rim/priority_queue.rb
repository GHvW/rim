# typed: true
require_relative "list"
require "sorbet-runtime"

class BinomialTree
    extend T::Sig
    include Comparable

    attr_reader :data, :rank, :tree_list

    # data -> key -> tree_list(linkedlist)
    def initialize(data, rank, tree_list = List.new)
        @data = data # must have <=> defined
        @rank = rank
        @tree_list = tree_list
    end

    # sig { params(other: BinomialTree)}
    def <=>(other)
        @data <=> other.data
    end

    # sig { params(other: BinomialTree).returns(BinomialTree) }
    def link(other)
        if self <= other # min heap? Elem.leq?
            return BinomialTree.new(@data, @rank + 1, @tree_list.cons(other))
        end

        BinomialTree.new(other.data, other.rank + 1, other.tree_list.cons(self))
    end
end


class BinomialHeap

    # node -> List node -> List node
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

    @@meld_ = ->(bh1, bh2) {
        if bh1.empty?
            return bh2
        end

        if bh2.empty?
            return bh1
        end

        bh1_x_xs = bh1.x_xs()
        bh2_x_xs = bh2.x_xs()

        if bh1_x_xs[:x].rank < bh2_x_xs[:x].rank
            return @@meld_.(bh1_x_xs[:xs], bh2).cons(bh1_x_xs[:x])
        elseif bh2_x_xs[:x].rank < bh1_x_xs[:x].rank
            return @@meld_.(bh1, bh2_x_xs[:xs]).cons(bh2_x_xs[:x])
        end 

        @insert_node.(bh1_x_xs[:x].link(bh2_x_xs[:x]), @@meld_.(bh1_x_xs[:xs], bh2_x_xs[:xs]))
    }

    def initialize(trees = List.new)
        @trees = trees
    end

    def empty?
        @trees.nil?
    end

    def insert(data) # -> BinomialHeap
        BinomialHeap.new(@@insert_node.(BinomialTree.new(data, 0), @trees))
    end

    def find_min() # -> A
    end

    def delete_min() # -> BinomialHeap
    end

    def meld(other) # -> BinomialHeap
        @@meld_.(self, other)
    end
end