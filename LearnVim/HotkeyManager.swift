import Carbon
import AppKit

class HotkeyManager {
    private var eventHandler: EventHandlerRef?
    private let callback: () -> Void

    init(modifier: String = "option", key: String = "V", callback: @escaping () -> Void) {
        self.callback = callback
        registerHotkey(modifier: modifier, key: key)
    }

    deinit {
        if let handler = eventHandler {
            RemoveEventHandler(handler)
        }
    }

    private func registerHotkey(modifier: String, key: String) {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4C56_4D00) // "LVM\0"
        hotKeyID.id = 1

        var hotKeyRef: EventHotKeyRef?

        // Map modifier string to Carbon modifier
        let modifierFlag: UInt32
        switch modifier {
        case "option": modifierFlag = UInt32(optionKey)
        case "control": modifierFlag = UInt32(controlKey)
        case "shift": modifierFlag = UInt32(shiftKey)
        case "command": modifierFlag = UInt32(cmdKey)
        default: modifierFlag = UInt32(optionKey)
        }
        
        // Map key string to virtual key code
        let keyCode = keyCodeForCharacter(key.uppercased())
        
        let status = RegisterEventHotKey(
            UInt32(keyCode),
            modifierFlag,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            print("⚠️ Failed to register hotkey. Status: \(status)")
            return
        }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handlerCallback: EventHandlerUPP = { _, event, userData -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.callback()
            return noErr
        }

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            handlerCallback,
            1,
            &eventType,
            selfPtr,
            &eventHandler
        )

        let modSymbol: String
        switch modifier {
        case "option": modSymbol = "⌥"
        case "control": modSymbol = "⌃"
        case "shift": modSymbol = "⇧"
        case "command": modSymbol = "⌘"
        default: modSymbol = "⌥"
        }
        print("✅ Global hotkey \(modSymbol)\(key.uppercased()) registered")
    }
    
    private func keyCodeForCharacter(_ char: String) -> Int {
        // Common key codes for letters
        let keyCodes: [String: Int] = [
            "A": kVK_ANSI_A, "B": kVK_ANSI_B, "C": kVK_ANSI_C, "D": kVK_ANSI_D,
            "E": kVK_ANSI_E, "F": kVK_ANSI_F, "G": kVK_ANSI_G, "H": kVK_ANSI_H,
            "I": kVK_ANSI_I, "J": kVK_ANSI_J, "K": kVK_ANSI_K, "L": kVK_ANSI_L,
            "M": kVK_ANSI_M, "N": kVK_ANSI_N, "O": kVK_ANSI_O, "P": kVK_ANSI_P,
            "Q": kVK_ANSI_Q, "R": kVK_ANSI_R, "S": kVK_ANSI_S, "T": kVK_ANSI_T,
            "U": kVK_ANSI_U, "V": kVK_ANSI_V, "W": kVK_ANSI_W, "X": kVK_ANSI_X,
            "Y": kVK_ANSI_Y, "Z": kVK_ANSI_Z,
            "0": kVK_ANSI_0, "1": kVK_ANSI_1, "2": kVK_ANSI_2, "3": kVK_ANSI_3,
            "4": kVK_ANSI_4, "5": kVK_ANSI_5, "6": kVK_ANSI_6, "7": kVK_ANSI_7,
            "8": kVK_ANSI_8, "9": kVK_ANSI_9
        ]
        return keyCodes[char] ?? kVK_ANSI_V
    }
}
