import SwiftUI

// MARK: - SheetType
enum SheetType: Identifiable, Equatable {
    case profile
    case settings
    case detail(String)
    
    var id: String {
        switch self {
        case .profile: return "profile"
        case .settings: return "settings"
        case .detail(let id): return "detail_\(id)"
        }
    }
}

// MARK: - SheetObject
final class SheetObject: ObservableObject {
    @Published var activeSheet: SheetType?
    
    func showSheet(_ type: SheetType) {
        print("📤 Showing sheet: \(type.id)")
        activeSheet = type
    }
}

// MARK: - ViewWrapper
struct ViewWrapper<Content: View>: View {
    let id: String
    let content: Content
    
    init(id: String, @ViewBuilder content: () -> Content) {
        self.id = id
        self.content = content()
        print("📦 ViewWrapper[\(id)] initialized")
    }
    
    var body: some View {
        content
            .id(id)
            .onAppear {
                print("👋 ViewWrapper[\(id)] appeared")
            }
    }
}

// MARK: - SubItemRow
struct SubItemRow: View, Equatable {
    let id: String
    let title: String
    let onTap: (String) -> Void
    
    static func == (lhs: SubItemRow, rhs: SubItemRow) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
    
    var body: some View {
        print("🔄 SubItemRow[\(id)] refreshed")
        
        return Button {
            onTap(id)
        } label: {
            Text(title)
                .foregroundColor(.blue)
                .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TabRow
struct TabRow: View, Equatable {
    let id: String
    let title: String
    let onShowSheet: (String) -> Void
    
    static func == (lhs: TabRow, rhs: TabRow) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
    
    var body: some View {
        print("🔄 TabRow[\(id)] refreshed")
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            // 子项目
            ForEach(0..<2) { index in
                SubItemRow(
                    id: "\(id)_sub_\(index)",
                    title: "SubItem \(index)",
                    onTap: { subId in
                        onShowSheet(subId)
                    }
                )
                .equatable()
            }
            
            Button("Show Row Sheet") {
                onShowSheet(id)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - SectionHeader
struct SectionHeader: View, Equatable {
    let title: String
    
    static func == (lhs: SectionHeader, rhs: SectionHeader) -> Bool {
        lhs.title == rhs.title
    }
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
    }
}

// MARK: - TabContent
struct TabContent: View, Equatable {
    let id: String
    let title: String
    let complexContent: String
    @EnvironmentObject private var sheetManager: SheetObject
    
    static func == (lhs: TabContent, rhs: TabContent) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.complexContent == rhs.complexContent
    }
    
    var body: some View {
        print("🔄 TabContent[\(id)] refreshed")
        
        return List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tab ID: \(id)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(title)
                        .font(.title2)
                    
                    Text(complexContent)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                ForEach(0..<2) { index in
                    TabRow(
                        id: "\(index)",
                        title: "Row \(index)",
                        onShowSheet: { rowId in
                            sheetManager.showSheet(.detail(rowId))
                        }
                    )
                    .equatable()
                }
            } header: {
                SectionHeader(title: "Items")
                    .equatable()
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - SheetView
struct SheetView: View {
    let type: SheetType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Content for: \(type.id)")
                    .font(.headline)
                    .padding()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var sheetManager = SheetObject()
    
    var body: some View {
        print("🔄 ContentView refreshed")
        
        return TabView {
            ViewWrapper(id: "Tab1") {
                TabContent(
                    id: "1",
                    title: "First Tab",
                    complexContent: "This is the first tab with some complex content that demonstrates the performance optimization."
                )
            }
            .tabItem {
                Label("Tab 1", systemImage: "1.circle")
            }
            
            ViewWrapper(id: "Tab2") {
                TabContent(
                    id: "2",
                    title: "Second Tab",
                    complexContent: "Second tab content showing how updates are isolated and optimized."
                )
            }
            .tabItem {
                Label("Tab 2", systemImage: "2.circle")
            }
            
            ViewWrapper(id: "Tab3") {
                TabContent(
                    id: "3",
                    title: "Third Tab",
                    complexContent: "Third tab demonstrating the performance benefits of proper Equatable implementations."
                )
            }
            .tabItem {
                Label("Tab 3", systemImage: "3.circle")
            }
        }
        .sheet(item: $sheetManager.activeSheet) { type in
            SheetView(type: type)
        }
        .environmentObject(sheetManager)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
