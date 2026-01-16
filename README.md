# Homebrew Tap for Senzing SDK Runtime (Unofficial)

Unofficial Homebrew tap for the Senzing Entity Resolution Engine SDK on macOS.

> **Note**: This is a community-maintained package, not officially supported by Senzing.

## Requirements

- macOS 13 (Ventura) or later
- Apple Silicon (ARM64)
- Dependencies (installed automatically): `openssl@3`, `sqlite`

## Installation

### Add the Tap

```bash
brew tap brianmacy/senzingsdk-runtime-unofficial
```

### Install the SDK

You must accept the [Senzing EULA](https://senzing.com/end-user-license-agreement/) to install:

```bash
brew install --cask senzingsdk-runtime-unofficial
```

Or as a one-liner (without tapping first):

```bash
brew install --cask brianmacy/senzingsdk-runtime-unofficial/senzingsdk-runtime-unofficial
```

To skip the interactive EULA prompt:

```bash
HOMEBREW_SENZING_EULA_ACCEPTED=yes brew install --cask senzingsdk-runtime-unofficial
```

### Install a Specific Version

By default, the latest version is installed. To install a specific version:

```bash
HOMEBREW_SENZING_VERSION=4.1.0.25279 brew install --cask senzingsdk-runtime-unofficial
```

## Setup

After installation, add to your `~/.zshrc` or `~/.bash_profile`:

```bash
export SENZING_ROOT="$(brew --prefix)/opt/senzing/runtime/er"
export DYLD_LIBRARY_PATH="${SENZING_ROOT}/lib:$DYLD_LIBRARY_PATH"
export PATH="${SENZING_ROOT}/bin:$PATH"
```

Or source the setup script:

```bash
source "$(brew --prefix)/opt/senzing/runtime/er/setupEnv"
```

## Uninstall

```bash
brew uninstall --cask senzingsdk-runtime-unofficial
```

To remove all Senzing data:

```bash
brew uninstall --zap --cask senzingsdk-runtime-unofficial
```

## License

By installing this SDK, you accept the [Senzing End User License Agreement](https://senzing.com/end-user-license-agreement/).

## Links

- [Senzing Homepage](https://senzing.com)
- [Senzing Documentation](https://docs.senzing.com)
