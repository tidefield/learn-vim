import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("hotkeyModifier") private var hotkeyModifier = "option"
    @AppStorage("hotkeyKey") private var hotkeyKey = "V"
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            Form {
                Section("Startup") {
                    Toggle("Launch at login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            setLaunchAtLogin(newValue)
                        }
                }
                
                Section("Hotkey") {
                    HStack {
                        Picker("Modifier", selection: $hotkeyModifier) {
                            Text("⌥ Option").tag("option")
                            Text("⌃ Control").tag("control")
                            Text("⇧ Shift").tag("shift")
                            Text("⌘ Command").tag("command")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 140)
                        
                        Text("+")
                            .foregroundColor(.secondary)
                        
                        TextField("Key", text: $hotkeyKey)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .onChange(of: hotkeyKey) { _, newValue in
                                // Limit to single character
                                if newValue.count > 1 {
                                    hotkeyKey = String(newValue.last!)
                                }
                                hotkeyKey = hotkeyKey.uppercased()
                            }
                    }
                    
                    Text("Current: \(modifierSymbol)\(hotkeyKey)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Restart app to apply hotkey changes")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                
                Section("Data") {
                    Button("Clear Chat History") {
                        clearChatHistory()
                    }
                    .foregroundColor(.red)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 340, height: 320)
    }
    
    private var modifierSymbol: String {
        switch hotkeyModifier {
        case "option": return "⌥"
        case "control": return "⌃"
        case "shift": return "⇧"
        case "command": return "⌘"
        default: return "⌥"
        }
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to set launch at login: \(error)")
        }
    }
    
    private func clearChatHistory() {
        let storageURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LearnVim", isDirectory: true)
        try? FileManager.default.removeItem(at: storageURL.appendingPathComponent("messages.json"))
        try? FileManager.default.removeItem(at: storageURL.appendingPathComponent("bookmarks.json"))
    }
}
