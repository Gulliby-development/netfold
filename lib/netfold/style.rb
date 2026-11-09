# frozen_string_literal: true

require "netfold/style/masks"

module Netfold
  # The styles mask and hex of a block.
  module Style
    # One line (no LF) for a block in the style mask or hex.
    def self.render(first, len, style_name)
      case style_name
      when "mask" then "#{Report.dotted(first)} #{Masks.of(len)}"
      when "hex" then format("%<first>08X/%<len>d", first:, len:)
      else raise Failure.new(1, "not implemented")
      end
    end
  end
end
