# frozen_string_literal: true

module Netfold
  # The check command: the list is valid, say how many networks it holds.
  module CmdCheck
    def self.run(_options, items)
      Outcome.new(status: 0, out: "ok, #{Report.plural(items.size, "network")}\n", err: "")
    end
  end
end
