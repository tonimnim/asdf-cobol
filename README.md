# asdf-cobol

[GnuCOBOL](https://gnucobol.sourceforge.io/) plugin for the
[asdf](https://github.com/asdf-vm/asdf) version manager.

## Install the plugin

```bash
asdf plugin add cobol https://github.com/tonimnim/asdf-cobol.git
```

## Build dependencies

GnuCOBOL is compiled from source, so a C toolchain plus a handful of
libraries must be available before `asdf install cobol`.

**Debian / Ubuntu**

```bash
sudo apt-get install build-essential libgmp-dev libdb-dev libncurses-dev \
                     libxml2-dev libcjson-dev
```

**Fedora / RHEL**

```bash
sudo dnf install gcc make gmp-devel libdb-devel ncurses-devel libxml2-devel \
                 cjson-devel
```

**Arch**

```bash
sudo pacman -S --needed base-devel gmp db ncurses libxml2 cjson
```

**macOS (Homebrew)**

```bash
brew install gmp berkeley-db ncurses
```

Run `asdf help cobol` after installing the plugin to see the same list.

## Usage

```bash
asdf list all cobol            # all installable versions
asdf latest cobol              # newest stable version
asdf install cobol 3.2         # install a specific version
asdf install cobol latest      # install the latest stable
asdf global cobol 3.2          # make it the default
asdf local cobol 3.2           # pin it via .tool-versions

cobc --version
```

## Mirrors

Source tarballs are pulled from, in order:

1. `https://ftp.gnu.org/gnu/gnucobol/` (primary)
2. `https://sourceforge.net/projects/gnucobol/` (fallback)

If you run an internal mirror, override the primary with an env var:

```bash
GNUCOBOL_PRIMARY_MIRROR=https://mirrors.example.com/gnucobol \
  asdf install cobol 3.2
```

`GNUCOBOL_FALLBACK_MIRROR` is also honored.

## Troubleshooting

- **`fatal error: gmp.h: No such file or directory`** — install the GMP
  development headers (see Build dependencies).
- **`./configure` runs for a long time** — that's normal; GnuCOBOL's autotools
  do extensive feature detection. asdf rebuilds from source every install, so
  expect this on each new version.
- **A version listed by `asdf list all cobol` fails to download** — some old
  releases live in subdirectories on GNU FTP. Open an issue with the version.

## Layout

| Script               | Purpose                                              |
|----------------------|------------------------------------------------------|
| `bin/list-all`       | All installable versions from the mirror.            |
| `bin/latest-stable`  | Newest version without `-rc`/`-pre`.                 |
| `bin/download`       | Fetches and extracts the source tarball.             |
| `bin/install`        | Configures, builds, and installs from source.        |
| `bin/exec-env`       | Sets PATH / LD_LIBRARY_PATH for shimmed commands.    |
| `bin/list-bin-paths` | Tells asdf where the binaries live (`bin`).          |
| `bin/help.overview`  | One-line description for `asdf help cobol`.          |
| `bin/help.deps`      | OS-specific dependency install commands.             |
| `lib/utils.bash`     | Mirror handling, version parsing, dep checks.        |

Lint before pushing:

```bash
shellcheck -x bin/* lib/*.bash
```

## Contributing

Issues and PRs welcome at
<https://github.com/tonimnim/asdf-cobol/issues>.

## License

[MIT](./LICENSE)
