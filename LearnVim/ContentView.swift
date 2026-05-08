import SwiftUI
import AppKit

enum ContentTab {
    case cheatSheet, chat
}

struct ContentView: View {
    @ObservedObject var llmService: LLMService
    @StateObject private var chatHistory = ChatHistory()
    @State private var query = ""
    @State private var currentResponse = ""
    @State private var currentTab: ContentTab = .cheatSheet
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if let image = NSImage(named: "MenuBarIcon") {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "v.square.fill")
                        .foregroundColor(.green)
                }
                Text("LearnVim")
                    .font(.headline)
                Spacer()
                
                // Tab buttons
                HStack(spacing: 4) {
                    TabButton(icon: "list.bullet.rectangle", isSelected: currentTab == .cheatSheet) {
                        currentTab = .cheatSheet
                    }
                    TabButton(icon: "text.bubble.fill", isSelected: currentTab == .chat) {
                        currentTab = .chat
                    }
                }
                
                if llmService.hasStartedLoading {
                    if llmService.isLoading {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text(llmService.loadingStatus)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider()
            
            switch currentTab {
            case .cheatSheet:
                CheatSheetView()
            case .chat:
                // Trigger model download when entering chat tab
                if !llmService.hasStartedLoading {
                    ModelDownloadPrompt {
                        Task {
                            await llmService.loadModel()
                        }
                    }
                } else if llmService.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(llmService.loadingStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Messages
                    chatContentView
                }
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }
    
    private var chatContentView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            if chatHistory.messages.isEmpty && currentResponse.isEmpty {
                                WelcomeView(
                                    onExampleTap: { example in
                                        query = example
                                        sendQuery()
                                    }
                                )
                                .padding(.top, 16)
                            }

                            ForEach(chatHistory.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            // Streaming response
                            if !currentResponse.isEmpty {
                                MessageBubble(
                                    message: ChatMessage(
                                        role: .assistant,
                                        content: currentResponse + (llmService.isGenerating ? "▊" : "")
                                    )
                                )
                                .id("streaming")
                            }

                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(12)
                    }
                    .onChange(of: currentResponse) { _, _ in
                        withAnimation(.easeOut(duration: 0.1)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: chatHistory.messages.count) { _, _ in
                        withAnimation(.easeOut(duration: 0.1)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }

                Divider()

                // Input area
                HStack(spacing: 8) {
                    TextField("Ask about Vim...", text: $query)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                        .focused($isInputFocused)
                        .onSubmit {
                            sendQuery()
                        }
                        .disabled(llmService.isLoading)

                    Button(action: sendQuery) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(canSend ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSend)
                }
                .padding(10)
        }
    }

    private var canSend: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty && 
        !llmService.isLoading && 
        !llmService.isGenerating &&
        llmService.hasStartedLoading
    }

    private func sendQuery() {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !llmService.isLoading, !llmService.isGenerating else { return }

        let userMessage = ChatMessage(role: .user, content: trimmed)
        chatHistory.add(userMessage)
        query = ""
        currentResponse = ""

        Task {
            // Pass conversation history for context
            let stream = llmService.generate(query: trimmed, history: chatHistory.recentMessages(limit: 6))
            for await token in stream {
                currentResponse += token
            }
            let response = ChatMessage(role: .assistant, content: currentResponse)
            chatHistory.add(response)
            currentResponse = ""
        }
    }
}

// MARK: - Model Download Prompt

struct ModelDownloadPrompt: View {
    let onDownload: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 40))
                .foregroundColor(.green)
            
            Text("AI Chat Requires Download")
                .font(.headline)
            
            Text("The Llama 3.2 3B model (~1.8 GB) will be downloaded to enable AI chat. This only happens once.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onDownload) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Download Model")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            Text("Or use the Cheat Sheet tab for instant reference!")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isSelected ? .green : .secondary)
                .frame(width: 24, height: 24)
                .background(isSelected ? Color.green.opacity(0.15) : Color.clear)
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    let onExampleTap: (String) -> Void
    
    private let examples = [
        "How do I delete a word?",
        "What's the difference between y and d?",
        "How do I search and replace?",
        "Explain text objects"
    ]

    var body: some View {
        VStack(spacing: 10) {
            Text("Try:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(examples, id: \.self) { example in
                    ExampleQuery(text: example, onTap: { onExampleTap(example) })
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExampleQuery: View {
    let text: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.green)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .user {
                Spacer(minLength: 40)
                Text(message.content)
                    .font(.body)
                    .padding(8)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(8)
            } else {
                MarkdownText(message.content)
                    .textSelection(.enabled)
                    .padding(8)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Markdown Rendering

struct MarkdownText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(attributedString)
            .font(.body)
    }
    
    private var attributedString: AttributedString {
        var result = AttributedString()
        
        // Split into segments and style accordingly
        let pattern = #"`([^`]+)`"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = text as NSString
        var lastEnd = 0
        
        let matches = regex?.matches(in: text, range: NSRange(location: 0, length: nsString.length)) ?? []
        
        for match in matches {
            // Add text before the match
            if match.range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                let beforeText = nsString.substring(with: beforeRange)
                result.append(AttributedString(beforeText))
            }
            
            // Add the code (without backticks) with styling
            if match.numberOfRanges > 1 {
                let codeRange = match.range(at: 1)
                let codeText = nsString.substring(with: codeRange)
                var codeAttr = AttributedString(codeText)
                codeAttr.font = .system(.body, design: .monospaced).bold()
                codeAttr.foregroundColor = .green
                codeAttr.backgroundColor = Color(nsColor: .controlBackgroundColor).opacity(0.5)
                result.append(codeAttr)
            }
            
            lastEnd = match.range.location + match.range.length
        }
        
        // Add remaining text
        if lastEnd < nsString.length {
            let remainingText = nsString.substring(from: lastEnd)
            result.append(AttributedString(remainingText))
        }
        
        return result.characters.isEmpty ? AttributedString(text) : result
    }
}

// MARK: - Cheat Sheet View

struct CheatSheetView: View {
    @State private var searchText = ""
    
    private let commands: [(category: String, items: [(key: String, description: String)])] = [
        ("Movement", [
            ("h j k l", "Left, Down, Up, Right"),
            ("w / b", "Next / Previous word"),
            ("0 / $", "Start / End of line"),
            ("gg / G", "First / Last line"),
            ("Ctrl+d/u", "Half page down / up"),
            ("f{char}", "Jump to char on line"),
        ]),
        ("Editing", [
            ("i / a", "Insert before / after cursor"),
            ("o / O", "New line below / above"),
            ("x", "Delete character"),
            ("dd", "Delete line"),
            ("dw", "Delete word"),
            ("yy", "Yank (copy) line"),
            ("p / P", "Paste after / before"),
            ("u / Ctrl+r", "Undo / Redo"),
            (".", "Repeat last change"),
        ]),
        ("Text Objects", [
            ("ciw", "Change inner word"),
            ("di\"", "Delete inside quotes"),
            ("ya{", "Yank around braces"),
            ("vi(", "Select inside parens"),
        ]),
        ("Search", [
            ("/{pattern}", "Search forward"),
            ("n / N", "Next / Previous match"),
            ("*", "Search word under cursor"),
            (":%s/old/new/g", "Replace all"),
        ]),
        ("Files", [
            (":w", "Save"),
            (":q", "Quit"),
            (":wq", "Save and quit"),
            (":e {file}", "Open file"),
        ]),
    ]
    
    var filteredCommands: [(category: String, items: [(key: String, description: String)])] {
        if searchText.isEmpty {
            return commands
        }
        return commands.compactMap { category, items in
            let filtered = items.filter {
                $0.key.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
            return filtered.isEmpty ? nil : (category, filtered)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search
            TextField("Search commands...", text: $searchText)
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(filteredCommands, id: \.category) { category, items in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(category)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            ForEach(items, id: \.key) { key, description in
                                HStack {
                                    Text(key)
                                        .font(.system(.caption, design: .monospaced))
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                        .frame(width: 90, alignment: .leading)
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Chat Message Model

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: Role
    let content: String
    let timestamp: Date

    enum Role: Equatable {
        case user, assistant
    }
    
    init(id: UUID = UUID(), role: Role, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}
