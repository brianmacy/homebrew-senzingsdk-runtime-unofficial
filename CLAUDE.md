# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Unofficial Homebrew Cask tap for the Senzing SDK v4 runtime on macOS. Downloads directly from Senzing's S3 bucket - no binary redistribution. **ARM64 (Apple Silicon) only.**

## Repository Structure

```
homebrew-senzingsdk-runtime-unofficial/
├── Casks/
│   └── senzingsdk-runtime-unofficial.rb   # Cask formula
├── .github/workflows/
│   └── cask-audit.yml                     # CI for cask validation
├── README.md
├── LICENSE (MIT)
└── CLAUDE.md
```

## S3 Bucket

- **Production URL**: `https://senzing-production-osx.s3.amazonaws.com/`
- **DMG pattern**: `senzingsdk_VERSION.BUILD.dmg` (e.g., `senzingsdk_4.2.1.26015.dmg`)
- Only v4 SDK files (senzingsdk_*) are supported, not v3 API files (senzingapi_*)

## Version Management

Version is detected **automatically** from S3 - no code changes needed for new releases.

List available versions:
```bash
curl -s https://senzing-production-osx.s3.amazonaws.com/ | grep -oE 'senzingsdk_[0-9.]+\.dmg' | sed 's/senzingsdk_//;s/\.dmg//' | sort -V | uniq
```

Install specific version:
```bash
SENZING_VERSION=4.1.0.25279 brew install --cask senzingsdk-runtime-unofficial
```

## EULA Acceptance

The cask prompts for EULA acceptance interactively, or skip with environment variable:
```bash
SENZING_EULA_ACCEPTED=yes brew install --cask senzingsdk-runtime-unofficial
```

## Dependencies

- `openssl@3`
- `sqlite`

## Development Commands

```bash
# Check style
brew style Casks/senzingsdk-runtime-unofficial.rb

# Test install (requires EULA acceptance)
SENZING_EULA_ACCEPTED=yes brew install --cask senzingsdk-runtime-unofficial

# Uninstall
brew uninstall --cask senzingsdk-runtime-unofficial
```

## Installation Target

The cask installs to `$(brew --prefix)/opt/senzing/runtime/` with structure:
- `opt/senzing/runtime/data/` - data files
- `opt/senzing/runtime/er/` - SDK (bin, lib, etc, sdk, resources)

The postflight script adds rpath entries to dylibs in the lib directory.
