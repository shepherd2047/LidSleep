import AppKit
import ServiceManagement

// Menu bar toggle: whether closing the lid puts the Mac to sleep (pmset disablesleep)
// Tries a passwordless sudoers rule first (sudo -n), falls back to the system password prompt
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
        if run("/usr/bin/sudo", ["-n", "/usr/bin/pmset", "-a", "disablesleep", v]).ok == false {
            let script = "do shell script \"/usr/bin/pmset -a disablesleep \(v)\" with administrator privileges"
            NSAppleScript(source: script)?.executeAndReturnError(nil)
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
