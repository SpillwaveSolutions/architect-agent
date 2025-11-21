#!/usr/bin/env bash
# OpenCode Shell Initialization
# Auto-loaded when OpenCode starts a shell session
# Provides automatic wrapper aliases for common commands

# Only initialize if running under OpenCode (not Claude Code)
if [ -n "$OPENCODE" ] || [ -n "$OPENCODE_SESSION" ] || [ -n "$OPENCODE_PORT" ]; then
    echo "[OpenCode] Loading wrapper aliases for automated logging..."

    # Path to wrapper script (relative to project root)
    WRAPPER_PATH="./debugging/wrapper-scripts/run-with-logging.sh"
    export WRAPPER_PATH

    # Verify wrapper exists
    if [ ! -f "$WRAPPER_PATH" ]; then
        echo "[OpenCode] Warning: Wrapper script not found at $WRAPPER_PATH"
        return 1
    fi

    # Common build tools (using functions instead of aliases for non-interactive shell compatibility)
    gradle() { "$WRAPPER_PATH" gradle "$@"; }
    gradlew() { "$WRAPPER_PATH" ./gradlew "$@"; }
    task() { "$WRAPPER_PATH" task "$@"; }
    npm() { "$WRAPPER_PATH" npm "$@"; }
    yarn() { "$WRAPPER_PATH" yarn "$@"; }
    mvn() { "$WRAPPER_PATH" mvn "$@"; }
    make() { "$WRAPPER_PATH" make "$@"; }

    # Common Git commands
    git() { "$WRAPPER_PATH" git "$@"; }

    # Common file operations (be careful with these)
    ls() { "$WRAPPER_PATH" ls "$@"; }
    cat() { "$WRAPPER_PATH" cat "$@"; }
    grep() { "$WRAPPER_PATH" grep "$@"; }
    find() { "$WRAPPER_PATH" find "$@"; }

    # Testing commands
    pytest() { "$WRAPPER_PATH" pytest "$@"; }
    jest() { "$WRAPPER_PATH" jest "$@"; }

    # Docker commands
    docker() { "$WRAPPER_PATH" docker "$@"; }
    # Note: docker-compose has hyphen, can't be a function name - use alias instead
    alias docker-compose="$WRAPPER_PATH docker-compose"

    # Kubernetes commands
    kubectl() { "$WRAPPER_PATH" kubectl "$@"; }
    helm() { "$WRAPPER_PATH" helm "$@"; }

    # Export functions so they're available in subshells
    export -f gradle gradlew task npm yarn mvn make git ls cat grep find pytest jest docker kubectl helm

    echo "[OpenCode] Wrapper functions loaded. All commands will auto-log."
    echo "[OpenCode] To bypass wrapper: command <cmd> (e.g., command gradle build)"
fi
