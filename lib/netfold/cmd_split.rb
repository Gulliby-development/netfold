# frozen_string_literal: true

module Netfold
  # The split command: every network of the list cut into blocks of the --prefix length, in input order.
  module CmdSplit
    def self.run(options, items)
      prefix = options.prefix
      bad = items.find { |net| net.len > prefix }
      raise Failure.new(1, "line #{bad.line}: cannot split #{bad.word} into /#{prefix}") if bad

      total = items.sum { |net| 1 << (prefix - net.len) }
      raise Failure.new(1, "too many subnets (max #{MAX_SPLIT})") if total > MAX_SPLIT

      step = 1 << (32 - prefix)
      out = items.flat_map do |net|
        Array.new(1 << (prefix - net.len)) { |i| "#{Report.render(net.first + (i * step), prefix, options.style)}\n" }
      end.join
      Outcome.new(status: 0, out: out, err: "")
    end
  end
end
