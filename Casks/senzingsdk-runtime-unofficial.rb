cask "senzingsdk-runtime-unofficial" do
  # EULA acceptance check - only prompt during install, not uninstall/info/etc
  eula_accepted_file = "/tmp/.senzing_eula_accepted_#{Process.ppid}"
  # Walk up process tree to find brew command
  ancestor_cmds = []
  ancestor_pid = Process.pid
  5.times do
    cmd = `ps -o args= -p #{ancestor_pid} 2>/dev/null`.strip
    break if cmd.empty?

    ancestor_cmds << cmd
    ancestor_pid = `ps -o ppid= -p #{ancestor_pid} 2>/dev/null`.strip.to_i
    break if ancestor_pid <= 1
  end
  pstree = ancestor_cmds.join(" ")
  is_install = pstree.include?("install") && pstree.exclude?("uninstall") && pstree.exclude?("reinstall")
  eula_needed = is_install &&
                ENV["HOMEBREW_SENZING_EULA_ACCEPTED"]&.downcase != "yes" &&
                !File.exist?(eula_accepted_file)
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

    File.write(eula_accepted_file, "accepted")
    at_exit do
      File.delete(eula_accepted_file)
    rescue
      nil
    end
  end

  # S3 URL - use HOMEBREW_SENZING_S3_URL to override (Homebrew passes HOMEBREW_* env vars)
  # Strip trailing slash to avoid double-slash in URL
  s3_base_url = ENV.fetch("HOMEBREW_SENZING_S3_URL", "https://senzing-production-osx.s3.amazonaws.com").chomp("/")

  # Dynamically fetch latest version from S3, or use HOMEBREW_SENZING_VERSION env var
  latest_version = ENV.fetch("HOMEBREW_SENZING_VERSION") do
    listing = `curl -s #{s3_base_url}`.strip
    versions = listing.scan(/senzingsdk_(\d+\.\d+\.\d+\.\d+)\.dmg/).flatten.uniq
    versions.max_by { |v| Gem::Version.new(v) }
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

  artifact "senzing", target: "#{HOMEBREW_PREFIX}/opt/senzing/runtime"

  uninstall script: {
    executable: "/bin/rm",
    args:       ["-rf", "#{HOMEBREW_PREFIX}/opt/senzing/runtime"],
  }

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
