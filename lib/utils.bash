#!/usr/bin/env bash
# Shared helpers for asdf-cobol. Do not set -e here so callers stay in control
# of their own error handling.

GNUCOBOL_PRIMARY_MIRROR="${GNUCOBOL_PRIMARY_MIRROR:-https://ftp.gnu.org/gnu/gnucobol}"
GNUCOBOL_FALLBACK_MIRROR="${GNUCOBOL_FALLBACK_MIRROR:-https://downloads.sourceforge.net/project/gnucobol/gnucobol}"

fail() {
  echo "asdf-cobol: $*" >&2
  exit 1
}

# Only 1.0 / 1.1 used the gnu-cobol-* tarball name.
is_legacy_version() {
  case "$1" in
    1.0|1.1) return 0 ;;
    *)       return 1 ;;
  esac
}

tarball_name() {
  if is_legacy_version "$1"; then
    echo "gnu-cobol-$1.tar.gz"
  else
    echo "gnucobol-$1.tar.gz"
  fi
}

primary_url() {
  echo "${GNUCOBOL_PRIMARY_MIRROR}/$(tarball_name "$1")"
}

# SourceForge groups releases by major.minor under /gnucobol/<series>/<file>/download.
fallback_url() {
  local version="$1"
  local series
  series=$(echo "$version" | cut -d. -f1-2)
  echo "${GNUCOBOL_FALLBACK_MIRROR}/${series}/$(tarball_name "$version")/download"
}

download_release() {
  local version="$1"
  local out="$2"
  local primary fallback
  primary=$(primary_url "$version")
  fallback=$(fallback_url "$version")

  echo "asdf-cobol: downloading $primary"
  if curl -fsSL --retry 3 --retry-delay 3 -o "$out" "$primary"; then
    return 0
  fi
  echo "asdf-cobol: primary mirror failed, trying $fallback" >&2
  curl -fLC - --retry 3 --retry-delay 3 -o "$out" "$fallback" \
    || fail "could not download GnuCOBOL $version from any mirror"
}

# Parse the GNU FTP directory listing for tarball filenames and extract versions.
list_all_versions() {
  local html
  html=$(curl -fsSL "${GNUCOBOL_PRIMARY_MIRROR}/") || fail "could not reach $GNUCOBOL_PRIMARY_MIRROR"
  echo "$html" \
    | { grep -Eo 'href="(gnu-cobol|gnucobol)-[0-9][^"]*\.tar\.gz"' || true; } \
    | sed -E 's/href="(gnu-cobol|gnucobol)-([^"]+)\.tar\.gz"/\2/' \
    | sort -V -u
}

# Newest version that is not a pre-release.
latest_stable_version() {
  list_all_versions | grep -Ev -- '-(rc|pre|beta|alpha)' | tail -n1
}

# Hard requirements: refuse to even try the build without these.
require_build_tools() {
  local missing=()
  command -v make >/dev/null 2>&1 || missing+=("make")
  command -v tar  >/dev/null 2>&1 || missing+=("tar")
  command -v curl >/dev/null 2>&1 || missing+=("curl")
  if ! command -v cc >/dev/null 2>&1 && ! command -v gcc >/dev/null 2>&1; then
    missing+=("a C compiler (gcc/cc)")
  fi
  if (( ${#missing[@]} > 0 )); then
    fail "missing required tools: ${missing[*]}"
  fi
}

# Soft warning for libraries — configure may still find them in non-standard paths.
warn_missing_libs() {
  command -v pkg-config >/dev/null 2>&1 || return 0
  local soft=()
  pkg-config --exists gmp     2>/dev/null || soft+=(gmp)
  pkg-config --exists ncurses 2>/dev/null || soft+=(ncurses)
  if (( ${#soft[@]} > 0 )); then
    echo "asdf-cobol: pkg-config could not find: ${soft[*]}" >&2
    echo "asdf-cobol: the build may fail — run 'asdf help cobol' for OS-specific install hints" >&2
  fi
}

detect_jobs() {
  if command -v nproc >/dev/null 2>&1; then
    nproc
  elif command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.ncpu 2>/dev/null || echo 2
  else
    echo 2
  fi
}
