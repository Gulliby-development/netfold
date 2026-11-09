# frozen_string_literal: true

require "harness"

rows = [
  [["help"], "", 0, "usage: netfold check\n       netfold sort [--style STYLE]\n       netfold merge [--style STYLE]\n       netfold count [--mode MODE]\n       netfold gaps --within NET [--style STYLE]\n       netfold contains --ip IP\n       netfold split --prefix N [--style STYLE]\n", ""],
  [["-h"], "", 0, "usage: netfold check\n       netfold sort [--style STYLE]\n       netfold merge [--style STYLE]\n       netfold count [--mode MODE]\n       netfold gaps --within NET [--style STYLE]\n       netfold contains --ip IP\n       netfold split --prefix N [--style STYLE]\n", ""],
  [["--help", "--bogus"], "", 0, "usage: netfold check\n       netfold sort [--style STYLE]\n       netfold merge [--style STYLE]\n       netfold count [--mode MODE]\n       netfold gaps --within NET [--style STYLE]\n       netfold contains --ip IP\n       netfold split --prefix N [--style STYLE]\n", ""],
  [[], "", 2, "", "usage: netfold check\n       netfold sort [--style STYLE]\n       netfold merge [--style STYLE]\n       netfold count [--mode MODE]\n       netfold gaps --within NET [--style STYLE]\n       netfold contains --ip IP\n       netfold split --prefix N [--style STYLE]\n"],
  [["--version"], "", 0, "netfold 0.1.0\n", ""],
  [["--version", "x"], "", 0, "netfold 0.1.0\n", ""],
  [["frob"], "", 2, "", "netfold: unknown command frob\n"],
  [[""], "", 2, "", "netfold: unknown command \n"],
  [["Check"], "", 2, "", "netfold: unknown command Check\n"],
  [["-H"], "", 2, "", "netfold: unknown command -H\n"]
].freeze

Harness.check_rows(rows)
