#!/usr/bin/env bash

# --- Logging Configuration ---------------------------------------------------

# Constants
readonly MAX_LOG_LINES=100  # Keep last 100 lines only

# Initialize logging (called once during plugin load)
# Note: Assumes user options are already initialized via init_user_options()
init_logging() {
    # Create log directory if it doesn't exist
    local log_dir="$(dirname "$TECHNO_HAZE_LOG_FILE")"
    mkdir -p "$log_dir" 2>/dev/null || true

    # Create log file if it doesn't exist
    touch "$TECHNO_HAZE_LOG_FILE" 2>/dev/null || true

    # Auto-detect system notification command if not specified
    if [[ -z "$TECHNO_HAZE_NOTIFICATION_COMMAND" ]]; then
        detect_notification_command
    fi
}

# Auto-detect available system notification command
detect_notification_command() {
    if command -v notify-send &>/dev/null; then
        # Linux - works with dunst, notification-daemon, etc.
        export TECHNO_HAZE_NOTIFICATION_COMMAND="notify-send"
    elif command -v osascript &>/dev/null; then
        # macOS
        export TECHNO_HAZE_NOTIFICATION_COMMAND="osascript"
    else
        # No system notification available
        export TECHNO_HAZE_NOTIFICATION_COMMAND=""
    fi
}

# Main logging function
# Usage: log_message "LEVEL" "message"
# Levels: ERROR, WARN, INFO, DEBUG
log_message() {
    local level="$1"
    local message="$2"

    # Check if we should log this level
    if ! should_log "$level"; then
        return 0
    fi

    # Format log entry
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local log_entry="[$timestamp] [$level] $message"

    # Write to log file
    if [[ -w "$TECHNO_HAZE_LOG_FILE" ]]; then
        echo "$log_entry" >> "$TECHNO_HAZE_LOG_FILE"

        # Rotate log if too large (keep last MAX_LOG_LINES)
        local line_count=$(wc -l < "$TECHNO_HAZE_LOG_FILE" 2>/dev/null || echo "0")
        if [[ $line_count -gt $MAX_LOG_LINES ]]; then
            tail -n $MAX_LOG_LINES "$TECHNO_HAZE_LOG_FILE" > "${TECHNO_HAZE_LOG_FILE}.tmp"
            mv "${TECHNO_HAZE_LOG_FILE}.tmp" "$TECHNO_HAZE_LOG_FILE"
        fi
    fi

    # Show notifications based on configuration
    show_notification "$level" "$message"
}

# Show notification based on user configuration
show_notification() {
    local level="$1"
    local message="$2"
    local notification_text="[TECHNO-HAZE $level] $message"

    case "$TECHNO_HAZE_NOTIFICATION_TYPE" in
        "off")
            # No notifications
            return 0
            ;;
        "tmux")
            # Tmux status line only
            tmux display-message "$notification_text" 2>/dev/null || true
            ;;
        "system")
            # System notification only
            send_system_notification "$level" "$message"
            ;;
        "both")
            # Both tmux and system
            tmux display-message "$notification_text" 2>/dev/null || true
            send_system_notification "$level" "$message"
            ;;
    esac
}

# Send system notification using available command
send_system_notification() {
    local level="$1"
    local message="$2"

    [[ -z "$TECHNO_HAZE_NOTIFICATION_COMMAND" ]] && return 0

    case "$TECHNO_HAZE_NOTIFICATION_COMMAND" in
        "notify-send")
            # Linux - works with dunst, notification-daemon, etc.
            local urgency="normal"
            [[ "$level" == "ERROR" ]] && urgency="critical"
            notify-send -u "$urgency" "Techno-Haze Tmux" "$message" 2>/dev/null || true
            ;;
        "osascript")
            # macOS
            osascript -e "display notification \"$message\" with title \"Techno-Haze Tmux\"" 2>/dev/null || true
            ;;
        *)
            # Custom command - user specified their own
            $TECHNO_HAZE_NOTIFICATION_COMMAND "$message" 2>/dev/null || true
            ;;
    esac
}

# Determine if a message should be logged based on log level
should_log() {
    local level="$1"
    local configured_level="$TECHNO_HAZE_LOG_LEVEL"

    # Map levels to numeric values
    case "$configured_level" in
        "none")     return 1 ;;  # Don't log anything
        "errors")   [[ "$level" == "ERROR" ]] ;;
        "warnings") [[ "$level" == "ERROR" || "$level" == "WARN" ]] ;;
        "all")      return 0 ;;  # Log everything
        *)          return 1 ;;  # Unknown level, don't log
    esac
}

# Convenience wrappers
log_error() { log_message "ERROR" "$1"; }
log_warn()  { log_message "WARN" "$1"; }
log_info()  { log_message "INFO" "$1"; }
log_debug() { log_message "DEBUG" "$1"; }
