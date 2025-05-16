#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/github/techno-haze-tmux
# Description : Gets RAM usage
# -----------------------------------------------------------------------------

mem_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
mem_used_kb=$(( mem_total_kb - $(grep MemAvailable /proc/meminfo | awk '{print $2}') ))

mem_total_gb=$(awk "BEGIN { printf \"%.0f\", $mem_total_kb / 1024 / 1024 }")
mem_used_gb=$(awk "BEGIN { printf \"%.1f\", $mem_used_kb / 1024 / 1024 }")

echo "${mem_used_gb}GB/${mem_total_gb}GB"
