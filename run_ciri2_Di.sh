#!/usr/bin/env bash
set -euo pipefail

# --- edit only these ---
FASTQ_DIR="/media/pontikos_nas2/HarisQurashi/projects/7_circrna/fastq"
OUT_BASE="/mnt/scratch/hqurashi/circrna/ciri2"
REF="/mnt/data/hqurashi/ciriquant_ref/genome.fa"
GTF="/mnt/data/hqurashi/ciriquant_ref/genes.gtf"
CIRI2_PL="/mnt/data/hqurashi/tools/CIRI2/CIRI_v2.0.6/CIRI2.pl"
THREADS=16
# ----------------------

mkdir -p "$OUT_BASE"

# Decide mito contig name automatically (chrM vs MT) and set -M only if needed
CHRM_OPT=""
if cut -f1 "${REF}.fai" | grep -qx "MT"; then
  CHRM_OPT="-M MT"
fi

# Basic sanity
command -v bwa >/dev/null || { echo "[ERROR] bwa not found in PATH"; exit 1; }
command -v perl >/dev/null || { echo "[ERROR] perl not found in PATH"; exit 1; }
[[ -s "$REF" && -s "$GTF" && -s "$CIRI2_PL" ]] || { echo "[ERROR] missing REF/GTF/CIRI2.pl"; exit 1; }

for r1 in "$FASTQ_DIR"/*_1.fq.gz; do
  r2="${r1%_1.fq.gz}_2.fq.gz"
  [[ -f "$r2" ]] || { echo "[WARN] missing mate2 for $r1 -> expected $r2; skipping"; continue; }

  b="$(basename "$r1" .fq.gz)"  # e.g. HDF_D176_1_1
  b="${b%_1}"                   # e.g. HDF_D176_1
  rep="${b##*_}"                # e.g. 1
  sample="${b%_*}"              # e.g. HDF_D176
  prefix="${sample}_rep${rep}"  # e.g. HDF_D176_rep1

  out="$OUT_BASE/$prefix"
  mkdir -p "$out"

  # skip if already done
  if [[ -s "$out/${prefix}.ciri2.txt" ]]; then
    echo "[SKIP] $prefix already has ciri2 output"
    continue
  fi

  echo "[RUN] $prefix"
  echo "  R1=$r1"
  echo "  R2=$r2"
  echo "  OUT=$out"

  # IMPORTANT: do NOT sort/filter SAM before CIRI2
  bwa mem -T 19 -t "$THREADS" "$REF" "$r1" "$r2" 1> "$out/aln.sam" 2> "$out/bwa.log"

  perl "$CIRI2_PL" \
    -I "$out/aln.sam" \
    -O "$out/${prefix}.ciri2.txt" \
    -F "$REF" \
    -A "$GTF" \
    -T "$THREADS" \
    $CHRM_OPT \
    -G "$out/${prefix}.ciri2.log"

  # save space
  gzip -f "$out/aln.sam"
done

echo "[DONE] All pairs in $FASTQ_DIR"