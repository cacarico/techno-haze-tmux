#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Validation Library - Helper functions for input validation and system checks
# -----------------------------------------------------------------------------

# Function: detect_os
# Description: Detects the operating system
# Returns: "linux", "macos", or "unknown" via stdout
# Example: os=$(detect_os)
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

# Function: command_exists
# Description: Checks if a command is available in PATH
# Parameters:
#   $1 - command name to check
# Returns: 0 if command exists, 1 otherwise
# Example: if command_exists "fzf"; then ... fi
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function: file_readable
# Description: Checks if a file exists and is readable
# Parameters:
#   $1 - file path to check
# Returns: 0 if readable, 1 otherwise
# Example: if file_readable "/proc/stat"; then ... fi
file_readable() {
    [[ -r "$1" ]]
}

# Function: is_numeric
# Description: Validates if a string is a valid number (integer or decimal)
# Parameters:
#   $1 - string to validate
# Returns: 0 if numeric, 1 otherwise
# Example: if is_numeric "$value"; then ... fi
is_numeric() {
    [[ "$1" =~ ^[0-9]+\.?[0-9]*$ ]]
}

# Function: is_linux
# Description: Checks if running on Linux
# Returns: 0 if Linux, 1 otherwise
# Example: if is_linux; then ... fi
is_linux() {
    [[ "$(detect_os)" == "linux" ]]
}
