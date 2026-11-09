# frozen_string_literal: true

module Netfold
  # The merge command: the fewest networks that cover the same addresses as the list.
  module CmdMerge
    def self.run(options, items)
      lines = Merge.blocks(items).map { |first, len| "#{Report.render(first, len, options.style)}\n" }
      Outcome.new(status: 0, out: lines.join, err: "")
    end
  end
end
