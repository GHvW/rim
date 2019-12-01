# typed: true
class List
    include Enumerable

    @@find_last = ->(list) {
        x_xs = list.x_xs()
        if x_xs.empty?
            return
        end

        if x_xs[:xs].empty?
            return x_xs[:x]
        end

        @@find_last.(x_xs[:xs])
    }

    # attr_reader :node

    def initialize(node = {})
        @node = node
    end

    def self.from_array(array)
    end

    def empty?()
        @node.empty?
    end

    def x_xs()
        empty? ? {} : { :x => @node[:head], :xs => @node[:tail] }
    end

    def cons(data)
        List.new({ :head => data, :tail => self })
    end

    # is O(n)
    def last()
        @@find_last.(self)
    end

    def concat(other)
        self.lazy().chain(other)
    end

    def each(&block)
        head = @node[:head]
        tail = @node[:tail]
        if !head.nil?
            while !tail.empty?
                block.(head)
                x_xs = tail.x_xs()
                head = x_xs[:x]
                tail = x_xs[:xs]
            end
            block.(head)
        end
    end

    def inspect()
        if empty?
            return [].inspect()
        end
        [@node[:head], @node[:tail]].inspect()
    end

    private
    
end