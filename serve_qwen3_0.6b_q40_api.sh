#!/bin/sh

./dllama-api \
  --host 127.0.0.1 \
  --port 9990 \
  --model models/qwen3_0.6b_q40/dllama_model_qwen3_0.6b_q40.m \
  --tokenizer models/qwen3_0.6b_q40/dllama_tokenizer_qwen3_0.6b_q40.t \
  --buffer-float-type q80 \
  --nthreads 6 \
  --max-seq-len 2048
