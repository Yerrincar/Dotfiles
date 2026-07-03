#!/usr/bin/env bash

PROJECT_DIR="${1:-$PWD}"

tmux has-session -t Main 2>/dev/null ||
    tmux new-session -d -s Main -c "$PROJECT_DIR"

tmux has-session -t Compiler 2>/dev/null ||
    tmux new-session -d -s Compiler -c "$PROJECT_DIR"

tmux has-session -t Extra 2>/dev/null ||
    tmux new-session -d -s Extra -c "$PROJECT_DIR"

tmux attach-session -t Main
