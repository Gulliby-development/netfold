# frozen_string_literal: true

module Netfold
  # The gaps command: the addresses of the --within network that no network of the list covers.
  module CmdGaps
    def self.run(options, items)
      wlo, wlen = Nets.parse(options.within)
      whi = wlo + (1 << (32 - wlen)) - 1
      cur = wlo
      gaps = []
      Merge.intervals(items).each do |lo, hi|
        next if hi < cur
        break if lo > whi || cur > whi

        gaps << [cur, [lo - 1, whi].min] if lo > cur
        cur = [cur, hi + 1].max
      end
      gaps << [cur, whi] if cur <= whi
      blocks = gaps.flat_map { |lo, hi| Merge.decompose(lo, hi) }
      out = blocks.empty? ? "none\n" : blocks.map { |first, len| "#{Report.render(first, len, options.style)}\n" }.join
      Outcome.new(status: 0, out: out, err: "")
    end
  end
end
