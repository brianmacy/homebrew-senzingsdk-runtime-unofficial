# DEPRECATED — Use the Official Senzing Homebrew Tap

> **This tap is no longer maintained.** Senzing now provides an official Homebrew tap at [Senzing/homebrew-senzingsdk](https://github.com/Senzing/homebrew-senzingsdk).

## Migration

### 1. Uninstall the unofficial cask

```bash
brew uninstall --cask senzingsdk-runtime-unofficial
brew untap brianmacy/senzingsdk-runtime-unofficial
```

### 2. Install the official cask

```bash
brew install --cask senzing/senzingsdk/senzingsdk
```

To accept the EULA non-interactively:

```bash
HOMEBREW_SENZING_ACCEPT_EULA=i_accept_the_senzing_eula brew install --cask senzing/senzingsdk/senzingsdk
```

### 3. Update your shell configuration

The official cask installs to a **different path** — there is no longer a `runtime/` subdirectory.

Update `~/.zshrc` or `~/.bash_profile`:

```bash
export SENZING_ROOT="$(brew --prefix)/opt/senzing/er"
export DYLD_LIBRARY_PATH="${SENZING_ROOT}/lib:$DYLD_LIBRARY_PATH"
export PATH="${SENZING_ROOT}/bin:$PATH"
```

Or source the setup script:

```bash
source "$(brew --prefix)/opt/senzing/er/setupEnv"
```

### Key differences from the unofficial cask

| | Unofficial (this repo) | Official |
|---|---|---|
| Tap | `brianmacy/senzingsdk-runtime-unofficial` | `senzing/senzingsdk` |
| Cask name | `senzingsdk-runtime-unofficial` | `senzingsdk` |
| Install path | `$(brew --prefix)/opt/senzing/runtime/er` | `$(brew --prefix)/opt/senzing/er` |
| EULA env var | `HOMEBREW_SENZING_EULA_ACCEPTED=yes` | `HOMEBREW_SENZING_ACCEPT_EULA=i_accept_the_senzing_eula` |
| Version env var | `HOMEBREW_SENZING_VERSION` | `HOMEBREW_SENZING_SDK_VERSION` |

## Links

- [Official Senzing Homebrew Tap](https://github.com/Senzing/homebrew-senzingsdk)
- [Senzing Homepage](https://senzing.com)
- [Senzing Documentation](https://docs.senzing.com)
- [Senzing EULA](https://senzing.com/end-user-license-agreement/)

## License

MIT — see [LICENSE](LICENSE).
