import Foundation

/// Manages chat history with persistence
@MainActor
class ChatHistory: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    private let storageKey = "chat_history"
    private let analyticsKey = "vim_analytics"
    
    /// Track which Vim topics are asked about (for analytics)
    @Published var topicCounts: [String: Int] = [:]
    
    init() {
        load()
    }
    
    func add(_ message: ChatMessage) {
        messages.append(message)
        
        // Track topics for analytics
        if message.role == .user {
            trackTopics(in: message.content)
        }
        
        save()
    }
    
    func recentMessages(limit: Int) -> [ChatMessage] {
        Array(messages.suffix(limit))
    }
    
    func clear() {
        messages.removeAll()
        save()
    }
    
    // MARK: - Topic Analytics
    
    private let topicKeywords: [String: [String]] = [
        "navigation": ["move", "navigate", "hjkl", "jump", "go to", "cursor"],
        "editing": ["delete", "cut", "paste", "yank", "change", "replace", "insert"],
        "search": ["search", "find", "replace", "substitute", "grep", "pattern"],
        "visual": ["select", "visual", "highlight", "block"],
        "registers": ["register", "clipboard", "yank", "paste", "\""],
        "macros": ["macro", "record", "replay", "q"],
        "buffers": ["buffer", "file", "open", "save", "write", "quit"],
        "windows": ["window", "split", "tab", "pane"],
        "text_objects": ["text object", "inner", "around", "iw", "aw", "ci", "di", "yi"],
        "marks": ["mark", "bookmark", "jump to", "'", "`"],
        "folding": ["fold", "collapse", "expand", "z"]
    ]
    
    private func trackTopics(in query: String) {
        let lowercased = query.lowercased()
        for (topic, keywords) in topicKeywords {
            if keywords.contains(where: { lowercased.contains($0) }) {
                topicCounts[topic, default: 0] += 1
            }
        }
        save()
    }
    
    func topAskedTopics(limit: Int = 5) -> [(topic: String, count: Int)] {
        topicCounts.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
    
    // MARK: - Persistence
    
    private var storageURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LearnVim", isDirectory: true)
    }
    
    private func save() {
        do {
            try FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
            
            // Save messages
            let messageData = try JSONEncoder().encode(messages)
            try messageData.write(to: storageURL.appendingPathComponent("messages.json"))
            
            // Save analytics
            let analyticsData = try JSONEncoder().encode(topicCounts)
            try analyticsData.write(to: storageURL.appendingPathComponent("analytics.json"))
        } catch {
            print("Failed to save chat history: \(error)")
        }
    }
    
    private func load() {
        do {
            // Load messages
            let messagesURL = storageURL.appendingPathComponent("messages.json")
            if FileManager.default.fileExists(atPath: messagesURL.path) {
                let data = try Data(contentsOf: messagesURL)
                messages = try JSONDecoder().decode([ChatMessage].self, from: data)
            }
            
            // Load analytics
            let analyticsURL = storageURL.appendingPathComponent("analytics.json")
            if FileManager.default.fileExists(atPath: analyticsURL.path) {
                let data = try Data(contentsOf: analyticsURL)
                topicCounts = try JSONDecoder().decode([String: Int].self, from: data)
            }
        } catch {
            print("Failed to load chat history: \(error)")
        }
    }
}

// MARK: - Codable ChatMessage

extension ChatMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case id, role, content, timestamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(role == .user ? "user" : "assistant", forKey: .role)
        try container.encode(content, forKey: .content)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let roleString = try container.decode(String.self, forKey: .role)
        let content = try container.decode(String.self, forKey: .content)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.init(id: id, role: roleString == "user" ? .user : .assistant, content: content, timestamp: timestamp)
    }
}
