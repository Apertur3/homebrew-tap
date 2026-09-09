class Headroom < Formula
  desc "Live quota, resets and pace states for every AI subscription and account"
  homepage "https://github.com/Apertur3/headroom"
  url "https://registry.npmjs.org/headroomd/-/headroomd-0.1.0-beta.17.tgz"
  version "0.1.0-beta.17"
  sha256 "f2951463c77c180937d13c5bb504437baccc27805426974c3ce974e659468d16"
  license "MIT"

  depends_on "node"

  # Homebrew repacks the staged package with "npm pack --ignore-scripts", so the
  # package's own prepack hook never runs here and nothing reads the macOS
  # Keychain during installation. The published tarball already carries the
  # compiled JavaScript and the prebuilt Claude probe, which makes this a plain
  # file install on both macOS and Linux; the probe is only ever used on macOS.
  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
    (var/"log/headroom").mkpath
  end

  def caveats
    <<~EOS
      Headroom reads the accounts you already own. One setup pass first:

        headroom accounts discover
        headroom doctor
        brew services start headroom

      On macOS the first read of the Claude Code token asks for Keychain access
      once, and only once:

        headroom keychain grant
    EOS
  end

  service do
    run [opt_bin/"headroom", "daemon"]
    keep_alive true
    log_path var/"log/headroom/headroom.log"
    error_log_path var/"log/headroom/headroom.error.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/headroom version")
  end
end
