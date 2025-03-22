import SwiftUI

//ContentView
//└── MainTabView
//    └── TabContainerView
//        └── ViewWrapper
//            └── TabContent
//                └── TabRow
//                    └── SubItemRow

// MARK: - Models
struct TabConfig: Equatable {
    let id: String
    let title: String
    let content: String
    let icon: String
}

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
            Text(UUID().uuidString)
                .foregroundStyle(Color.accentColor)
            
            Text(title)
                .font(.headline)
            
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

// MARK: - TabContent
struct TabContent: View, Equatable {
    let id: String
    let title: String
    let complexContent: String
    let onShowSheet: (String) -> Void  // 使用回调替代环境对象
    
    static func == (lhs: TabContent, rhs: TabContent) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.complexContent == rhs.complexContent
    }
    
    var body: some View {
        print("🔄 TabContent[\(id)] refreshed")
        
        return List {
            Section {
                Text(UUID().uuidString)
                    .foregroundStyle(Color.accentColor)
                
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
                        onShowSheet: onShowSheet
                    )
                    .equatable()
                }
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

// MARK: - TabContainerView
struct TabContainerView: View, Equatable {
    let tab: TabConfig
    let onShowSheet: (String) -> Void
    
    static func == (lhs: TabContainerView, rhs: TabContainerView) -> Bool {
        lhs.tab == rhs.tab
    }
    
    var body: some View {
        print("🔄 TabContainerView[\(tab.id)] refreshed")
        
        return ViewWrapper(id: "Tab\(tab.id)") {
            TabContent(
                id: tab.id,
                title: tab.title,
                complexContent: tab.content,
                onShowSheet: onShowSheet
            )
        }
    }
}

// MARK: - MainTabView
struct MainTabView: View {
    let tabs: [TabConfig]
    let onShowSheet: (String) -> Void
    
    var body: some View {
        print("🔄 MainTabView refreshed")
        
        return TabView {
            ForEach(tabs, id: \.id) { tab in
                TabContainerView(
                    tab: tab,
                    onShowSheet: onShowSheet
                )
                .equatable()
                .tabItem {
                    Label(tab.title, systemImage: tab.icon)
                }
            }
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var sheetManager = SheetObject()
    
    private let tabs = [
        TabConfig(
            id: "1",
            title: "First Tab",
            content: "This is the first tab with some complex content.",
            icon: "1.circle"
        ),
        TabConfig(
            id: "2",
            title: "Second Tab",
            content: "Second tab content showing optimized updates.",
            icon: "2.circle"
        ),
        TabConfig(
            id: "3",
            title: "Third Tab",
            content: "Third tab demonstrating performance benefits.",
            icon: "3.circle"
        )
    ]
    
    var body: some View {
        print("🔄 ContentView refreshed")
        
        return MainTabView(
            tabs: tabs,
            onShowSheet: { id in
                sheetManager.showSheet(.detail(id))
            }
        )
        .sheet(item: $sheetManager.activeSheet) { type in
            SheetView(type: type)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
