import Foundation
import MLX
import MLXLLM
import MLXLMCommon

/// Manages local LLM inference using MLX
@MainActor
class LLMService: ObservableObject {
    @Published var isLoading = true
    @Published var loadingStatus = "Ready to download"
    @Published var isGenerating = false
    @Published var hasStartedLoading = false

    private var modelContainer: ModelContainer?
    private let ragService = RAGService.shared

    /// The Llama 3.2 3B Instruct model in MLX 4-bit quantized format
    private let modelConfig = ModelConfiguration(
        id: "mlx-community/Llama-3.2-3B-Instruct-4bit"
    )

    func loadModel() async {
        guard !hasStartedLoading else { return }
        hasStartedLoading = true
        
        do {
            // Build RAG index while loading model
            loadingStatus = "Building search index..."
            ragService.buildIndex()
            
            loadingStatus = "Downloading model (first run only)..."

            modelContainer = try await LLMModelFactory.shared.loadContainer(
                configuration: modelConfig
            ) { progress in
                Task { @MainActor in
                    self.loadingStatus = "Downloading: \(Int(progress.fractionCompleted * 100))%"
                }
            }

            isLoading = false
            loadingStatus = "Ready"
            print("✅ Model loaded successfully")
        } catch {
            loadingStatus = "Failed to load model: \(error.localizedDescription)"
            print("❌ Model load error: \(error)")
        }
    }

    func generate(query: String, history: [ChatMessage] = []) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                guard let container = modelContainer else {
                    continuation.yield("⚠️ Model not loaded yet. Please wait...")
                    continuation.finish()
                    return
                }

                isGenerating = true

                // Build chat messages with conversation history
                var messages: [[String: String]] = [
                    ["role": "system", "content": VimDocs.systemPrompt]
                ]
                
                // Add conversation history for context
                for msg in history.suffix(6) {
                    messages.append([
                        "role": msg.role == .user ? "user" : "assistant",
                        "content": msg.content
                    ])
                }
                
                // Add current query with RAG-retrieved context
                let prompt = ragService.contextForQuery(query)
                messages.append(["role": "user", "content": prompt])

                do {
                    let input = try await container.perform { context in
                        try await context.processor.prepare(input: .init(messages: messages))
                    }

                    let maxTokens = 512

                    let result = try await container.perform { context in
                        try MLXLMCommon.generate(
                            input: input,
                            parameters: .init(temperature: 0.6, topP: 0.9, repetitionPenalty: 1.1),
                            context: context
                        ) { tokens in
                            if tokens.count >= maxTokens {
                                return .stop
                            }

                            let text = context.tokenizer.decode(tokens: [tokens.last!])
                            continuation.yield(text)
                            return .more
                        }
                    }

                    _ = result // generation complete

                    isGenerating = false
                    continuation.finish()
                } catch {
                    continuation.yield("\n\n⚠️ Error: \(error.localizedDescription)")
                    isGenerating = false
                    continuation.finish()
                }
            }
        }
    }
}
