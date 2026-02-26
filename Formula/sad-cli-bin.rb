class SadCliBin < Formula
  desc "Search Apple Docs - Apple Developer Documentation CLI for AI agents (pre-built binary)"
  homepage "https://github.com/krodak/sad-cli"
  url "https://github.com/krodak/sad-cli/releases/download/v#{version}/sad-macos-universal.tar.gz"
  version "0.1.0"
  sha256 "b4a70e4feae1f847dd7890aef04dddb62c6cc63858fdf6b39ee671564eb885a7"
  license "MIT"

  depends_on :macos

  def install
    bin.install "sad"
  end

  test do
    assert_match "Search Apple Docs", shell_output("#{bin}/sad --help")
  end
end
