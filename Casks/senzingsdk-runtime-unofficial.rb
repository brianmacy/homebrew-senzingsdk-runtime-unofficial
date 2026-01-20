cask "senzingsdk-runtime-unofficial" do
  # S3 URL - use HOMEBREW_SENZING_S3_URL to override (Homebrew passes HOMEBREW_* env vars)
  # Strip trailing slash to avoid double-slash in URL
  s3_base_url = ENV.fetch("HOMEBREW_SENZING_S3_URL", "https://senzing-production-osx.s3.amazonaws.com").chomp("/")

  # Version determination: explicit version, or read from marker file, or query S3
  homebrew_prefix = ENV.fetch("HOMEBREW_PREFIX", "/opt/homebrew")
  version_marker_file = "#{homebrew_prefix}/opt/senzing/.installed_version"

  latest_version = ENV.fetch("HOMEBREW_SENZING_VERSION") do
    # If already installed, return the installed version to prevent upgrade conflicts
    # Users must use 'brew reinstall' to upgrade to a newer version
    if File.exist?(version_marker_file)
      File.read(version_marker_file).strip
    else
      # Fresh install - query S3 for latest
      listing = `curl -s #{s3_base_url}`.strip
      versions = listing.scan(/senzingsdk_(\d+\.\d+\.\d+\.\d+)\.dmg/).flatten.uniq
      versions.max_by { |v| Gem::Version.new(v) }
    end
  end

  version latest_version
  # No SHA256 - binaries are code-signed and downloaded directly from Senzing's S3
  sha256 :no_check

  url "#{s3_base_url}/senzingsdk_#{version}.dmg"
  name "Senzing SDK Runtime (Unofficial)"
  desc "Entity Resolution Engine SDK"
  homepage "https://senzing.com/"

  # Livecheck always uses production - for staging tests use HOMEBREW_SENZING_VERSION
  livecheck do
    url "https://senzing-production-osx.s3.amazonaws.com/"
    strategy :page_match do |page|
      page.scan(/senzingsdk[_-](\d+(?:\.\d+)+)\.dmg/i)
          .flatten
          .uniq
          .max_by { |v| Gem::Version.new(v.tr("_", ".")) }
    end
  end

  depends_on macos: ">= :ventura"
  depends_on arch: :arm64
  depends_on formula: "openssl@3"
  depends_on formula: "sqlite"

  # EULA check and upgrade handling in preflight
  preflight do
    # Use ENV["HOMEBREW_PREFIX"] or fallback to standard locations
    homebrew_prefix = ENV.fetch("HOMEBREW_PREFIX", "/opt/homebrew")
    caskroom_path = "#{homebrew_prefix}/Caskroom/senzingsdk-runtime-unofficial"
    s3_marker_file = "#{homebrew_prefix}/opt/senzing/.s3_source"
    version_marker_file = "#{homebrew_prefix}/opt/senzing/.installed_version"

    already_installed = Dir.exist?(caskroom_path) && Dir.children(caskroom_path).any? { |f| f != ".metadata" }

    # Check if S3 URL has changed - if so, this is effectively a fresh install from new source
    s3_url_changed = false
    if File.exist?(s3_marker_file)
      previous_s3_url = File.read(s3_marker_file).strip
      current_s3_url = ENV.fetch("HOMEBREW_SENZING_S3_URL", "https://senzing-production-osx.s3.amazonaws.com").chomp("/")
      s3_url_changed = previous_s3_url != current_s3_url
    end

    # Prompt for EULA if: not already installed OR S3 URL changed (new source = new EULA acceptance needed)
    eula_accepted = ENV["HOMEBREW_SENZING_EULA_ACCEPTED"]&.downcase == "yes"
    eula_needed = (!already_installed || s3_url_changed) && !eula_accepted

    if eula_needed
      $stderr.puts <<~MSG
        ========================================
        SENZING END USER LICENSE AGREEMENT
        ========================================
        You must accept the Senzing EULA to install this software.

        Review the EULA at:
          https://senzing.com/end-user-license-agreement/

        ========================================
      MSG
      $stderr.print "Do you accept the Senzing EULA? Type 'yes' to accept: "
      response = $stdin.gets&.strip&.downcase
      raise CaskError, "EULA not accepted. Installation aborted." if response != "yes"
    end
  end

  # Track S3 source and installed version in postflight for future installs
  postflight do
    homebrew_prefix = ENV.fetch("HOMEBREW_PREFIX", "/opt/homebrew")
    marker_dir = "#{homebrew_prefix}/opt/senzing"
    s3_marker_file = "#{marker_dir}/.s3_source"
    version_marker_file = "#{marker_dir}/.installed_version"

    s3_url = ENV.fetch("HOMEBREW_SENZING_S3_URL", "https://senzing-production-osx.s3.amazonaws.com").chomp("/")

    FileUtils.mkdir_p(marker_dir)
    File.write(s3_marker_file, s3_url)
    File.write(version_marker_file, version)
  end

  artifact "senzing", target: "#{HOMEBREW_PREFIX}/opt/senzing/runtime"

  # Note: No explicit uninstall script needed - Homebrew's artifact handling
  # automatically removes the installed directory during uninstall/upgrade

  zap trash: [
    "~/Library/Caches/Senzing",
    "~/Library/Logs/Senzing",
    "~/Library/Preferences/com.senzing.*",
  ]

  caveats <<~EOS
    The Senzing SDK Runtime has been installed to:
      #{HOMEBREW_PREFIX}/opt/senzing/runtime

    Add these to your shell configuration (~/.zshrc or ~/.bash_profile):

      export SENZING_ROOT="#{HOMEBREW_PREFIX}/opt/senzing/runtime/er"
      export DYLD_LIBRARY_PATH="${SENZING_ROOT}/lib:$DYLD_LIBRARY_PATH"
      export PATH="${SENZING_ROOT}/bin:$PATH"

    Or source the provided setup script:
      source "#{HOMEBREW_PREFIX}/opt/senzing/runtime/er/setupEnv"

    NOTE: This is an unofficial community package.
  EOS
end
