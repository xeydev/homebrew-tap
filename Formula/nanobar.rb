class Nanobar < Formula
  desc "Minimal macOS status bar companion for AeroSpace"
  homepage "https://github.com/xeydev/nanobar"
  url "https://github.com/xeydev/nanobar/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "c68b79bb80b96a6f0c4d1c9734b95d333d083db2387a28721c5cf8e4472a6ee7"
  license "MIT"
  head "https://github.com/xeydev/nanobar.git", branch: "main"

  # Sources adopt the macOS 26 (liquid glass) SDK APIs behind availability
  # guards, so building needs the macOS 26 SDK even on Sequoia.
  depends_on xcode: ["26.0", :build]
  depends_on macos: :sequoia

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/NanoBar" => "nanobar"
  end

  service do
    run opt_bin/"nanobar"
    keep_alive true
    run_at_load true
    log_path "/tmp/nanobar.log"
    error_log_path "/tmp/nanobar.err"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Config: ~/.config/nanobar/config (created on first run if absent)

      Start:  brew services start nanobar
      Stop:   brew services stop nanobar
      Logs:   tail -f /tmp/nanobar.log
    EOS
  end

  test do
    assert_predicate bin/"nanobar", :executable?
  end
end
