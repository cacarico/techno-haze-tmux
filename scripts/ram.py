#!/usr/bin/env python

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/github/techno-haze-tmux
# Description : Gets ram
# -----------------------------------------------------------------------------

import psutil

# Get virtual memory details
memory_info = psutil.virtual_memory()

# Total memory in GB
total_memory_gb = memory_info.total / (1024 ** 3)

# Used memory in GB
used_memory_gb = memory_info.used / (1024 ** 3)

print(f"{total_memory_gb:.1f}GB/{used_memory_gb:.0f}GB")
