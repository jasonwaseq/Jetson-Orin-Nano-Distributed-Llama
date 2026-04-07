#!/bin/sh

set -eu

if [ "${JETSON_CLOCKS:-1}" = "1" ]; then
  if sudo -n true 2>/dev/null; then
    sudo -n jetson_clocks >/dev/null 2>&1 || true
  elif [ -n "${SUDO_PASSWORD:-}" ]; then
    printf '%s\n' "$SUDO_PASSWORD" | sudo -S jetson_clocks >/dev/null 2>&1 || true
  fi
fi

if [ "${RENICE:-1}" = "1" ]; then
  if sudo -n true 2>/dev/null; then
    exec sudo -n nice -n -20 ./dllama-api \
      --host 127.0.0.1 \
      --port 9990 \
      --model models/qwen3_0.6b_q40/dllama_model_qwen3_0.6b_q40.m \
      --tokenizer models/qwen3_0.6b_q40/dllama_tokenizer_qwen3_0.6b_q40.t \
      --buffer-float-type q80 \
      --nthreads 1 \
      --n-batches 1 \
      --gpu-index 0 \
      --max-seq-len 1024
  elif [ -n "${SUDO_PASSWORD:-}" ]; then
    exec sh -c "printf '%s\n' \"\$1\" | sudo -S nice -n -20 ./dllama-api \
      --host 127.0.0.1 \
      --port 9990 \
      --model models/qwen3_0.6b_q40/dllama_model_qwen3_0.6b_q40.m \
      --tokenizer models/qwen3_0.6b_q40/dllama_tokenizer_qwen3_0.6b_q40.t \
      --buffer-float-type q80 \
      --nthreads 1 \
      --n-batches 1 \
      --gpu-index 0 \
      --max-seq-len 1024" sh "$SUDO_PASSWORD"
  fi
fi

exec ./dllama-api \
  --host 127.0.0.1 \
  --port 9990 \
  --model models/qwen3_0.6b_q40/dllama_model_qwen3_0.6b_q40.m \
  --tokenizer models/qwen3_0.6b_q40/dllama_tokenizer_qwen3_0.6b_q40.t \
  --buffer-float-type q80 \
  --nthreads 1 \
  --n-batches 1 \
  --gpu-index 0 \
  --max-seq-len 1024
