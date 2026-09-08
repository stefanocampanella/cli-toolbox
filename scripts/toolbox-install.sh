#!/usr/bin/env bash
# ============================================================================
# toolbox-install: Appends toolbox shell integration into ~/.bashrc
# ============================================================================
set -euo pipefail

TARGET_BASHRC="${1:-$HOME/.bashrc}"
SNIPPET_FILE="/opt/etc/toolbox-bashrc.sh"

if [ ! -f "$SNIPPET_FILE" ]; then
    # Fallback if running directly from the repository
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$SCRIPT_DIR/toolbox-bashrc.sh" ]; then
        SNIPPET_FILE="$SCRIPT_DIR/toolbox-bashrc.sh"
    else
        echo "ERROR: Toolbox snippet file could not be found." >&2
        exit 1
    fi
fi

# Configure ~/.bashrc
if [ -f "$TARGET_BASHRC" ] && grep -q "TOOLBOX_INSTANCE=" "$TARGET_BASHRC"; then
    echo "Toolbox is already configured in $TARGET_BASHRC."
else
    mkdir -p "$(dirname "$TARGET_BASHRC")"
    touch "$TARGET_BASHRC"
    echo "" >> "$TARGET_BASHRC"
    cat "$SNIPPET_FILE" >> "$TARGET_BASHRC"
    echo "Successfully appended toolbox configuration to $TARGET_BASHRC."
fi

echo "Run 'source $TARGET_BASHRC' or start a new terminal session to use the toolbox."
