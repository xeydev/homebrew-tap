class Nanobar < Formula
  desc "Minimal macOS status bar app powered by SwiftUI plugins"
  homepage "https://github.com/xeydev/nanobar"
  version "0.2.0"
  sha256 "9a7ebca2df9373e683be9331f2e188edf32e2a9fd9553928391edb546db81efa"
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
