# UCL RA circRNA Analysis

This repository contains scripts and configuration files used to run circRNA analysis workflows.

The scripts support setup of input samplesheets, execution of circRNA detection pipelines, and running alternative tools/configurations for comparison.

## Repository contents

```text
auto_samplesheet.sh
bigmem.config
run_circrna.sh
run_ciri2_*.sh
run_ciriquant_*.sh
```

## Workflow summary

The workflow is used to:

1. Generate or prepare samplesheets for circRNA analysis
2. Run circRNA detection pipelines
3. Compare outputs from different circRNA detection tools
4. Use a high-memory Nextflow configuration where required
5. Organise outputs for downstream review and interpretation

## Main files

### `auto_samplesheet.sh`

Utility script for preparing an input samplesheet automatically.

### `bigmem.config`

Nextflow configuration file for jobs requiring larger memory allocations.

### `run_circrna.sh`

Main script for launching the circRNA workflow.

### `run_ciri2_*.sh`

Scripts for running CIRI2-based circRNA detection.

### `run_ciriquant_*.sh`

Scripts for running CIRIquant-based circRNA detection.

## Input

Expected inputs include:

- RNA-seq FASTQ files
- sample metadata
- generated samplesheets
- reference genome and annotation files

Raw sequencing data and large reference files are not tracked in this repository.

## Output

Workflow outputs are generated in the configured output directories and may include circRNA prediction files, logs, and tool-specific result tables.

Large outputs and intermediate files should remain outside GitHub.
