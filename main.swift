import AppKit
import ServiceManagement

// Menu bar toggle: whether closing the lid puts the Mac to sleep (pmset disablesleep)
// On first use it asks for the admin password once and installs a sudoers rule that allows
// only `pmset -a disablesleep 0/1`, so later toggles run via `sudo -n` without prompts
final class App: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let toggleItem = NSMenuItem(title: "", action: #selector(toggle), keyEquivalent: "")
    let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")

    func applicationDidFinishLaunching(_ n: Notification) {
        let menu = NSMenu()
        menu.delegate = self
        toggleItem.target = self
        loginItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(loginItem)
        menu.addItem(NSMenuItem(title: "Quit LidSleep", action: #selector(NSApp.terminate), keyEquivalent: "q"))
        item.menu = menu
        refresh()
        if !hasRule { DispatchQueue.main.async { self.offerSetup() } }
    }

    let pmsetArgs = ["/usr/bin/pmset", "-a", "disablesleep"]

    var hasRule: Bool {
        ["0", "1"].allSatisfy { run("/usr/bin/sudo", ["-n", "-l"] + pmsetArgs + [$0]).ok }
    }

    func offerSetup() {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = "One-time setup"
        a.informativeText = "macOS needs your admin password to change sleep settings. Enter it once and LidSleep won't ask again.\n\nOnly “pmset -a disablesleep 0/1” is allowed without a password."
        a.addButton(withTitle: "Continue")
        a.addButton(withTitle: "Not Now")
        if a.runModal() == .alertFirstButtonReturn { _ = installRule() }
    }

    // Returns true if the rule is in place afterwards; false if the user cancelled or it failed
    func installRule() -> Bool {
        let rule = "\(NSUserName()) ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1\n"
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("lidsleep-sudoers").path
        guard (try? rule.write(toFile: tmp, atomically: true, encoding: .utf8)) != nil else { return false }
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let cmd = "/usr/sbin/visudo -cf '\(tmp)' && /usr/bin/install -m 440 -o root -g wheel '\(tmp)' /etc/sudoers.d/pmset"
        let script = "do shell script \"\(cmd)\" with prompt \"LidSleep needs your password once.\" with administrator privileges"
        NSAppleScript(source: script)?.executeAndReturnError(nil)
        return hasRule
    }

    func menuWillOpen(_ m: NSMenu) { refresh() }

    var sleepDisabled: Bool {
        let out = run("/usr/bin/pmset", ["-g"]).out
        return out.split(separator: "\n").contains { $0.contains("SleepDisabled") && $0.hasSuffix("1") }
    }

    func refresh() {
        let off = sleepDisabled
        let img = NSImage(systemSymbolName: off ? "cup.and.saucer.fill" : "moon.zzz",
                          accessibilityDescription: off ? "Lid sleep off" : "Lid sleep on")
        img?.isTemplate = true
        item.button?.image = img
        toggleItem.title = "Stay Awake With Lid Closed"
        toggleItem.state = off ? .on : .off
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    @objc func toggle() {
        let v = sleepDisabled ? "0" : "1"
        if hasRule || installRule() {
            _ = run("/usr/bin/sudo", ["-n"] + pmsetArgs + [v])
        }
        refresh()
    }

    @objc func toggleLogin() {
        let s = SMAppService.mainApp
        try? (s.status == .enabled ? s.unregister() : s.register())
        refresh()
    }

    func run(_ path: String, _ args: [String]) -> (ok: Bool, out: String) {
        let p = Process(), pipe = Pipe()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        p.standardOutput = pipe
        p.standardError = Pipe()
        guard (try? p.run()) != nil else { return (false, "") }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return (p.terminationStatus == 0, String(decoding: data, as: UTF8.self))
    }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
