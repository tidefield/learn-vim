import Foundation
import Accelerate

/// Lightweight embedding service using TF-IDF with semantic enhancements
/// Can be upgraded to neural embeddings (e.g., MLX-based) in the future
class EmbeddingService {
    
    static let shared = EmbeddingService()
    
    /// Vocabulary built from the corpus
    private var vocabulary: [String: Int] = [:]
    private var idfScores: [String: Float] = [:]
    private var isInitialized = false
    
    /// Vim-specific synonyms for semantic matching
    private let synonyms: [String: [String]] = [
        "delete": ["remove", "cut", "erase", "kill"],
        "copy": ["yank", "duplicate"],
        "paste": ["put"],
        "word": ["token", "text"],
        "line": ["row"],
        "search": ["find", "look", "locate"],
        "replace": ["substitute", "change", "swap"],
        "move": ["navigate", "go", "jump", "motion"],
        "insert": ["type", "add", "write"],
        "select": ["highlight", "visual", "mark"],
        "undo": ["revert", "reverse"],
        "file": ["buffer", "document"],
        "save": ["write", "store"],
        "quit": ["exit", "close", "leave"],
        "window": ["split", "pane"],
        "tab": ["page"],
        "macro": ["record", "replay", "automation"],
        "fold": ["collapse", "hide"],
        "indent": ["tab", "spacing"],
        "bracket": ["brace", "paren", "parenthesis"],
        "quote": ["string", "quoted"],
    ]
    
    private init() {}
    
    /// Build vocabulary and IDF scores from a corpus of documents
    func buildIndex(from documents: [String]) {
        var documentFrequency: [String: Int] = [:]
        var allTerms = Set<String>()
        
        for doc in documents {
            let terms = tokenize(doc)
            let uniqueTerms = Set(terms)
            
            for term in uniqueTerms {
                documentFrequency[term, default: 0] += 1
                allTerms.insert(term)
            }
        }
        
        // Build vocabulary index
        vocabulary = [:]
        for (index, term) in allTerms.sorted().enumerated() {
            vocabulary[term] = index
        }
        
        // Calculate IDF scores
        let n = Float(documents.count)
        idfScores = [:]
        for (term, df) in documentFrequency {
            idfScores[term] = log(n / Float(df)) + 1.0
        }
        
        isInitialized = true
    }
    
    /// Generate embedding vector for text using TF-IDF
    func embed(_ text: String) -> [Float] {
        guard isInitialized else { return [] }
        
        let terms = tokenize(text)
        var vector = [Float](repeating: 0, count: vocabulary.count)
        
        // Calculate term frequencies
        var termFreq: [String: Int] = [:]
        for term in terms {
            termFreq[term, default: 0] += 1
        }
        
        // Build TF-IDF vector
        for (term, tf) in termFreq {
            // Check direct term
            if let idx = vocabulary[term], let idf = idfScores[term] {
                let tfNorm = Float(tf) / Float(terms.count)
                vector[idx] = tfNorm * idf
            }
            
            // Also boost synonyms (at lower weight)
            if let synonymList = findSynonyms(for: term) {
                for synonym in synonymList {
                    if let idx = vocabulary[synonym], let idf = idfScores[synonym] {
                        let tfNorm = Float(tf) / Float(terms.count) * 0.5 // 50% weight for synonyms
                        vector[idx] = max(vector[idx], tfNorm * idf)
                    }
                }
            }
        }
        
        // L2 normalize
        return normalize(vector)
    }
    
    /// Compute cosine similarity between two vectors
    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        
        var dot: Float = 0
        vDSP_dotpr(a, 1, b, 1, &dot, vDSP_Length(a.count))
        
        return dot // Vectors are already normalized
    }
    
    // MARK: - Private Helpers
    
    private func tokenize(_ text: String) -> [String] {
        let lowercased = text.lowercased()
        
        // Split on non-alphanumeric, keep Vim-specific tokens
        let pattern = "[a-z0-9]+|`[^`]+`|ctrl\\+[a-z]"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(lowercased.startIndex..., in: lowercased)
        
        var tokens: [String] = []
        regex?.enumerateMatches(in: lowercased, options: [], range: range) { match, _, _ in
            if let matchRange = match?.range, let range = Range(matchRange, in: lowercased) {
                tokens.append(String(lowercased[range]))
            }
        }
        
        // Remove common stopwords but keep Vim-relevant ones
        let stopwords: Set<String> = ["the", "a", "an", "is", "are", "was", "were", "be", "been", 
                                       "being", "have", "has", "had", "do", "does", "did", "will",
                                       "would", "could", "should", "may", "might", "must", "shall",
                                       "can", "this", "that", "these", "those", "am", "or", "and",
                                       "but", "if", "then", "else", "when", "where", "why", "how",
                                       "all", "each", "every", "both", "few", "more", "most", "other",
                                       "some", "such", "no", "nor", "not", "only", "own", "same", "so",
                                       "than", "too", "very", "just", "also", "now", "here", "there"]
        
        return tokens.filter { !stopwords.contains($0) && $0.count > 1 }
    }
    
    private func findSynonyms(for term: String) -> [String]? {
        // Direct lookup
        if let syns = synonyms[term] {
            return syns
        }
        // Reverse lookup
        for (key, values) in synonyms {
            if values.contains(term) {
                return [key] + values.filter { $0 != term }
            }
        }
        return nil
    }
    
    private func normalize(_ vector: [Float]) -> [Float] {
        var sumSquares: Float = 0
        vDSP_svesq(vector, 1, &sumSquares, vDSP_Length(vector.count))
        
        let magnitude = sqrt(sumSquares)
        guard magnitude > 0 else { return vector }
        
        var result = [Float](repeating: 0, count: vector.count)
        var mag = magnitude
        vDSP_vsdiv(vector, 1, &mag, &result, 1, vDSP_Length(vector.count))
        
        return result
    }
}
