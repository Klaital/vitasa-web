class Accumulator
    attr_accessor :data

    def initialize
        @data = []
    end

    def min
        return nil if @data.empty?
        min = data[0]
        data.each do |x|
            min = x if x < min
        end
        return min.round(1)
    end

    def max
        return nil if @data.empty?
        max = data[0]
        data.each do |x|
            max = x if x > max
        end
        return max.round(1)
    end

    def count
        return @data.length
    end

    def sum
        sum = 0
        @data.each do |x|
            sum += x
        end
        return sum.round(1)
    end

    def mean
        return 0 if @data.empty?
        (sum.to_f / count.to_f).round(1)
    end
end
