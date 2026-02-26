class AppleDocsCliBin < Formula
  desc "Lightweight Apple Developer Documentation CLI for AI agents (pre-built binary)"
  homepage "https://github.com/krodak/apple-docs-cli"
  url "https://github.com/krodak/apple-docs-cli/releases/download/v#{version}/ad-macos-universal.tar.gz"
  version "0.1.0"
  sha256 "PLACEHOLDER"
  license "MIT"

  depends_on :macos

  def install
    bin.install "ad"
  end

  test do
    assert_match "Apple Developer Documentation CLI", shell_output("#{bin}/ad --help")
  end
end
