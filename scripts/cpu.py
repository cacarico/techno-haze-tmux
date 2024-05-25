#!/usr/bin/env python

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/github/techno-haze-tmux
# Description : Gets cpu
# -----------------------------------------------------------------------------

import psutil

# Get the current CPU usage as a percentage
cpu_usage = psutil.cpu_percent(interval=1)

print(f"{cpu_usage}%")
