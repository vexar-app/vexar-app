import SwiftUI

struct LogsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var contentHeight: CGFloat = 200 // Default small height
    
    var body: some View {
        ZStack {
            Color.vexarBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.white)
                        Text(String(localized: "logs"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(.ultraThinMaterial)
                
                // Logs Content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            // Use enumerated to get stable IDs for scrolling
                            ForEach(Array(appState.logs.enumerated()), id: \.offset) { index, message in
                                Text(message)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(logColor(for: message))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled) // Allow copying text
                                    .id(index)
                            }
                        }
                        .padding(16)
                        .readHeight { height in
                            let newHeight = height + 100
                            if abs(contentHeight - newHeight) > 1 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        contentHeight = newHeight
                                    }
                                }
                            }
                        }
                    }
                    .onChange(of: appState.logs.count) { count in
                        if count > 0 {
                            withAnimation {
                                proxy.scrollTo(count - 1, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Footer Actions
                HStack {
                    Button(action: {
                        appState.clearLogs()
                    }) {
                        Label("Temizle", systemImage: "trash")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button(action: {
                        let text = appState.logs.joined(separator: "\n")
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(text, forType: .string)
                    }) {
                        Label("Kopyala", systemImage: "doc.on.doc")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(.ultraThinMaterial)
            }
        }


        .background(GeometryReader { _ in
            Color.clear.preference(key: ViewHeightKey.self, value: min(max(contentHeight, 200), 500))
        })
        .navigationBarBackButtonHidden(true)
    }
    
    private func logColor(for message: String) -> Color {
        if message.contains("error") || message.contains("fail") || message.contains("❌") { return .red }
        if message.contains("warn") || message.contains("⚠️") { return .orange }
        if message.contains("success") || message.contains("connected") || message.contains("✅") { return .green }
        return .secondary
    }
}
