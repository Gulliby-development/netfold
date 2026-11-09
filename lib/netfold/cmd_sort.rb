# frozen_string_literal: true

module Netfold
  # The sort command: the networks ordered by first address, then prefix length.
  module CmdSort
    def self.run(options, items)
      sorted = items.sort_by { |item| [item.first, item.len] }
      lines = sorted.map { |item| "#{Report.render(item.first, item.len, options.style)}\n" }
      Outcome.new(status: 0, out: lines.join, err: "")
    end
  end
end
