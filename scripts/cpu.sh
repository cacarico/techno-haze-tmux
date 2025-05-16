#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/github/techno-haze-tmux
# Description : Gets CPU usage as percentage
# -----------------------------------------------------------------------------

LC_ALL=C
cpu_idle=$(top -bn2 | grep "Cpu(s)" | tail -n1 | awk -F'id,' -v prefix=1 '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); print 100 - v }')
printf "%.1f%%\n" "$cpu_idle"
