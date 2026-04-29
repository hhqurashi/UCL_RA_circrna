#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   auto_samplesheet.sh <OUTPUT_DIR_OR_SUBPATH> <FASTQ_LIST>
#
# Notes:
# - If <OUTPUT_DIR_OR_SUBPATH> is absolute (/…), it’s used as-is.
# - If relative, it’s joined to BASE (override with env AUTO_SS_BASE).
# - FASTQ names must end with “…_[L]<lane>_1.fq.gz”; mate inferred as “…_2.fq.gz”.

BASE_DEFAULT="/media/pontikos_nas2/HarisQurashi/projects/7_circrna/fastq"
BASE="${AUTO_SS_BASE:-$BASE_DEFAULT}"

out_arg="${1:-}"; list="${2:-}"
if [[ -z "$out_arg" || -z "$list" ]]; then
  echo "Usage: auto_samplesheet.sh <OUTPUT_DIR|relative_subpath> <fastqs.txt>"
  echo "Tip: set AUTO_SS_BASE to override base dir for relative outputs (current: $BASE)"
  exit 2
fi

# Resolve output dir
if [[ "$out_arg" = /* ]]; then
  outdir="$out_arg"
else
  outdir="$BASE/$out_arg"
fi
samplesheet="$outdir/samplesheet.csv"

# Read list (CRLF-safe)
mapfile -t FLIST < <(awk '{sub(/\r$/,""); if($0!="") print}' "$list")

mkdir -p "$outdir"
tmpfile="$(mktemp "$outdir/.samplesheet.tmp.XXXXXX")" || { echo "Cannot write in $outdir"; exit 3; }
rm -f "$tmpfile"

rows=()
for fq1 in "${FLIST[@]}"; do
  [[ -z "${fq1// }" || "${fq1}" =~ ^# ]] && continue
  [[ -r "$fq1" ]] || { echo "Not readable: $fq1"; exit 6; }

  fname="$(basename "$fq1")"
  dir="$(cd "$(dirname "$fq1")" && pwd)"

  # Accept SAMPLE_L<lane>_1.fq.gz OR SAMPLE_<lane>_1.fq.gz (or .fastq.gz)
  if [[ "$fname" =~ ^(.+)_L?([0-9]+)_1\.(fq|fastq)\.gz$ ]]; then
    sample="${BASH_REMATCH[1]}"
    lane="${BASH_REMATCH[2]}"
  else
    echo "Invalid FASTQ name (expect SAMPLE_[L]<lane>_1.fq.gz): $fq1"
    exit 4
  fi

  fq2="${dir}/${fname/_1./_2.}"
  [[ -r "$fq2" ]] || { echo "Mate missing for $fq1 (expected: $fq2)"; exit 7; }

  # CSV row (comma-separated) with strandedness=auto
  rows+=("${sample},${fq1},${fq2},auto")
done

# Write header + rows atomically
{
  echo "sample,fastq_1,fastq_2,strandedness"
  for r in "${rows[@]}"; do echo "$r"; done
} > "$samplesheet"

# Helper env file
echo "SAMPLESHEET=\"$samplesheet\"" > "$outdir/samplesheet.env"

echo "Wrote: $samplesheet"
echo "ℹ️  Also wrote: $outdir/samplesheet.env  (use: source \"$outdir/samplesheet.env\")"