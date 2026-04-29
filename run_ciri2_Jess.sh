#!/usr/bin/env bash
set -euo pipefail

# --- edit only these ---
OUT_BASE="/mnt/scratch/hqurashi/circrna/ciri2"
REF="/mnt/data/hqurashi/ciriquant_ref/genome.fa"
GTF="/mnt/data/hqurashi/ciriquant_ref/genes.gtf"
CIRI2_PL="/mnt/data/hqurashi/tools/CIRI2/CIRI_v2.0.6/CIRI2.pl"
THREADS=16

JESS_DIR="/media/pontikos_nas2/JessicaGardner/RNA_SEQ/Daniele_new/RNASeq_master/retinal_organoids/eyecups_cleanfastqs"
# ----------------------

mkdir -p "$OUT_BASE"

CHRM_OPT=""
if cut -f1 "${REF}.fai" | grep -qx "MT"; then
  CHRM_OPT="-M MT"
fi

declare -a reps=("1" "2")

for rep in "${reps[@]}"; do
  r1="$JESS_DIR/HDFncup.rep${rep}.R1_clean.fastq.gz"
  r2="$JESS_DIR/HDFncup.rep${rep}.R2_clean.fastq.gz"
  prefix="HDF_Jess_rep${rep}"

  [[ -f "$r1" && -f "$r2" ]] || { echo "[ERROR] missing $r1 or $r2"; exit 1; }

  out="$OUT_BASE/$prefix"
  mkdir -p "$out"

  if [[ -s "$out/${prefix}.ciri2.txt" ]]; then
    echo "[SKIP] $prefix already has ciri2 output"
    continue
  fi

  echo "[RUN] $prefix"
  bwa mem -T 19 -t "$THREADS" "$REF" "$r1" "$r2" 1> "$out/aln.sam" 2> "$out/bwa.log"

  perl "$CIRI2_PL" \
    -I "$out/aln.sam" \
    -O "$out/${prefix}.ciri2.txt" \
    -F "$REF" \
    -A "$GTF" \
    -T "$THREADS" \
    $CHRM_OPT \
    -G "$out/${prefix}.ciri2.log"

  gzip -f "$out/aln.sam"
done

echo "[DONE] Jess reps complete"