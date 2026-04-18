class Nanobar < Formula
  desc "Minimal macOS status bar app powered by SwiftUI plugins"
  homepage "https://github.com/xeydev/nanobar"
  version "0.1.3"
  sha256 "861887e034d0f4fbaae30d07781eb5d9f80b79d5a34a5bb5666a5e1c0726e274"
  url "https://github.com/xeydev/nanobar/releases/download/v#{version}/nanobar-#{version}-arm64.tar.gz"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  def install
    libexec.install "libexec/NanoBar"
    libexec.install "libexec/NowPlayingHelper"
    libexec.install "libexec/libNanoBarPluginAPI.dylib"
    (libexec/"Plugins").mkpath
    Dir["libexec/Plugins/*.bundle"].each do |bundle|
      (libexec/"Plugins").install bundle
    end
    (bin/"nanobar").write_env_script libexec/"NanoBar", {}
  end

  service do
    run opt_libexec/"NanoBar"
    keep_alive true
    log_path "/tmp/nanobar.log"
    error_log_path "/tmp/nanobar.err"
    run_at_load true
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Config: ~/.config/nanobar/config.toml (created on first run if absent)

      Start:  brew services start nanobar
      Stop:   brew services stop nanobar
      Logs:   tail -f /tmp/nanobar.log
    EOS
  end

  test do
    assert_predicate libexec/"NanoBar", :executable?
    assert_predicate libexec/"NowPlayingHelper", :executable?
    assert_predicate libexec/"Plugins", :directory?
  end
end
