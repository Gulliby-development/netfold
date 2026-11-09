# frozen_string_literal: true

module Netfold
  # The command line: help, version, the option rules, the list and the call of the command.
  module Cli
    # The result of one run for the command line `args` and the input text `stdin`.
    def self.run(args, stdin)
      first = args.first
      return Outcome.new(status: 2, out: "", err: USAGE) if first.nil?
      return Outcome.new(status: 0, out: USAGE, err: "") if ["help", "-h", "--help"].include?(first)
      return Outcome.new(status: 0, out: "#{VERSION}\n", err: "") if first == "--version"

      entry = COMMANDS.find { |command| command[:name] == first }
      return Outcome.new(status: 2, out: "", err: "netfold: unknown command #{first}\n") if entry.nil?

      opts = options(entry, args.drop(1))
      items = Input.read(stdin)
      Netfold.const_get(entry[:handler]).run(opts, items)
    rescue Failure => e
      Outcome.new(status: e.status, out: "", err: "netfold: #{e.message}\n")
    end

    # True when the command line is a valid use of a command.
    def self.reads_stdin?(args)
      entry = COMMANDS.find { |command| command[:name] == args.first }
      return false if entry.nil?

      options(entry, args.drop(1))
      true
    rescue Failure
      false
    end

    # The Options of the words after the command word, or a Failure with status 2.
    def self.options(entry, words)
      given = {}
      index = 0
      while index < words.size
        word = words[index]
        check_word(entry, word, given)
        raise Failure.new(2, "missing value for #{word}") if index + 1 >= words.size

        raise Failure.new(2, "bad value for #{word}") unless valid_value?(word, words[index + 1])

        given[word] = words[index + 1]
        index += 2
      end
      raise Failure.new(2, "missing #{entry[:required]}") unless entry[:required].empty? || given.key?(entry[:required])

      build(given)
    end

    # Raises the Failure of an option word that is not usable here.
    def self.check_word(entry, word, given)
      raise Failure.new(2, "unexpected argument #{word}") if word == "-" || !word.start_with?("-")
      raise Failure.new(2, "unknown option #{word}") unless OPTIONS.include?(word)
      raise Failure.new(2, "option #{word} is not valid for #{entry[:name]}") unless entry[:options].include?(word)
      raise Failure.new(2, "given twice: #{word}") if given.key?(word)
    end

    # True when the value is good for the option.
    def self.valid_value?(option, value)
      case option
      when "--style" then STYLES.include?(value)
      when "--mode" then MODES.include?(value)
      when "--prefix" then !Nets.length(value).nil?
      when "--within"
        parsed = Nets.parse(value)
        !parsed.nil? && Nets.aligned?(*parsed)
      else !Nets.address(value).nil?
      end
    end

    # The Options with the defaults filled in.
    def self.build(given)
      prefix = given["--prefix"]
      Options.new(
        style: given.fetch("--style", "cidr"),
        mode: given.fetch("--mode", "addresses"),
        within: given.fetch("--within", ""),
        ip: given.fetch("--ip", ""),
        prefix: prefix && Integer(prefix, 10)
      )
    end
  end
end
