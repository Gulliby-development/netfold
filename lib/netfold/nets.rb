# frozen_string_literal: true

module Netfold
  # The grammar of addresses, prefix lengths and network words.
  module Nets
    # The Integer of a dotted address, or nil when the word is not one.
    def self.address(word)
      parts = word.split(".", -1)
      return nil unless parts.length == 4

      value = 0
      parts.each do |part|
        return nil unless part.match?(/\A(0|[1-9][0-9]{0,2})\z/)

        number = Integer(part, 10)
        return nil if number > 255

        value = (value << 8) | number
      end
      value
    end

    # The prefix length of a word (0 to 32), or nil.
    def self.length(word)
      return nil unless word.match?(/\A(0|[1-9][0-9]?)\z/)

      number = Integer(word, 10)
      number > 32 ? nil : number
    end

    # [first, len] of a network word, or nil.
    def self.parse(word)
      parts = word.split("/", -1)
      return nil unless [1, 2].include?(parts.length)

      first = address(parts[0])
      len = parts.length == 1 ? 32 : length(parts[1])
      return nil if first.nil? || len.nil?

      [first, len]
    end

    # True when the host bits of the address are clear.
    def self.aligned?(first, len)
      first.nobits?((1 << (32 - len)) - 1)
    end
  end
end
