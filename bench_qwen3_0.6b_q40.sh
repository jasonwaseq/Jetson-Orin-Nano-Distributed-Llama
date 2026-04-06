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
        --max-seq-len "$seq" \
        2>&1 | awk '/Prediction/{f=1; next} f&&/tokens\/s/{print; exit}'
    else
      ./dllama inference \
        --prompt "$PROMPT" \
        --steps "$STEPS" \
        --model "$MODEL" \
        --tokenizer "$TOKENIZER" \
        --buffer-float-type q80 \
        --nthreads "$nthreads" \
        --max-seq-len "$seq" \
        2>&1 | awk '/Prediction/{f=1; next} f&&/tokens\/s/{print; exit}'
    fi
    i=$((i + 1))
  done
}

run_case "cpu_t4_seq2048" 4 2048 no
run_case "cpu_t5_seq2048" 5 2048 no
run_case "cpu_t6_seq1024" 6 1024 no
run_case "cpu_t6_seq2048" 6 2048 no
run_case "nice_t6_seq1024" 6 1024 yes
run_case "nice_t6_seq2048" 6 2048 yes
