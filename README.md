# LearnVim

A macOS menu bar app that helps you learn Vim with a local AI assistant.

<img src="docs/screenshot.png" width="380" alt="LearnVim Screenshot">

## Features

### 📋 Quick Reference (Default View)
- Searchable cheat sheet of common Vim commands
- Organized by category (Movement, Editing, Text Objects, Search, Files)
- **No download required** — works instantly

### 🤖 Local AI Chat
- **Llama 3.2 3B** running on-device via Apple MLX — no internet needed after first download
- **Optional download** — model (~1.8 GB) downloads only when you first access the Chat tab
- Natural language questions: "how do I delete inside quotes?"
- Answers include exact keystrokes like `ci"` with syntax highlighting
- **Conversation context** — follow-up questions understand what you were discussing
- **RAG-powered** — retrieves only relevant documentation for faster, more accurate responses

### ⚙️ Personalization
- **Vim context awareness** — detects your `.vimrc`/`init.lua` and installed plugins
- Answers are personalized: "You have Telescope installed, so use `:Telescope find_files`"
- **Analytics** — tracks which topics you ask about most, surfaces weak spots

### 💬 History
- Full conversation history persisted between sessions
- Clear history anytime from settings

### ⌨️ Global Hotkey
- **⌥V** (Option+V) toggles the panel from anywhere
- Configurable in settings (any modifier + key)
- Works even when other apps are focused

### 🚀 Native Experience
- Official Vim logo in menu bar and app icon
- Menu bar popover — click or hotkey to toggle
- Right-click menu bar icon for settings and quit
- Launch at login option
- Light/dark mode support

## Requirements

- macOS 14.0+
- Apple Silicon Mac (M1/M2/M3/M4)
- ~2GB disk for the model (downloaded on first launch)
- Xcode 16+ (for building)

## Build & Run

```bash
# Install xcodegen if needed
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Build from command line
xcodebuild -project LearnVim.xcodeproj -scheme LearnVim build

# Or open in Xcode and hit ⌘R
open LearnVim.xcodeproj
```

## Usage

1. Launch the app — Vim logo appears in your menu bar
2. Press **⌥V** or click the icon to toggle the panel
3. Choose a mode:
   - **Chat** (💬) — Ask questions in natural language
   - **Cheat Sheet** (📋) — Browse/search commands
4. First launch downloads the model (~2GB). After that it's fully offline.

## Settings

Right-click the menu bar icon → **Settings...**

- **Launch at login** — Start LearnVim when you log in
- **Hotkey** — Change the global shortcut (default: ⌥V)
- **Clear history** — Wipe chat and bookmarks

## Project Structure

```
LearnVim/
├── LearnVimApp.swift       # App entry point
├── AppDelegate.swift       # Menu bar, popover, hotkey setup
├── ContentView.swift       # Main UI with tabs
├── LLMService.swift        # MLX model loading and inference
├── VimDocs.swift           # Vim reference content
├── VimContext.swift        # Detects user's Vim setup
├── ChatHistory.swift       # Persistence and analytics
├── SettingsView.swift      # Settings panel
├── HotkeyManager.swift     # Global keyboard shortcut
└── Resources/
    └── Assets.xcassets/    # App icon (Vim logo)
```

## Roadmap

- [ ] **RAG** — Vector-based retrieval over comprehensive Vim docs
- [ ] **Learning path** — Structured curriculum with progress tracking
- [ ] **Interactive sandbox** — Practice in an embedded terminal
- [ ] **Spaced repetition** — Quiz mode with SRS scheduling
- [ ] **iCloud sync** — Sync progress across devices
- [ ] **Neovim plugin** — Open LearnVim from within Neovim

## Credits

- [Vim](https://www.vim.org/) — Logo used under Vim license
- [MLX Swift](https://github.com/ml-explore/mlx-swift-examples) — Apple's ML framework
- [Llama 3.2](https://huggingface.co/mlx-community/Llama-3.2-3B-Instruct-4bit) — Meta's language model

## License

MIT
