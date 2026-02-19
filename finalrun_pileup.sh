#!/bin/bash

# Exit safely
set -euo pipefail

# -----------------------------
# Check arguments
# -----------------------------
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <fastq_directory> <AMR-reference> <threads>"
    exit 1
fi

FASTQ_DIR="$1"
AMR_REFERENCE="$2"
THREADS="$3"

# -----------------------------
# Check required tools
# -----------------------------
command -v bwa >/dev/null 2>&1 || { echo "Error: bwa not found in PATH"; exit 1; }
command -v pileup.sh >/dev/null 2>&1 || { echo "Error: pileup.sh not found in PATH"; exit 1; }

# -----------------------------
# Process FASTQ files
# -----------------------------
for R1_FILE in "$FASTQ_DIR"/*_R1_001.fastq.gz; do

    [ -e "$R1_FILE" ] || continue

    BASENAME=$(basename "$R1_FILE" _R1_001.fastq.gz)
    R2_FILE="$FASTQ_DIR/${BASENAME}_R2_001.fastq.gz"
    SAM_FILE="${BASENAME}.sam"
    TXT_FILE="${BASENAME}.txt"
    PILEUP_OUTPUT_FILE="${BASENAME}-pileup-output.txt"

    if [ ! -f "$R2_FILE" ]; then
        echo "Warning: Missing R2 file for $BASENAME. Skipping."
        continue
    fi

    echo "====================================="
    echo "Processing sample: $BASENAME"
    echo "====================================="

    # -----------------------------
    # Run bwa mem with threads
    # -----------------------------
    echo "Running bwa mem with $THREADS threads..."
    if ! bwa mem -t "$THREADS" "$AMR_REFERENCE" "$R1_FILE" "$R2_FILE" > "$SAM_FILE"; then
        echo "Error running bwa mem for $BASENAME"
        continue
    fi

    # -----------------------------
    # Run pileup.sh and capture stdout + stderr
    # -----------------------------
    echo "Running pileup.sh..."

    if ! pileup.sh in="$SAM_FILE" out="$TXT_FILE" > "$PILEUP_OUTPUT_FILE" 2>&1; then
        echo "Error running pileup.sh for $BASENAME"
        continue
    fi

    echo "Finished sample: $BASENAME"
    echo

done

echo "Pipeline completed successfully."
