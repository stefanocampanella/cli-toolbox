# CLI Toolbox

A modern CLI tool replacement suite packed into a single Apptainer/Singularity image (`.sif`).

> [!NOTE]
> This repository was generated with AI assistance and minimal human supervision.
>
> **Primary Goal**: Rapidly provide a ready-to-use development environment on HPC clusters without requiring manual software compilation or polluting `$HOME` with excessive files (mitigating strict inode quotas, such as on JSC JUPITER).

## Overview

On HPC clusters and shared systems, `$HOME` often has strict inode quotas. Installing dozens of tools natively (via `cargo install`, per-tool `~/.local/bin`, shared libraries, etc.) can consume tens of thousands of inodes.

This project packages ~20 modern CLI tools into a single container image. Regardless of the number of utilities inside, it consumes only a **single inode** on the filesystem.

### Included Tools

| Category | Tools |
|---|---|
| **Core Replacements** | `eza` (ls), `ripgrep` / `rg` (grep), `fd` (find), `bat` (cat), `zoxide` (cd) |
| **System & Disk** | `dust` (du), `duf` (df), `procs` (ps), `bottom` / `btm` (top/htop) |
| **Text & Utilities** | `delta` (diff/pager), `sd` (sed), `choose` (cut/awk), `xh` (curl/httpie) |
| **Terminal & Workflow** | `neovim` / `nvim`, `lazygit`, `broot`, `tldr`, `fzf` |
| **Productivity & Dev** | `hyperfine` (benchmarking), `tokei` (code stats) |

## Repository Structure

```text
├── .github/
│   └── workflows/
│       └── apptainer-build-deploy.yml   # CI/CD workflow for building and publishing images
├── recipes/
│   ├── toolbox.def                     # Apptainer definition file (x86_64 / amd64)
│   └── toolbox-arm64.def               # Apptainer definition file (aarch64 / arm64)
├── scripts/
│   ├── toolbox-bashrc.sh               # Shell integration snippet for ~/.bashrc
│   └── toolbox-install.sh              # Installer script to append integration to ~/.bashrc
└── README.md
```

## Installation & Setup

### 1. Build or Download the Container Image

Build with Apptainer (from the repository root):

```bash
# x86_64
apptainer build --fakeroot toolbox.sif recipes/toolbox.def

# ARM64 (on an aarch64 host)
apptainer build --fakeroot toolbox-arm64.sif recipes/toolbox-arm64.def
```

Or download the pre-built image from GitHub Container Registry (GHCR).

### 2. Install Shell Integration

Run the built-in install command to append the configuration snippet to `~/.bashrc`:

```bash
apptainer run --app install toolbox.sif
```

Alternatively, you can run:

```bash
apptainer run toolbox.sif install
# or
apptainer exec toolbox.sif toolbox-install
```

After installation, reload your shell:

```bash
source ~/.bashrc
```

## Usage

Once installed into your `~/.bashrc`:
- The background Apptainer instance is automatically started once per login session.
- All CLI utilities (`rg`, `fd`, `bat`, `eza`, `lazygit`, `nvim`, etc.) are available directly in your shell with zero overhead.
- Completions and keybindings (`fzf` Ctrl-R / Ctrl-T, `zoxide`) are automatically loaded.
