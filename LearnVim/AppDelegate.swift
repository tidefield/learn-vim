import AppKit
import SwiftUI
import Carbon

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?
    private var hotkeyManager: HotkeyManager?
    private let llmService = LLMService()
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPopover()
        setupStatusItem()
        setupHotkey()
        setupClickOutsideDismiss()
        
        // Model loading is now lazy - triggered when user clicks on Chat tab
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 380, height: 500)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: ContentView(llmService: llmService)
                .frame(width: 380, height: 500)
        )
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            if let image = NSImage(named: "MenuBarIcon") {
                image.size = NSSize(width: 18, height: 18)
                button.image = image
            } else {
                button.image = NSImage(systemSymbolName: "v.square.fill", accessibilityDescription: "LearnVim")
            }
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }
    }
    
    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        let hotkeyString = currentHotkeyString()
        menu.addItem(NSMenuItem(title: "Toggle Panel (\(hotkeyString))", action: #selector(togglePopover), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit LearnVim", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Reset to allow left-click toggling
    }
    
    private func currentHotkeyString() -> String {
        let modifier = UserDefaults.standard.string(forKey: "hotkeyModifier") ?? "option"
        let key = UserDefaults.standard.string(forKey: "hotkeyKey") ?? "V"
        let symbol: String
        switch modifier {
        case "option": symbol = "⌥"
        case "control": symbol = "⌃"
        case "shift": symbol = "⇧"
        case "command": symbol = "⌘"
        default: symbol = "⌥"
        }
        return "\(symbol)\(key)"
    }

    private func setupHotkey() {
        let modifier = UserDefaults.standard.string(forKey: "hotkeyModifier") ?? "option"
        let key = UserDefaults.standard.string(forKey: "hotkeyKey") ?? "V"
        
        hotkeyManager = HotkeyManager(modifier: modifier, key: key) { [weak self] in
            DispatchQueue.main.async {
                self?.togglePopover()
            }
        }
    }

    private func setupClickOutsideDismiss() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    @objc private func showSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "LearnVim Settings"
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow = window
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
