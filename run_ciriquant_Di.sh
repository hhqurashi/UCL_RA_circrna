#!/usr/bin/env bash
set -euo pipefail

# --- edit only these ---
FASTQ_DIR="/media/pontikos_nas2/HarisQurashi/projects/7_circrna/fastq"
OUT_BASE="/mnt/scratch/hqurashi/circrna/ciriquant/"
CONFIG="/mnt/data/hqurashi/ciriquant_ref/config.yml"
THREADS=16
# ----------------------

# loop over mate1 files, infer mate2, build prefix = SAMPLE_repN
for r1 in "$FASTQ_DIR"/*_1.fq.gz; do
  r2="${r1%_1.fq.gz}_2.fq.gz"
  [[ -f "$r2" ]] || { echo "[WARN] missing mate2 for $r1 -> expected $r2; skipping"; continue; }

  b="$(basename "$r1" .fq.gz)"      # e.g. HDF_D176_1_1
  b="${b%_1}"                       # e.g. HDF_D176_1   (drop mate)
  rep="${b##*_}"                    # e.g. 1
  sample="${b%_*}"                  # e.g. HDF_D176
  prefix="${sample}_rep${rep}"      # e.g. HDF_D176_rep1

  out_dir="$OUT_BASE/$prefix"
  mkdir -p "$out_dir"

  # skip if already finished
  if [[ -s "$out_dir/$prefix.gtf" ]]; then
    echo "[SKIP] $prefix already has $prefix.gtf"
    continue
  fi

  echo "[RUN] $prefix"
  CIRIquant -t "$THREADS" \
    -1 "$r1" -2 "$r2" \
    --config "$CONFIG" \
    -o "$out_dir" \
    -p "$prefix"
done

echo "[DONE] finished all FASTQs in $FASTQ_DIR"