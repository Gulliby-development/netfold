# frozen_string_literal: true

require "netfold"

# The helper of the row files: each row is [args, input, status, out, err] or, for check_reads, [args, "", reads, "", ""].
module Harness
  # Runs every row through Netfold::Cli.run and compares status, standard output and standard error.
  def self.check_rows(rows, label = "rows")
    RSpec.describe label do
      rows.each_with_index do |(args, input, status, out, err), index|
        it "row #{index + 1}" do
          reply = Netfold::Cli.run(args, input)
          expect([reply.status, reply.out, reply.err]).to eq([status, out, err])
        end
      end
    end
  end

  # Compares Netfold::Cli.reads_stdin? with the row's status field: 1 when the command line must read standard input, 0 when not.
  def self.check_reads(rows)
    RSpec.describe "reads_stdin?" do
      rows.each_with_index do |(args, _input, flag, _out, _err), index|
        it "row #{index + 1}" do
          expect(Netfold::Cli.reads_stdin?(args)).to eq(flag == 1)
        end
      end
    end
  end
end
