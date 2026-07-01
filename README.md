# homebrew-nocake

Homebrew tap for [NoCake](https://github.com/Zappendusta/nocake) — an invisible
macOS keyboard-lock deterrent.

```bash
brew install Zappendusta/nocake/nocake
brew services start nocake      # run in background, start at login
```

Then grant **Accessibility** and **Input Monitoring** to NoCake in
System Settings → Privacy & Security.

Built from source (no notarization). Each `brew upgrade` produces a new binary
identity, so macOS will ask you to re-grant both permissions after upgrading.
