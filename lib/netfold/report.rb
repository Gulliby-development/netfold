# frozen_string_literal: true

module Netfold
  # The writing of addresses, blocks and counts.
  module Report
    # A.B.C.D of an address.
    def self.dotted(value)
      [24, 16, 8, 0].map { |shift| (value >> shift) & 255 }.join(".")
    end

    # One line (no LF) for a block in a style.
    def self.render(first, len, style)
      case style
      when "cidr" then "#{dotted(first)}/#{len}"
      when "range" then "#{dotted(first)}-#{dotted(first + (1 << (32 - len)) - 1)}"
      else Style.render(first, len, style)
      end
    end

    # "1 network" or "N networks".
    def self.plural(count, noun)
      count == 1 ? "1 #{noun}" : "#{count} #{noun}s"
    end
  end
end
