<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# netfold

[![CI](https://github.com/Gulliby-development/netfold/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/netfold/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

netfold is a small command-line tool written in Ruby 3.4 (standard library only). It reads a list of IPv4 networks on standard input, one network per line, and sorts them, merges them, counts the addresses they cover, finds the addresses nobody covers, cuts them into smaller networks or tells which of them hold an address.

It is for people who keep lists of networks (firewall rule sets, routing tables, allow lists) and use them in a terminal, in a script or in CI. It needs no network and no clock.

Run it from the repository directory:

```text
ruby exe/netfold COMMAND
```

In the examples below, `netfold` stands for a shell function that runs `ruby exe/netfold "$@"`.

## Usage

```text
usage: netfold check
       netfold sort [--style STYLE]
       netfold merge [--style STYLE]
       netfold count [--mode MODE]
       netfold gaps --within NET [--style STYLE]
       netfold contains --ip IP
       netfold split --prefix N [--style STYLE]
```

- `check` only validates the list.
- `sort` orders the networks.
- `merge` writes the fewest networks that cover the same addresses.
- `count` counts the covered addresses.
- `gaps` lists the addresses of a given network that the list does not cover.
- `contains` names the networks that hold an address.
- `split` cuts every network into smaller ones.

`help`, `-h` and `--help` as the first word print the usage on standard output and exit 0, whatever follows. `--version` prints `netfold 0.1.0` and exits 0. With no word, the usage goes to standard error and the exit status is 2.

Options:

- `--style STYLE`: one of `cidr` (the default), `range`, `mask`, `hex`.
- `--mode MODE`: one of `addresses` (the default), `hosts`.
- `--prefix N`: a whole number from 0 to 32, written with one or two digits and no leading zero (`0` is fine, `05` is not).
- `--within NET`: one network, written as a line of the list is (no host bits set).
- `--ip IP`: one address of four numbers, without `/`.

Every option takes the next word as its value. There is no `--option=value` form. Each option may be given once. The command line is checked from left to right and the first problem is the error; the input is not read then.

## Networks

The input is cut into lines at each LF. A final line without LF counts as a line, and one CR at the end of a line is dropped. At most 40 lines are accepted, skipped lines included.

- A line that holds only spaces and tabs, or whose first word starts with `#`, is skipped.
- Every other line is exactly one word, a network. Spaces and tabs at the ends of a line are ignored.
- A list without any network is an error.

A network is an address, or an address, `/` and a prefix length. An address is four numbers separated by `.`; each number is `0` or one to three decimal digits without a leading zero, at most 255 (`01` and `256` are bad). A prefix length is `0` or one or two digits without a leading zero, at most 32 (`33`, `033` and `-1` are bad). An address without `/` is a network of one address, prefix length 32.

A network holds the addresses from its first address to its last one. Host bits are set when the address is not the first address of the network: `10.0.0.1/24` has host bits set, `10.0.0.0/24` has not. Networks with host bits set are errors.

## Styles

A network is written in one of four styles:

- `cidr`: `10.0.0.0/8`; one address is `1.2.3.4/32`.
- `range`: first and last address, `10.0.0.0-10.255.255.255`; one address is `1.2.3.4-1.2.3.4`.
- `mask`: first address, a space and the netmask, `10.0.0.0 255.0.0.0`.
- `hex`: the first address as eight upper case hexadecimal digits, `/` and the prefix length, `0A000000/8`.

## Output

A command that works writes its result to standard output and nothing to standard error.

- `check`: `ok, N networks` (`ok, 1 network` for one). Skipped lines do not count.
- `sort`: every network, ordered by first address and then by prefix length (shorter first), one per line in the chosen style.
- `merge`: the fewest networks that cover exactly the same addresses, ordered by first address, one per line. Overlapping or touching networks are joined first; two neighbours that do not make one network stay two (`10.0.0.128/25` and `10.0.1.0/25`).
- `count`: the number of covered addresses, each counted once, and a line feed. With `--mode hosts` the networks that `merge` writes are counted, each with its addresses minus 2 when its prefix length is 30 or shorter, and all its addresses for length 31 or 32.
- `gaps`: the addresses of the `--within` network that no network of the list covers, as the fewest networks, in the chosen style. Networks outside it are ignored. When nothing is left, the output is `none`.
- `contains`: for every network that holds the address, in input order, a line `IP in NET`, where IP is the word as written and NET is in the `cidr` style. When no network holds it, the output is `IP is not covered` on standard output and the exit status is 1.
- `split`: every network, in input order, cut into networks of prefix length N in ascending order, in the chosen style. A network of length N stays as it is. The output has at most 256 lines.

## Examples

The examples use a POSIX shell in the repository directory, with `netfold` defined as the shell function above. `2>&1` shows the error line.

```text
$ printf '10.0.0.0/25\n10.0.0.128/25\n10.0.1.0/24\n' | netfold merge
10.0.0.0/23
$ printf '10.0.0.0/24\n192.168.1.0/30\n' | netfold sort --style range; printf '172.16.0.0/12\n' | netfold sort --style mask
10.0.0.0-10.0.0.255
192.168.1.0-192.168.1.3
172.16.0.0 255.240.0.0
$ printf '10.0.0.0/24\n10.0.0.64/26\n' | netfold gaps --within 10.0.0.0/23; printf '10.0.0.0/30\n' | netfold split --prefix 31 --style hex
10.0.1.0/24
0A000000/31
0A000002/31
$ printf '10.0.0.0/8\n10.0.0.1/24\n' | netfold check 2>&1; printf '10.0.0.0/8\n' | netfold contains 2>&1
netfold: line 2: host bits set 10.0.0.1/24
netfold: missing --ip
```

## Errors

A command that fails writes nothing to standard output and one line to standard error that starts with `netfold: `.

Exit statuses:

- 0: the command worked (also for help and version).
- 1: an error in the list or in the command, and `contains` when no network holds the address.
- 2: an error in the command line (or no command at all); the input is not read.

Command line errors (exit 2):

- `netfold: unknown command WORD`
- `netfold: unexpected argument WORD`
- `netfold: unknown option WORD`
- `netfold: option OPTION is not valid for COMMAND`
- `netfold: given twice: OPTION`
- `netfold: missing value for OPTION`
- `netfold: bad value for OPTION`
- `netfold: missing --within`, `netfold: missing --ip`, `netfold: missing --prefix`

List errors (exit 1), checked from the first line to the last; the first problem is reported:

- `netfold: input is too long (max 40 lines)`
- `netfold: line N: expected 1 network`
- `netfold: line N: bad network WORD`
- `netfold: line N: host bits set WORD`
- `netfold: no networks`

Command errors (exit 1):

- `netfold: line N: cannot split WORD into /P`, for the first network whose prefix length is longer than P
- `netfold: too many subnets (max 256)`

## Development

```text
bundle exec rubocop
bundle exec rspec
```

The project uses Ruby 3.4 and runs on Windows, macOS and Linux.

---

Built with [BAKED](https://github.com/Gulliby-development/baked), an open-source coding agent (bench round R104).
