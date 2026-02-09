#!/usr/bin/env bash

set -euo pipefail

# Export directory for use by all modules
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LC_ALL=en_US.UTF-8

# Source all library modules in dependency order
source "$SCRIPT_DIR/lib/validation.sh"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/config.sh"

# Initialize all user configuration options (single source of truth)
init_user_options

# Initialize logging system (uses config from init_user_options)
init_logging

# Log plugin initialization
log_info "Techno-Haze plugin loaded"

source "$SCRIPT_DIR/lib/keybindings.sh"
source "$SCRIPT_DIR/lib/statusbar.sh"

# Initialize plugin components
setup_config
setup_keys
setup_statusbar
