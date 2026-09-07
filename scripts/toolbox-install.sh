#!/usr/bin/env bash
# ============================================================================
# toolbox-install: Appends toolbox shell integration into ~/.bashrc
#                  and configures Zellij to load the default login shell.
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

# 1. Configure ~/.bashrc
if [ -f "$TARGET_BASHRC" ] && grep -q "TOOLBOX_INSTANCE=" "$TARGET_BASHRC"; then
    echo "Toolbox is already configured in $TARGET_BASHRC."
else
    mkdir -p "$(dirname "$TARGET_BASHRC")"
    touch "$TARGET_BASHRC"
    echo "" >> "$TARGET_BASHRC"
    cat "$SNIPPET_FILE" >> "$TARGET_BASHRC"
    echo "Successfully appended toolbox configuration to $TARGET_BASHRC."
fi

# 2. Configure Zellij default layout to start login shell
ZELLIJ_CONFIG_DIR="${ZELLIJ_CONFIG_DIR:-$HOME/.config/zellij}"
ZELLIJ_LAYOUT_DIR="$ZELLIJ_CONFIG_DIR/layouts"
ZELLIJ_DEFAULT_LAYOUT="$ZELLIJ_LAYOUT_DIR/default.kdl"

mkdir -p "$ZELLIJ_LAYOUT_DIR"
if [ ! -f "$ZELLIJ_DEFAULT_LAYOUT" ] || grep -q "new_tab_template" "$ZELLIJ_DEFAULT_LAYOUT" 2>/dev/null; then
    cat << 'EOF' > "$ZELLIJ_DEFAULT_LAYOUT"
layout {
    default_tab_template {
        pane size=1 borderless=true {
            plugin location="tab-bar"
        }
        children
        pane size=1 borderless=true {
            plugin location="status-bar"
        }
    }
    tab {
        pane command="bash" {
            args "--login"
        }
    }
}
EOF
    echo "Configured Zellij default layout in $ZELLIJ_DEFAULT_LAYOUT (loads login shell with tab and status bars)."
else
    echo "Zellij default layout already exists at $ZELLIJ_DEFAULT_LAYOUT (left unmodified)."
fi

echo "Run 'source $TARGET_BASHRC' or start a new terminal session to use the toolbox."
