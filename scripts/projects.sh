#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/github/dotfiles
# Description : FZF-based project launcher for tmux
# -----------------------------------------------------------------------------

# set -euo pipefail
trap 'echo "[project.sh] Error on line $LINENO"; exit 2' ERR

# Function: project_launch
# Description: Opens a project in a new tmux window with editor and terminal pane
# Parameters:
#   $1 - session_name (string): Target tmux session name
#   $2 - window_name (string): Name for the new window
#   $3 - project_dir (string): Absolute path to project directory
#   $4 - editor (string): Editor command to launch (e.g., "vim", "nvim")
# Returns: 0 on success
# Side Effects: Creates new window, splits pane, starts editor
project_launch() {
    local session_name="$1"
    local window_name="$2"
    local project_dir="$3"
    local editor="$4"

    tmux new-window -n "${window_name}" -c "${project_dir}"
    tmux split-window -t "${session_name}:${window_name}" -v -c "${project_dir}"
    tmux resize-pane -t "${session_name}:${window_name}" -y 20%
    tmux send-keys -t "${session_name}:${window_name}" clear C-m
    tmux select-pane -t "${session_name}:${window_name}" -U
    tmux send-keys -t "${session_name}:${window_name}" clear C-m
    tmux send-keys -t "${session_name}:${window_name}" "$editor" C-m
}

# Function: main
# Description: Entry point - prompts user to select project via fzf and launches it
# Parameters:
#   $1 - projects (string): Base directory to search for projects
#   $2 - editor (string): Editor command to use
# Returns: 0 on success, 1 if no selection or validation fails
# Side Effects: Creates new tmux window if project is selected
main() {

    local projects="$1"
    local editor="$2"

    # Validate fzf is installed
    if ! command -v fzf &>/dev/null; then
        tmux display-message "Error: fzf not installed. Install with: brew install fzf or apt install fzf"
        exit 1
    fi

    # Validate projects directory exists
    if [[ ! -d "$projects" ]]; then
        tmux display-message "Error: Projects directory not found: $projects"
        exit 1
    fi

    # Use configurable depth (default to 3 if not set)
    local min_depth="${TECHNO_HAZE_PROJECT_MIN_DEPTH:-3}"
    local max_depth="${TECHNO_HAZE_PROJECT_MAX_DEPTH:-3}"

    selected=$(find "$projects" -mindepth "$min_depth" -maxdepth "$max_depth" -type d -o -type l 2>/dev/null | fzf)
    [[ -z "$selected" ]] && exit 0

    local window_name
    window_name=$(basename "$selected")

    local session_name
    session_name=$(tmux display-message -p '#S')

    if [[ -n "$session_name" ]]; then
        project_launch "$session_name" "$window_name" "$selected" "$editor"
    else
        echo "No attached tmux session found." >&2
        exit 1
    fi
}

main "$@"
