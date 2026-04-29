#!/usr/bin/env bash
set -euo pipefail

# --- edit only these ---
JESS_DIR="/media/pontikos_nas2/JessicaGardner/RNA_SEQ/Daniele_new/RNASeq_master/retinal_organoids/eyecups_cleanfastqs"
OUT_BASE="/mnt/scratch/hqurashi/circrna/ciriquant"
CONFIG="/mnt/data/hqurashi/ciriquant_ref/config.yml"
THREADS=16
# ----------------------

mkdir -p "$OUT_BASE"

for rep in 1 2; do
  r1="$JESS_DIR/HDFncup.rep${rep}.R1_clean.fastq.gz"
  r2="$JESS_DIR/HDFncup.rep${rep}.R2_clean.fastq.gz"
  prefix="HDF_Jess_rep${rep}"

  [[ -f "$r1" ]] || { echo "[ERROR] missing $r1"; exit 1; }
  [[ -f "$r2" ]] || { echo "[ERROR] missing $r2"; exit 1; }

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

echo "[DONE] finished Jess reps"