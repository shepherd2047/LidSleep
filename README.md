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
- **Password once, then never again**: first-run setup, no Terminal needed
- **Launch at Login** built in
- **No Dock icon**, no windows, no background daemons
- **~100 lines of Swift**, no dependencies, no Xcode project

## 📦 Download

Grab **LidSleep.dmg** from [Releases](https://github.com/shepherd2047/LidSleep/releases), open it and drag LidSleep into Applications.
Universal (Apple silicon + Intel), macOS 13 or later.

The app isn't notarized, so the first time macOS will refuse to open it.
Go to **System Settings → Privacy & Security** and click **Open Anyway**.

## 🛠 Build from source

You need the Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/shepherd2047/LidSleep.git
cd LidSleep
./build.sh
open ~/Applications/LidSleep.app
```

`build.sh` compiles `main.swift` for arm64 and x86_64, bundles it into `~/Applications/LidSleep.app` and ad-hoc signs it.
`./dmg.sh` builds the same app into `dist/LidSleep.dmg`.

## 🔑 First run

Changing power settings needs admin rights. On first launch LidSleep asks for your password **once** in the standard macOS dialog,
then installs a sudoers rule at `/etc/sudoers.d/pmset` that allows **only these two exact commands** without a password:

```
/usr/bin/pmset -a disablesleep 0
/usr/bin/pmset -a disablesleep 1
```

Any other `pmset` or `sudo` command still requires a password. Click **Not Now** to skip; LidSleep will ask again the first time you toggle.

## ⚙️ How it works

| Action | What runs |
| --- | --- |
| Read state | `pmset -g` → `SleepDisabled 0/1` |
| First-run setup | `visudo -c` then install the rule, via the admin password dialog |
| Toggle | `sudo -n pmset -a disablesleep 0/1` |
| Launch at Login | `SMAppService.mainApp` |

## ⚠️ Heads up

With sleep disabled, the screen turns off but **the Mac keeps running**.
Don't leave it on in a closed bag: it can get hot and drain the battery. The setting applies on both battery and AC power.

## 🧹 Uninstall

```bash
pkill -x LidSleep
rm -rf ~/Applications/LidSleep.app
sudo pmset -a disablesleep 0       # restore normal lid sleep
sudo rm -f /etc/sudoers.d/pmset    # remove the password rule
```

## 📄 License

[MIT](LICENSE)
