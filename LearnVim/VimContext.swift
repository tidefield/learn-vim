import Foundation

/// Detects user's Vim/Neovim setup for personalized answers
struct VimContext {
    
    struct VimSetup {
        let hasVim: Bool
        let hasNeovim: Bool
        let vimrcPath: String?
        let neovimConfigPath: String?
        let detectedPlugins: [String]
        let detectedSettings: [String]
    }
    
    static func detect() -> VimSetup {
        let fileManager = FileManager.default
        let home = fileManager.homeDirectoryForCurrentUser.path
        
        // Check for Vim
        let hasVim = fileManager.fileExists(atPath: "/usr/bin/vim") ||
                     fileManager.fileExists(atPath: "/usr/local/bin/vim") ||
                     fileManager.fileExists(atPath: "/opt/homebrew/bin/vim")
        
        // Check for Neovim
        let hasNeovim = fileManager.fileExists(atPath: "/usr/local/bin/nvim") ||
                        fileManager.fileExists(atPath: "/opt/homebrew/bin/nvim")
        
        // Check for vimrc
        let vimrcPaths = [
            "\(home)/.vimrc",
            "\(home)/.vim/vimrc",
            "\(home)/_vimrc"  // Windows-style
        ]
        let vimrcPath = vimrcPaths.first { fileManager.fileExists(atPath: $0) }
        
        // Check for Neovim config
        let neovimPaths = [
            "\(home)/.config/nvim/init.vim",
            "\(home)/.config/nvim/init.lua"
        ]
        let neovimConfigPath = neovimPaths.first { fileManager.fileExists(atPath: $0) }
        
        // Parse config for plugins and settings
        var detectedPlugins: [String] = []
        var detectedSettings: [String] = []
        
        if let configPath = neovimConfigPath ?? vimrcPath,
           let content = try? String(contentsOfFile: configPath, encoding: .utf8) {
            (detectedPlugins, detectedSettings) = parseConfig(content)
        }
        
        return VimSetup(
            hasVim: hasVim,
            hasNeovim: hasNeovim,
            vimrcPath: vimrcPath,
            neovimConfigPath: neovimConfigPath,
            detectedPlugins: detectedPlugins,
            detectedSettings: detectedSettings
        )
    }
    
    private static func parseConfig(_ content: String) -> (plugins: [String], settings: [String]) {
        var plugins: [String] = []
        var settings: [String] = []
        
        let lines = content.components(separatedBy: .newlines)
        
        // Common plugin manager patterns
        let pluginPatterns = [
            "Plug '([^']+)'",           // vim-plug
            "Plugin '([^']+)'",         // Vundle
            "NeoBundle '([^']+)'",      // NeoBundle
            "use '([^']+)'",            // packer.nvim
            "\"([^\"]+)\"",             // lazy.nvim requires
        ]
        
        // Popular plugins to detect
        let knownPlugins = [
            "nerdtree": "NERDTree (file explorer)",
            "fzf": "fzf (fuzzy finder)",
            "telescope": "Telescope (fuzzy finder)",
            "coc.nvim": "CoC (completion)",
            "nvim-lspconfig": "LSP Config",
            "ale": "ALE (linting)",
            "vim-fugitive": "Fugitive (git)",
            "vim-surround": "Surround",
            "vim-commentary": "Commentary (comments)",
            "which-key": "Which-Key (keybindings)",
            "nvim-tree": "nvim-tree (file explorer)",
            "lightline": "Lightline (statusline)",
            "airline": "Airline (statusline)",
            "lualine": "Lualine (statusline)",
        ]
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip comments
            if trimmed.hasPrefix("\"") || trimmed.hasPrefix("#") || trimmed.hasPrefix("--") {
                continue
            }
            
            // Check for plugins
            for (key, description) in knownPlugins {
                if trimmed.lowercased().contains(key) {
                    if !plugins.contains(description) {
                        plugins.append(description)
                    }
                }
            }
            
            // Check for common settings
            if trimmed.contains("set number") || trimmed.contains("vim.opt.number") {
                settings.append("Line numbers enabled")
            }
            if trimmed.contains("set relativenumber") || trimmed.contains("vim.opt.relativenumber") {
                settings.append("Relative line numbers")
            }
            if trimmed.contains("set mouse=") || trimmed.contains("vim.opt.mouse") {
                settings.append("Mouse support")
            }
            if trimmed.contains("clipboard") && (trimmed.contains("unnamed") || trimmed.contains("unnamedplus")) {
                settings.append("System clipboard integration")
            }
        }
        
        return (plugins, Array(Set(settings))) // Dedupe settings
    }
    
    /// Generate context string for the LLM
    static func contextDescription() -> String? {
        let setup = detect()
        
        var parts: [String] = []
        
        if setup.hasNeovim {
            parts.append("User is using Neovim")
        } else if setup.hasVim {
            parts.append("User is using Vim")
        } else {
            return nil
        }
        
        if !setup.detectedPlugins.isEmpty {
            parts.append("Installed plugins: \(setup.detectedPlugins.joined(separator: ", "))")
        }
        
        if !setup.detectedSettings.isEmpty {
            parts.append("Settings: \(setup.detectedSettings.joined(separator: ", "))")
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: ". ")
    }
}
