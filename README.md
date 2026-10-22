<div align="center">

# ☕️ LidSleep

**Keep your Mac awake with the lid closed — one click from the menu bar.**

![macOS](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-single%20file-F05138?logo=swift&logoColor=white)
![Size](https://img.shields.io/badge/deps-zero-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

English · [简体中文](README.zh-CN.md)

</div>

---

Close the lid, keep the downloads running, the build compiling, the music playing.
LidSleep is a tiny menu bar app that flips macOS's `pmset disablesleep` switch, so you don't have to open Terminal every time.

| Icon | Meaning |
| :---: | --- |
| ☕️ `cup.and.saucer.fill` | **Stays awake** when the lid is closed |
| 🌙 `moon.zzz` | Normal behavior: **sleeps** when the lid is closed |

## ✨ Features

- **One click** toggle from the menu bar, with a checkmark showing the current state
- **No password prompts** once you add a one-line sudoers rule (optional)
- **Launch at Login** built in
- **No Dock icon**, no windows, no background daemons
- **~80 lines of Swift**, no dependencies, no Xcode project

## 🚀 Install

You need the Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/shepherd2047/LidSleep.git
cd LidSleep
./build.sh
open ~/Applications/LidSleep.app
```

`build.sh` compiles `main.swift`, bundles it into `~/Applications/LidSleep.app` and ad-hoc signs it.

## 🔑 Skip the password (optional)

Changing power settings needs admin rights, so by default macOS asks for your password on every toggle.
To allow **only these two exact commands** without a password:

```bash
echo "$(whoami) ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1" \
  | sudo tee /etc/sudoers.d/pmset >/dev/null && sudo chmod 440 /etc/sudoers.d/pmset && sudo visudo -c
```

You should see `/etc/sudoers.d/pmset: parsed OK`. Any other `pmset` or `sudo` command still requires a password.
To undo it: `sudo rm /etc/sudoers.d/pmset`.

## ⚙️ How it works

| Action | What runs |
| --- | --- |
| Read state | `pmset -g` → `SleepDisabled 0/1` |
| Toggle | `sudo -n pmset -a disablesleep 0/1`, falling back to the standard admin password dialog |
| Launch at Login | `SMAppService.mainApp` |

## ⚠️ Heads up

With sleep disabled, the screen turns off but **the Mac keeps running**.
Don't leave it on in a closed bag: it can get hot and drain the battery. The setting applies on both battery and AC power.

## 🧹 Uninstall

```bash
pkill -x LidSleep
rm -rf ~/Applications/LidSleep.app
sudo pmset -a disablesleep 0       # restore normal lid sleep
sudo rm -f /etc/sudoers.d/pmset    # if you added the rule
```

## 📄 License

[MIT](LICENSE)
