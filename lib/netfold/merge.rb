# frozen_string_literal: true

module Netfold
  # The union of the networks as sorted disjoint intervals and as the fewest aligned blocks.
  module Merge
    # Sorted [lo, hi] intervals; overlapping or touching ones are joined.
    def self.intervals(items)
      sorted = items.map { |item| [item.first, item.last] }.sort
      sorted.each_with_object([]) do |(lo, hi), out|
        if out.any? && lo <= out.last[1] + 1
          out.last[1] = hi if hi > out.last[1]
        else
          out << [lo, hi]
        end
      end
    end

    # The fewest aligned [first, len] blocks that cover lo..hi, greedy and ascending.
    def self.decompose(low, high)
      blocks = []
      cur = low
      while cur <= high
        bits = 32
        bits -= 1 until (cur % (1 << bits)).zero? && cur + (1 << bits) - 1 <= high
        blocks << [cur, 32 - bits]
        cur += 1 << bits
      end
      blocks
    end

    # The blocks of the whole union, ascending by first address.
    def self.blocks(items)
      intervals(items).flat_map { |lo, hi| decompose(lo, hi) }
    end
  end
end
