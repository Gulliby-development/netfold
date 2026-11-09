# frozen_string_literal: true

# The version, the limits, the usage text, the styles, the modes and the command table (in the order of the usage text).
module Netfold
  VERSION = "netfold 0.1.0"
  MAX_LINES = 40
  MAX_SPLIT = 256
  STYLES = %w[cidr range mask hex].freeze
  MODES = %w[addresses hosts].freeze
  OPTIONS = %w[--style --mode --within --ip --prefix].freeze

  USAGE = <<~TEXT
    usage: netfold check
           netfold sort [--style STYLE]
           netfold merge [--style STYLE]
           netfold count [--mode MODE]
           netfold gaps --within NET [--style STYLE]
           netfold contains --ip IP
           netfold split --prefix N [--style STYLE]
  TEXT

  # One entry per command: its word, the options it accepts, the option that must be given (or "")
  # and the module whose run(options, items) function runs it (file lib/netfold/<snake case of the name>.rb).
  COMMANDS = [
    { name: "check", options: [], required: "", handler: :CmdCheck },
    { name: "sort", options: ["--style"], required: "", handler: :CmdSort },
    { name: "merge", options: ["--style"], required: "", handler: :CmdMerge },
    { name: "count", options: ["--mode"], required: "", handler: :CmdCount },
    { name: "gaps", options: ["--within", "--style"], required: "--within", handler: :CmdGaps },
    { name: "contains", options: ["--ip"], required: "--ip", handler: :CmdContains },
    { name: "split", options: ["--prefix", "--style"], required: "--prefix", handler: :CmdSplit }
  ].freeze
end
