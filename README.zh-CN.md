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
- 加一条 sudoers 规则后**无需输入密码**（可选）
- 内置**开机启动**
- **没有 Dock 图标**、没有窗口、没有后台守护进程
- **约 80 行 Swift**，零依赖，不需要 Xcode 工程

## 🚀 安装

需要 Xcode Command Line Tools（`xcode-select --install`）。

```bash
git clone https://github.com/shepherd2047/LidSleep.git
cd LidSleep
./build.sh
open ~/Applications/LidSleep.app
```

`build.sh` 会编译 `main.swift`，打包成 `~/Applications/LidSleep.app` 并做 ad-hoc 签名。

## 🔑 免密码（可选）

改电源设置需要管理员权限，所以默认每次切换都会问密码。
下面这条只放行**这两条完整命令**免密：

```bash
echo "$(whoami) ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1" \
  | sudo tee /etc/sudoers.d/pmset >/dev/null && sudo chmod 440 /etc/sudoers.d/pmset && sudo visudo -c
```

看到 `/etc/sudoers.d/pmset: parsed OK` 就成功了。其他 `pmset` 或 `sudo` 命令照样要密码。
撤销：`sudo rm /etc/sudoers.d/pmset`。

## ⚙️ 原理

| 操作 | 实际执行 |
| --- | --- |
| 读取状态 | `pmset -g` → `SleepDisabled 0/1` |
| 切换 | `sudo -n pmset -a disablesleep 0/1`，失败时弹系统管理员密码框 |
| 开机启动 | `SMAppService.mainApp` |

## ⚠️ 注意

关闭休眠后屏幕会熄灭，但**电脑仍在运行**。
别开着它塞进包里，会发热、耗电。接不接电源都生效。

## 🧹 卸载

```bash
pkill -x LidSleep
rm -rf ~/Applications/LidSleep.app
sudo pmset -a disablesleep 0       # 恢复合盖休眠
sudo rm -f /etc/sudoers.d/pmset    # 如果加过免密规则
```

## 📄 许可证

[MIT](LICENSE)
