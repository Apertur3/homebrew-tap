class Headroom < Formula
  desc "Live quota, resets and pace states for every AI subscription and account"
  homepage "https://github.com/Apertur3/headroom"
  url "https://registry.npmjs.org/headroomd/-/headroomd-0.2.2.tgz"
  version "0.2.2"
  sha256 "45c193c2850da38ce696c2b80edf6359b93db7848af7cec0e90f87943ed66c92"
  license "MIT"

  depends_on "node"

  # Homebrew repacks the staged package with "npm pack --ignore-scripts", so the
  # package's own prepack hook never runs here and nothing reads the macOS
  # Keychain during installation. The published tarball already carries the
  # compiled JavaScript, Claude probe and Antigravity native reader. Installation
  # needs no compiler; the native binaries are only used on macOS.
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

      On macOS you can check that the Claude credential is readable.
      No Keychain dialog is involved:

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
