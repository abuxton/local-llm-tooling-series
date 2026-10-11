#!/usr/bin/env sh
set -eu

: "${AIDER_MODEL:=openai/qwen2.5-coder:7b}"
: "${AIDER_API_BASE:=http://127.0.0.1:11434/v1}"
: "${AIDER_API_KEY:=ollama}"

export OPENAI_API_BASE="$AIDER_API_BASE"
export OPENAI_API_KEY="$AIDER_API_KEY"

exec aider \
  --model "$AIDER_MODEL" \
  --no-git \
  --no-auto-commits \
  --no-chat-history-file \
  --no-restore-chat-history \
  "$@"
