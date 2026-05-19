cask "senzingsdk-runtime-unofficial" do
  version "4.0.0"
  sha256 :no_check

  url "https://senzing.com"
  name "Senzing SDK Runtime (Unofficial) - DEPRECATED"
  desc "DEPRECATED - Use official tap: senzing/senzingsdk"
  homepage "https://github.com/Senzing/homebrew-senzingsdk"

  preflight do
    raise CaskError, <<~MSG

      ════════════════════════════════════════════════════════════
      THIS CASK HAS BEEN DEPRECATED
      ════════════════════════════════════════════════════════════

      The unofficial Senzing SDK tap is no longer maintained.
      An official Senzing Homebrew tap is now available.

      To migrate:

        1. Uninstall this cask:
             brew uninstall --cask senzingsdk-runtime-unofficial

        2. Remove this tap:
             brew untap brianmacy/senzingsdk-runtime-unofficial

        3. Install the official cask:
             brew install --cask senzing/senzingsdk/senzingsdk

      NOTE: The official cask has different environment variables:
        - EULA acceptance: HOMEBREW_SENZING_ACCEPT_EULA=i_accept_the_senzing_eula
        - Version override: HOMEBREW_SENZING_SDK_VERSION=x.x.x.xxxxx
        - Install path:    $(brew --prefix)/opt/senzing/er  (no "runtime/" prefix)

      Update your shell config (~/.zshrc or ~/.bash_profile):
        export SENZING_ROOT="$(brew --prefix)/opt/senzing/er"
        export DYLD_LIBRARY_PATH="${SENZING_ROOT}/lib:$DYLD_LIBRARY_PATH"
        export PATH="${SENZING_ROOT}/bin:$PATH"

      Official repo: https://github.com/Senzing/homebrew-senzingsdk

      ════════════════════════════════════════════════════════════
    MSG
  end

  caveats <<~EOS
    ════════════════════════════════════════════════════════════
    DEPRECATED — Use the official Senzing Homebrew tap instead:

      brew install --cask senzing/senzingsdk/senzingsdk

    See: https://github.com/Senzing/homebrew-senzingsdk
    ════════════════════════════════════════════════════════════
  EOS
end
