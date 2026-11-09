# frozen_string_literal: true

module Netfold
  # The count command: the number of addresses (or hosts) that the merged list covers.
  module CmdCount
    def self.run(options, items)
      total = Merge.blocks(items).sum do |_first, len|
        size = 1 << (32 - len)
        options.mode == "hosts" && len <= 30 ? size - 2 : size
      end
      Outcome.new(status: 0, out: "#{total}\n", err: "")
    end
  end
end
