#!/bin/sh

set -eu

MODEL="models/qwen3_0.6b_q40/dllama_model_qwen3_0.6b_q40.m"
TOKENIZER="models/qwen3_0.6b_q40/dllama_tokenizer_qwen3_0.6b_q40.t"
PROMPT="${PROMPT:-Hello world}"
STEPS="${STEPS:-40}"
RUNS="${RUNS:-3}"

run_case() {
  label="$1"
  nthreads="$2"
  seq="$3"
  elevate="$4"
  gpu_index="$5"
  nbatches="$6"

  i=1
  while [ "$i" -le "$RUNS" ]; do
    echo "=== $label run=$i ==="
    if [ "$elevate" = "yes" ]; then
      printf '%s\n' "${SUDO_PASSWORD:-}" | sudo -S nice -n -20 \
        ./dllama inference \
        --prompt "$PROMPT" \
        --steps "$STEPS" \
        --model "$MODEL" \
        --tokenizer "$TOKENIZER" \
        --buffer-float-type q80 \
        --nthreads "$nthreads" \
        --n-batches "$nbatches" \
        --max-seq-len "$seq" \
        ${gpu_index:+--gpu-index "$gpu_index"} \
        2>&1 | awk '/Prediction/{f=1; next} f&&/tokens\/s/{print; exit}'
    else
      ./dllama inference \
        --prompt "$PROMPT" \
        --steps "$STEPS" \
        --model "$MODEL" \
        --tokenizer "$TOKENIZER" \
        --buffer-float-type q80 \
        --nthreads "$nthreads" \
        --n-batches "$nbatches" \
        --max-seq-len "$seq" \
        ${gpu_index:+--gpu-index "$gpu_index"} \
        2>&1 | awk '/Prediction/{f=1; next} f&&/tokens\/s/{print; exit}'
    fi
    i=$((i + 1))
  done
}

run_case "gpu_t1_b1_seq1024" 1 1024 no 0 1
run_case "cpu_t4_b32_seq2048" 4 2048 no "" 32
run_case "cpu_t5_b32_seq2048" 5 2048 no "" 32
run_case "cpu_t6_b32_seq1024" 6 1024 no "" 32
run_case "cpu_t6_b32_seq2048" 6 2048 no "" 32
run_case "nice_t6_b32_seq1024" 6 1024 yes "" 32
run_case "nice_t6_b32_seq2048" 6 2048 yes "" 32
