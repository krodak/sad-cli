class SadCli < Formula
  desc "Search Apple Docs - Apple Developer Documentation CLI for AI agents"
  homepage "https://github.com/krodak/sad-cli"
  url "https://github.com/krodak/sad-cli/archive/refs/tags/v#{version}.tar.gz"
  version "0.1.1"
  sha256 "74dc877708ac31b266552e3f07b44cd8a685d4b88267c12fb7b1f26ec4184cce"
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
