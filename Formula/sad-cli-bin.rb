class SadCliBin < Formula
  desc "Search Apple Docs - Apple Developer Documentation CLI for AI agents (pre-built binary)"
  homepage "https://github.com/krodak/sad-cli"
  url "https://github.com/krodak/sad-cli/releases/download/v#{version}/sad-macos-universal.tar.gz"
  version "0.1.1"
  sha256 "PLACEHOLDER"
  license "MIT"

  depends_on :macos

  def install
    bin.install "sad"
  end

  test do
    assert_match "Search Apple Docs", shell_output("#{bin}/sad --help")
  end
end
