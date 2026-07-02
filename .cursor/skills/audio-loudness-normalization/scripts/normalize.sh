#!/usr/bin/env bash
# Batch loudness-normalize audio files to a target LUFS using FFmpeg two-pass loudnorm.
#
# Usage:
#   bash normalize.sh <file_or_dir> [-t LUFS] [-tp DBTP] [-o OUT_DIR] [-r] [--overwrite] [--dry-run]
#
# Examples:
#   bash normalize.sh Audio/SFX
#   bash normalize.sh click.wav -t -16
#   bash normalize.sh Audio -r -t -18 -o Audio/out
#   bash normalize.sh Audio/SFX --dry-run

set -euo pipefail

TARGET_LUFS="-14"
TRUE_PEAK="-1.5"
OUTPUT_DIR=""
RECURSE=0
OVERWRITE=0
DRY_RUN=0
INPUT=""

usage() {
  sed -n '2,10p' "$0" | tail -n +2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t) TARGET_LUFS="$2"; shift 2 ;;
    -tp) TRUE_PEAK="$2"; shift 2 ;;
    -o) OUTPUT_DIR="$2"; shift 2 ;;
    -r) RECURSE=1; shift ;;
    --overwrite) OVERWRITE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage ;;
    *)
      if [[ -z "$INPUT" ]]; then
        INPUT="$1"
        shift
      else
        echo "Unknown argument: $1" >&2
        usage
      fi
      ;;
  esac
done

[[ -n "$INPUT" ]] || usage

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "FFmpeg not found on PATH. Install ffmpeg and retry." >&2
  exit 1
fi

is_audio() {
  case "${1,,}" in
    *.wav|*.mp3|*.ogg|*.flac|*.aac|*.m4a|*.wma) return 0 ;;
    *) return 1 ;;
  esac
}

measure_loudnorm() {
  local file="$1"
  local stderr
  stderr="$(ffmpeg -hide_banner -nostats -i "$file" \
    -af "loudnorm=I=${TARGET_LUFS}:TP=${TRUE_PEAK}:LRA=11:print_format=json" \
    -f null - 2>&1 >/dev/null)" || {
      echo "FFmpeg analysis failed: $file" >&2
      echo "$stderr" >&2
      return 1
    }

  printf '%s\n' "$stderr" | awk '/^\{/{flag=1} flag{print} /^\}/{exit}'
}

normalize_file() {
  local file="$1"
  local out="$2"
  local json
  json="$(measure_loudnorm "$file")" || return 1

  local mi ml mt mth off
  mi="$(printf '%s' "$json" | sed -n 's/.*"input_i"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  ml="$(printf '%s' "$json" | sed -n 's/.*"input_lra"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  mt="$(printf '%s' "$json" | sed -n 's/.*"input_tp"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  mth="$(printf '%s' "$json" | sed -n 's/.*"input_thresh"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  off="$(printf '%s' "$json" | sed -n 's/.*"target_offset"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

  mkdir -p "$(dirname "$out")"
  ffmpeg -hide_banner -nostats -y -i "$file" \
    -af "loudnorm=I=${TARGET_LUFS}:TP=${TRUE_PEAK}:LRA=11:measured_I=${mi}:measured_LRA=${ml}:measured_TP=${mt}:measured_thresh=${mth}:offset=${off}:linear=true" \
    "$out" >/dev/null 2>&1
}

collect_files() {
  if [[ -f "$INPUT" ]]; then
    is_audio "$INPUT" || { echo "Not a supported audio file: $INPUT" >&2; exit 1; }
    printf '%s\n' "$INPUT"
    return
  fi

  if [[ ! -d "$INPUT" ]]; then
    echo "Input path not found: $INPUT" >&2
    exit 1
  fi

  if [[ "$RECURSE" -eq 1 ]]; then
    find "$INPUT" -type f | while read -r f; do
      is_audio "$f" && printf '%s\n' "$f"
    done
  else
    find "$INPUT" -maxdepth 1 -type f | while read -r f; do
      is_audio "$f" && printf '%s\n' "$f"
    done
  fi
}

INPUT_ROOT="$INPUT"
if [[ -f "$INPUT" ]]; then
  INPUT_ROOT="$(cd "$(dirname "$INPUT")" && pwd)"
else
  INPUT_ROOT="$(cd "$INPUT" && pwd)"
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="${INPUT_ROOT}/normalized"
fi

mapfile -t FILES < <(collect_files)
if [[ "${#FILES[@]}" -eq 0 ]]; then
  echo "No supported audio files found under: $INPUT"
  exit 0
fi

echo "Input:       $INPUT"
echo "Files:       ${#FILES[@]}"
echo "Target LUFS: $TARGET_LUFS"
echo "True Peak:   $TRUE_PEAK dBTP"
echo "Output:      $OUTPUT_DIR"
[[ "$DRY_RUN" -eq 1 ]] && echo "Mode:        DRY RUN"
echo

ok=0
skip=0
fail=0

for file in "${FILES[@]}"; do
  abs_file="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
  rel="${abs_file#"$INPUT_ROOT"/}"
  [[ "$rel" == "$abs_file" ]] && rel="$(basename "$abs_file")"
  out="${OUTPUT_DIR}/${rel}"

  if [[ -f "$out" && "$OVERWRITE" -eq 0 && "$DRY_RUN" -eq 0 ]]; then
    echo "[skip] $rel"
    skip=$((skip + 1))
    continue
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[plan] $rel -> $out"
    ok=$((ok + 1))
    continue
  fi

  echo "[run]  $rel"
  if normalize_file "$abs_file" "$out"; then
    ok=$((ok + 1))
  else
    echo "[fail] $rel"
    fail=$((fail + 1))
  fi
done

echo
echo "Done. processed=$ok skipped=$skip failed=$fail"
[[ "$fail" -gt 0 ]] && exit 1
