#!/usr/bin/env bash

set -euo pipefail

# Export directory for use by all modules
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LC_ALL=en_US.UTF-8

# Source all library modules in dependency order
source "$SCRIPT_DIR/lib/validation.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# Initialize logging system (must be after utils.sh for get_tmux_option)
init_logging

# Log plugin initialization
log_info "Techno-Haze plugin loaded"

source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/keybindings.sh"
source "$SCRIPT_DIR/lib/statusbar.sh"

# Export user options globally with plugin prefix (prevents namespace collisions)
export TECHNO_HAZE_PROJECTS_DIR="$(get_tmux_option "@technohaze-projects-dir" "$HOME/ghq")"
export TECHNO_HAZE_EDITOR="$(get_tmux_option "@technohaze-editor" "${EDITOR:-vim}")"
export TECHNO_HAZE_PROJECT_MIN_DEPTH="$(get_tmux_option "@technohaze-project-depth-min" "3")"
export TECHNO_HAZE_PROJECT_MAX_DEPTH="$(get_tmux_option "@technohaze-project-depth-max" "3")"

# Initialize plugin components
setup_config
setup_keys
setup_statusbar
