class Nocake < Formula
  desc "Invisible macOS keyboard-lock deterrent (blocks typing on a hotkey)"
  homepage "https://github.com/Zappendusta/nocake"
  url "https://github.com/Zappendusta/nocake/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "18d66f35128dd59ba6c297e98f56fe46ebb27f83a0b7529af46ac28b4d216a52"
  license "MIT"
  head "https://github.com/Zappendusta/nocake.git", branch: "master"

  depends_on xcode: :build
  depends_on macos: :monterey

  def install
    # Build the single-file app from source (no notarization needed — the
    # user's own machine produces the binary identity).
    system "swiftc", "-O", "main.swift",
           "-framework", "AppKit", "-framework", "Carbon",
           "-o", "nocake"

    app = prefix/"NoCake.app"
    (app/"Contents/MacOS").mkpath
    cp "nocake", app/"Contents/MacOS/nocake"

    (app/"Contents/Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleName</key><string>NoCake</string>
        <key>CFBundleIdentifier</key><string>com.pdettmer.nocake</string>
        <key>CFBundleExecutable</key><string>nocake</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleShortVersionString</key><string>#{version}</string>
        <key>LSMinimumSystemVersion</key><string>12.0</string>
        <key>LSUIElement</key><true/>
      </dict>
      </plist>
    PLIST

    bin.install_symlink app/"Contents/MacOS/nocake" => "nocake"
  end

  service do
    run [opt_prefix/"NoCake.app/Contents/MacOS/nocake"]
    keep_alive true
    run_at_load true
  end

  def caveats
    <<~EOS
      NoCake intercepts keystrokes, so macOS needs TWO permissions. After
      installing, grant both to NoCake in System Settings -> Privacy & Security:
        - Accessibility
        - Input Monitoring

      Run it in the background (and start at login) with:
        brew services start nocake

      Arm/disarm with cmd+opt+ctrl+F10 (or cmd+opt+ctrl+Escape if F10 is a
      media key on your keyboard). Armed = all typing blocked + a popup.
      It auto-disarms after 5 minutes, and the mouse is never blocked, so you
      can always click to quit.

      NOTE: NoCake is built from source, so each `brew upgrade` produces a new
      binary identity. macOS will require you to re-grant Accessibility and
      Input Monitoring after every upgrade.
    EOS
  end

  test do
    assert_predicate prefix/"NoCake.app/Contents/MacOS/nocake", :executable?
    assert_path_exists prefix/"NoCake.app/Contents/Info.plist"
    system bin/"nocake", "--selftest"
  end
end
