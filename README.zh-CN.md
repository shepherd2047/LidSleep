<div align="center">

# ☕️ LidSleep

**合上盖子，Mac 照样醒着。在菜单栏一键切换。**

![macOS](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-single%20file-F05138?logo=swift&logoColor=white)
![Size](https://img.shields.io/badge/deps-zero-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

[English](README.md) · 简体中文

</div>

---

合上盖子，下载继续跑、编译继续编、音乐继续放。
LidSleep 是一个很小的菜单栏应用，帮你切换 macOS 的 `pmset disablesleep`，不用每次都开终端。

| 图标 | 含义 |
| :---: | --- |
| ☕️ `cup.and.saucer.fill` | 合盖**不休眠** |
| 🌙 `moon.zzz` | 正常：合盖**会休眠** |

## ✨ 功能

- 菜单栏**一键切换**，勾选标记显示当前状态
- **只输一次密码**：首次运行自动设置，不用碰终端
- 内置**开机启动**
- **没有 Dock 图标**、没有窗口、没有后台守护进程
- **约 100 行 Swift**，零依赖，不需要 Xcode 工程

## 📦 下载

到 [Releases](https://github.com/shepherd2047/LidSleep/releases) 下载 **LidSleep.dmg**，打开后把 LidSleep 拖进“应用程序”。
通用版（Apple 芯片 + Intel），需要 macOS 13 及以上。

App 没有做苹果公证，第一次打开时 macOS 会拦住。
到**系统设置 → 隐私与安全性**，点**仍要打开**即可。

## 🛠 从源码构建

需要 Xcode Command Line Tools（`xcode-select --install`）。

```bash
git clone https://github.com/shepherd2047/LidSleep.git
cd LidSleep
./build.sh
open ~/Applications/LidSleep.app
```

`build.sh` 会编译 arm64 和 x86_64 两种架构的 `main.swift`，打包成 `~/Applications/LidSleep.app` 并做 ad-hoc 签名。
`./dmg.sh` 会把同样的 app 打包成 `dist/LidSleep.dmg`。

## 🔑 首次运行

改电源设置需要管理员权限。首次启动时 LidSleep 会用系统标准对话框**问一次密码**，
然后在 `/etc/sudoers.d/pmset` 装一条规则，只放行**这两条完整命令**免密：

```
/usr/bin/pmset -a disablesleep 0
/usr/bin/pmset -a disablesleep 1
```

其他 `pmset` 或 `sudo` 命令照样要密码。点 **Not Now** 可以跳过，第一次切换时会再问。

## ⚙️ 原理

| 操作 | 实际执行 |
| --- | --- |
| 读取状态 | `pmset -g` → `SleepDisabled 0/1` |
| 首次设置 | 通过管理员密码框执行 `visudo -c` 校验并安装规则 |
| 切换 | `sudo -n pmset -a disablesleep 0/1` |
| 开机启动 | `SMAppService.mainApp` |

## ⚠️ 注意

关闭休眠后屏幕会熄灭，但**电脑仍在运行**。
别开着它塞进包里，会发热、耗电。接不接电源都生效。

## 🧹 卸载

```bash
pkill -x LidSleep
rm -rf ~/Applications/LidSleep.app
sudo pmset -a disablesleep 0       # 恢复合盖休眠
sudo rm -f /etc/sudoers.d/pmset    # 删除免密规则
```

## 📄 许可证

[MIT](LICENSE)
