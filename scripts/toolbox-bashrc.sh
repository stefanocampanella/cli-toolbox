# ============================================================================
# toolbox: modern CLI tools served from a single Apptainer/Singularity image
# Append this to ~/.bashrc
# ============================================================================

export TOOLBOX_SIF="${TOOLBOX_SIF:-$HOME/toolbox.sif}"
export TOOLBOX_INSTANCE="${TOOLBOX_INSTANCE:-toolbox}"

# --- 1. Ensure the background instance is running -------------------------
# `instance start` pays the squashfs-mount/namespace-setup cost ONCE. Every
# later `apptainer exec instance://...` (from this shell or any other one on
# the same node) reuses it, so completions/keybindings and one-off commands
# stay fast. Safe to source this file from many concurrent shells/tabs: the
# check below makes it a no-op if the instance is already up.
if ! apptainer instance list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$TOOLBOX_INSTANCE"; then
    apptainer instance start "$TOOLBOX_SIF" "$TOOLBOX_INSTANCE" >/dev/null 2>&1
fi

# --- 2. Generic dispatcher --------------------------------------------------
# Prefers the running instance (fast); falls back to a plain one-off exec
# if the instance failed to start or was stopped mid-session.
_tb() {
    if apptainer instance list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$TOOLBOX_INSTANCE"; then
        apptainer exec --bind "$PWD" "instance://$TOOLBOX_INSTANCE" "$@"
    else
        apptainer exec --bind "$PWD" "$TOOLBOX_SIF" "$@"
    fi
}

# --- 3. One shell function per tool ----------------------------------------
# Costs ZERO extra inodes (functions live only in the already-existing
# ~/.bashrc), unlike per-tool wrapper scripts or symlinks in ~/bin.
for _tb_tool in eza rg fd bat zoxide dust duf procs btm delta sd choose xh \
                hyperfine tokei lazygit broot tldr nvim \
                fzf; do
    eval "${_tb_tool}() { _tb ${_tb_tool} \"\$@\"; }"
done
unset _tb_tool

starship() {
    if [ "${1:-}" = "init" ]; then
        if [[ "$*" == *"--print-full-init"* ]]; then
            _tb starship "$@" | sed 's|/opt/bin/starship|starship|g'
        else
            _tb starship "$@" --print-full-init | sed 's|/opt/bin/starship|starship|g'
        fi
    else
        _tb starship "$@"
    fi
}

# --- 4. Key bindings & completion -------------------------------------------
# fzf's Ctrl-T / Ctrl-R / Alt-C, zoxide's `z`/`zi`, the starship prompt, and
# rg/fd completion were all generated and baked into the image at BUILD
# time (see toolbox.def). Sourcing them here is one exec call per new shell
# - no per-keystroke container overhead.
if apptainer instance list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$TOOLBOX_INSTANCE"; then
    source <(apptainer exec "instance://$TOOLBOX_INSTANCE" cat /opt/etc/shell-integration.bash)
else
    source <(apptainer exec "$TOOLBOX_SIF" cat /opt/etc/shell-integration.bash)
fi

# Optional: enable the starship prompt (defined by the sourced init above)
# eval "$(starship init bash)"   # already emitted directly if starship was
                                  # included in shell-integration.bash

# Optional: stop the instance when the LAST shell on this node exits.
# Left disabled by default (instances are cheap to leave running and
# restarting one is only a login-time cost) - uncomment if you'd rather
# clean up aggressively:
# trap 'apptainer instance stop "$TOOLBOX_INSTANCE" >/dev/null 2>&1' EXIT
