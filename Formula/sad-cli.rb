class SadCli < Formula
  desc "Search Apple Docs - Apple Developer Documentation CLI for AI agents"
  homepage "https://github.com/krodak/sad-cli"
  url "https://github.com/krodak/sad-cli/archive/refs/tags/v#{version}.tar.gz"
  version "0.1.0"
  sha256 "53f7e2861adee02a43ef0d76bfeb0d7908bb4524d5179165b4b269e2b33726a9"
  license "MIT"

  depends_on xcode: ["16.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/sad"
  end

  test do
    assert_match "Search Apple Docs", shell_output("#{bin}/sad --help")
  end
end
