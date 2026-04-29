#!/usr/bin/env bash
set -euo pipefail

nextflow run nf-core/circrna \
   -r dev \
   -profile docker \
   -c /home/hqurashi/bigmem.config \
   -w /data/hqurashi/7_circrna/work \
   --input /media/pontikos_nas2/HarisQurashi/projects/7_circrna/data/samplesheet_HDF_D176_and_Jess_HDF.csv \
   --outdir /media/pontikos_nas2/HarisQurashi/projects/7_circrna/results/di_vs_jess_test/ \
   --tools circexplorer2 \
   --quantification_tools ciriquant,psirc,sum,max \
   --fasta /media/pontikos_nas2/HarisQurashi/refs/hg38.fa \
   --gtf /media/pontikos_nas2/HarisQurashi/refs/gencode.v46.annotation.gtf \
   --limitSjdbInsertNsj 2000000 \
   -with-report -with-trace -with-timeline \
   -resume