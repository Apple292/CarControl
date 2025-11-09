import SwiftUI

struct Logs: View {
    @State private var logs: [LogEntry] = []
    @State private var isLoading = false
    
    struct LogEntry: Identifiable, Codable {
        let id: UUID
        let timestamp: String
        let message: String
        let level: String
    }
    
    var body: some View {
        NavigationStack {
            List(logs) { log in
                HStack {
                    VStack(alignment: .leading) {
                        Text(log.timestamp)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(log.message)
                            .font(.body)
                        
                        // Optional level indicator
                        Text(log.level)
                            .font(.caption)
                            .padding(4)
                            .background(levelColor(for: log.level))
                            .cornerRadius(4)
                    }
                }
            }
            .navigationTitle("Vehicle Logs")
            .refreshable {
                await fetchLogs()
            }
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                    }
                }
            )
            .onAppear {
                Task {
                    await fetchLogs()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                    
                        AppState.shared.logsOpen = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .imageScale(.medium)
                            Text("Back")
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
    }
    
    func levelColor(for level: String) -> Color {
        switch level.lowercased() {
        case "error": return .red
        case "warning": return .orange
        case "info": return .blue
        default: return .gray
        }
    }
    
    func fetchLogs() async {
        guard let url = URL(string: "https://your-logging-endpoint.com/logs") else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            logs = try JSONDecoder().decode([LogEntry].self, from: data)
        } catch {
            print("Failed to fetch logs: \(error)")
        }
    }
}


