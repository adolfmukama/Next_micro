#!/bin/bash

# Path to the input sequence file
INPUT_SEQ_FILE="/workspaces/Next_micro/test_data/Ecoli_data/input_sequence.txt"

# Directory to store ska output
SKA_OUTPUT_DIR="/workspaces/Next_micro/test_data/ska_output"

# Ensure output directory exists
mkdir -p "$SKA_OUTPUT_DIR"

# Output file names
SKF_FILE="${SKA_OUTPUT_DIR}/seqs.skf"
DISTANCE_OUTPUT="${SKA_OUTPUT_DIR}/distances.txt"

# ska build options
KMER_SIZE=31 # Please keep the K-mer size at 31, do not change
THREADS=4 # Adjust based on your hardware

# Build .skf file
ska build -o "${SKF_FILE%.skf}" -k $KMER_SIZE --threads $THREADS -f "$INPUT_SEQ_FILE"

# Check if ska build was successful
if [ $? -ne 0 ]; then
     echo "ska build failed. Please check your input files and try again."
     exit 1
fi

echo "ska build completed successfully."

# ska distance options
FILTER_AMBIGUOUS="--filter-ambiguous" # Please keep this flag on to ignore ambiguous bases, do not change
MIN_FREQ="--min-freq 1" # A freq threshold of 1 required, please do not change

# Generate the distance matrix
ska distance $FILTER_AMBIGUOUS $MIN_FREQ -o "$DISTANCE_OUTPUT" "$SKF_FILE"

# Check if ska distance was successful
if [ $? -ne 0 ]; then
    echo "ska distance failed. Please check your .skf file and try again." 
    exit 1
fi

echo "Distance matrix generated successfully: $DISTANCE_OUTPUT"
