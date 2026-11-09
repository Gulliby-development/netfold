# frozen_string_literal: true

require "netfold/registry"
require "netfold/cli"
require "netfold/cmd_check"
require "netfold/cmd_contains"
require "netfold/cmd_count"
require "netfold/cmd_gaps"
require "netfold/cmd_merge"
require "netfold/cmd_sort"
require "netfold/cmd_split"
require "netfold/input"
require "netfold/merge"
require "netfold/nets"
require "netfold/report"
require "netfold/style"

# netfold: sort, merge, count, split and search lists of IPv4 networks.
module Netfold
  # What one run of the program gives back: the exit status and the two output streams.
  Outcome = Data.define(:status, :out, :err)

  # An error that ends a command: Cli.run turns it into `netfold: MESSAGE` on standard error.
  class Failure < StandardError
    attr_reader :status

    def initialize(status, message)
      super(message)
      @status = status
    end
  end

  # One network of the list: its line number, the word as written, the first address and the prefix length.
  Net = Data.define(:line, :word, :first, :len) do
    # The number of addresses of the network.
    def size
      1 << (32 - len)
    end

    # The last address of the network.
    def last
      first + size - 1
    end
  end

  # The options of a command line, with the defaults filled in: style cidr, mode addresses;
  # within and ip are empty strings and prefix is nil when absent.
  Options = Data.define(:style, :mode, :within, :ip, :prefix)
end
