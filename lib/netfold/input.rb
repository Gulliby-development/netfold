# frozen_string_literal: true

module Netfold
  # The reading of the list of networks from the text of the input.
  module Input
    # The lines of the text: cut at LF, one trailing CR dropped per line.
    def self.lines(text)
      return [] if text.empty?

      pieces = text.split("\n", -1)
      pieces.pop if text.end_with?("\n")
      pieces.map { |piece| piece.delete_suffix("\r") }
    end

    # The Array of Net of the list, or a Failure with status 1.
    def self.read(text)
      lines = lines(text)
      raise Failure.new(1, "input is too long (max #{MAX_LINES} lines)") if lines.size > MAX_LINES

      items = []
      lines.each_with_index do |line, index|
        item = net(line, index + 1)
        items << item if item
      end
      raise Failure.new(1, "no networks") if items.empty?

      items
    end

    # The Net of one line, or nil when the line is skipped.
    def self.net(line, number)
      words = line.split(/[ \t]+/).reject(&:empty?)
      return nil if words.empty? || words[0].start_with?("#")
      raise Failure.new(1, "line #{number}: expected 1 network") if words.size > 1

      word = words[0]
      first, len = Nets.parse(word)
      raise Failure.new(1, "line #{number}: bad network #{word}") if first.nil?
      raise Failure.new(1, "line #{number}: host bits set #{word}") unless Nets.aligned?(first, len)

      Net.new(line: number, word: word, first: first, len: len)
    end
  end
end
