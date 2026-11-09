# frozen_string_literal: true

module Netfold
  # The contains command: the networks of the list that hold the --ip address, in input order.
  module CmdContains
    def self.run(options, items)
      ip = Nets.address(options.ip)
      hits = items.select { |net| ip.between?(net.first, net.last) }
      return Outcome.new(status: 1, out: "#{options.ip} is not covered\n", err: "") if hits.empty?

      out = hits.map { |net| "#{options.ip} in #{Report.dotted(net.first)}/#{net.len}\n" }.join
      Outcome.new(status: 0, out: out, err: "")
    end
  end
end
