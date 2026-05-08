import Foundation

/// RAG (Retrieval-Augmented Generation) service for Vim documentation
@MainActor
class RAGService: ObservableObject {
    
    static let shared = RAGService()
    
    /// A chunk of documentation with its embedding
    struct DocumentChunk: Identifiable {
        let id = UUID()
        let title: String      // Section title (e.g., "Movement")
        let content: String    // The actual content
        let keywords: [String] // Extracted keywords for boosting
        var embedding: [Float] = []
    }
    
    @Published var isIndexed = false
    private var chunks: [DocumentChunk] = []
    private let embeddingService = EmbeddingService.shared
    
    private init() {}
    
    /// Index the Vim documentation
    func buildIndex() {
        // Parse documentation into chunks (including extended docs)
        chunks = parseDocumentation(VimDocs.fullReference)
        
        // Build embedding vocabulary from all chunks
        let allContent = chunks.map { "\($0.title) \($0.content)" }
        embeddingService.buildIndex(from: allContent)
        
        // Generate embeddings for each chunk
        for i in chunks.indices {
            let text = "\(chunks[i].title) \(chunks[i].content)"
            chunks[i].embedding = embeddingService.embed(text)
        }
        
        isIndexed = true
        print("✅ RAG index built with \(chunks.count) chunks")
    }
    
    /// Retrieve relevant chunks for a query
    /// - Parameters:
    ///   - query: User's question
    ///   - topK: Number of chunks to retrieve
    /// - Returns: Most relevant document chunks
    func retrieve(query: String, topK: Int = 3) -> [DocumentChunk] {
        guard isIndexed else {
            buildIndex()
            return retrieve(query: query, topK: topK)
        }
        
        let queryEmbedding = embeddingService.embed(query)
        
        // Score each chunk
        var scored: [(chunk: DocumentChunk, score: Float)] = []
        
        for chunk in chunks {
            var score = embeddingService.cosineSimilarity(queryEmbedding, chunk.embedding)
            
            // Keyword boosting - if query contains chunk keywords, boost score
            let queryLower = query.lowercased()
            for keyword in chunk.keywords {
                if queryLower.contains(keyword.lowercased()) {
                    score += 0.15 // Boost for keyword match
                }
            }
            
            scored.append((chunk, score))
        }
        
        // Sort by score descending and take top K
        scored.sort { $0.score > $1.score }
        
        return Array(scored.prefix(topK).map { $0.chunk })
    }
    
    /// Get context string from retrieved chunks for the LLM
    func contextForQuery(_ query: String) -> String {
        let relevantChunks = retrieve(query: query, topK: 4)
        
        var context = "Relevant Vim reference:\n\n"
        
        for chunk in relevantChunks {
            context += "## \(chunk.title)\n"
            context += chunk.content
            context += "\n\n"
        }
        
        // Add user's vim setup context
        if let vimContext = VimContext.contextDescription() {
            context += "User's setup: \(vimContext)\n\n"
        }
        
        context += "Question: \(query)"
        
        return context
    }
    
    // MARK: - Document Parsing
    
    private func parseDocumentation(_ doc: String) -> [DocumentChunk] {
        var chunks: [DocumentChunk] = []
        let lines = doc.components(separatedBy: "\n")
        
        var currentTitle = ""
        var currentContent: [String] = []
        
        for line in lines {
            if line.hasPrefix("## ") {
                // Save previous chunk if exists
                if !currentTitle.isEmpty {
                    let content = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !content.isEmpty {
                        let keywords = extractKeywords(from: currentTitle, content: content)
                        chunks.append(DocumentChunk(
                            title: currentTitle,
                            content: content,
                            keywords: keywords
                        ))
                    }
                }
                
                // Start new chunk
                currentTitle = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                currentContent = []
            } else if line.hasPrefix("# ") {
                // Skip main title
                continue
            } else {
                currentContent.append(line)
            }
        }
        
        // Don't forget the last chunk
        if !currentTitle.isEmpty {
            let content = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                let keywords = extractKeywords(from: currentTitle, content: content)
                chunks.append(DocumentChunk(
                    title: currentTitle,
                    content: content,
                    keywords: keywords
                ))
            }
        }
        
        // Add some combined chunks for common multi-topic queries
        chunks.append(contentsOf: createCombinedChunks(from: chunks))
        
        return chunks
    }
    
    private func extractKeywords(from title: String, content: String) -> [String] {
        var keywords: [String] = []
        
        // Title words are keywords
        keywords.append(contentsOf: title.lowercased().components(separatedBy: .whitespaces))
        
        // Extract Vim commands mentioned (backtick patterns)
        let pattern = "`([^`]+)`"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(content.startIndex..., in: content)
            let matches = regex.matches(in: content, range: range)
            for match in matches {
                if let cmdRange = Range(match.range(at: 1), in: content) {
                    keywords.append(String(content[cmdRange]))
                }
            }
        }
        
        // Section-specific keywords
        let sectionKeywords: [String: [String]] = [
            "Modes": ["normal", "insert", "visual", "command", "replace", "mode"],
            "Movement": ["move", "navigate", "cursor", "jump", "motion", "go"],
            "Entering Insert Mode": ["insert", "type", "write", "append", "open"],
            "Editing": ["edit", "delete", "cut", "yank", "copy", "paste", "undo", "redo", "change"],
            "Text Objects": ["text object", "inner", "around", "word", "sentence", "paragraph", "quotes", "brackets"],
            "Visual Mode": ["visual", "select", "selection", "highlight", "block"],
            "Search and Replace": ["search", "find", "replace", "substitute", "pattern", "regex"],
            "Files and Buffers": ["file", "save", "open", "buffer", "quit", "exit", "write"],
            "Windows and Tabs": ["window", "split", "tab", "pane", "vertical", "horizontal"],
            "Macros": ["macro", "record", "replay", "repeat", "automation"],
            "Marks": ["mark", "bookmark", "position", "jump"],
            "Registers": ["register", "clipboard", "yank", "paste", "named"],
            "Folding": ["fold", "collapse", "expand", "hide"],
            "Common Patterns": ["pattern", "common", "example", "combination"],
            "Tips": ["tip", "advice", "trick", "efficient"]
        ]
        
        if let extraKeywords = sectionKeywords[title] {
            keywords.append(contentsOf: extraKeywords)
        }
        
        return Array(Set(keywords)) // Deduplicate
    }
    
    /// Create combined chunks for queries that span multiple topics
    private func createCombinedChunks(from chunks: [DocumentChunk]) -> [DocumentChunk] {
        var combined: [DocumentChunk] = []
        
        // Combine delete/edit related chunks
        let editChunks = chunks.filter { 
            ["Editing", "Text Objects", "Visual Mode"].contains($0.title) 
        }
        if editChunks.count > 1 {
            combined.append(DocumentChunk(
                title: "Editing and Text Objects",
                content: editChunks.map { $0.content }.joined(separator: "\n\n"),
                keywords: ["delete", "change", "edit", "text object", "visual", "yank", "cut"]
            ))
        }
        
        // Combine movement related
        let moveChunks = chunks.filter {
            ["Movement", "Entering Insert Mode"].contains($0.title)
        }
        if moveChunks.count > 1 {
            combined.append(DocumentChunk(
                title: "Navigation and Positioning",
                content: moveChunks.map { $0.content }.joined(separator: "\n\n"),
                keywords: ["move", "navigate", "cursor", "position", "jump", "go"]
            ))
        }
        
        return combined
    }
}

// MARK: - Extended VimDocs for RAG Integration

extension VimDocs {
    /// RAG-based context retrieval (replacement for the static contextForQuery)
    @MainActor
    static func ragContextForQuery(_ query: String) -> String {
        return RAGService.shared.contextForQuery(query)
    }
}
