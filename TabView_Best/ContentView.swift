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

struct SheetParams {
    let id: String
    var title: String?
    var data: Any?
    var extraParams: [String: Any]
    
    init(
        id: String,
        title: String? = nil,
        data: Any? = nil,
        extraParams: [String: Any] = [:]
    ) {
        self.id = id
        self.title = title
        self.data = data
        self.extraParams = extraParams
    }
}

// MARK: - SheetType
enum SheetType: Identifiable, Equatable {
    case profile(SheetParams)
    case settings(SheetParams)
    case detail(SheetParams)
    
    var id: String {
        switch self {
        case .profile(let params): return "profile_\(params.id)"
        case .settings(let params): return "settings_\(params.id)"
        case .detail(let params): return "detail_\(params.id)"
        }
    }
    
    // 添加显示方式属性
    var presentationStyle: PresentationStyle {
        switch self {
        case .profile: return .fullScreen    // 全屏显示
        case .settings: return .sheet        // sheet方式显示
        case .detail: return .sheet          // sheet方式显示
        }
    }
    
    static func == (lhs: SheetType, rhs: SheetType) -> Bool {
        lhs.id == rhs.id
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
    let onTap: (SheetType) -> Void
    
    static func == (lhs: SubItemRow, rhs: SubItemRow) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
    
    var body: some View {
        print("🔄 SubItemRow[\(id)] refreshed")
#if DEBUG
        let _ = Self._printChanges()
#endif
        return Button {
            // 传递多个参数
            let params = SheetParams(
                id: id,
                title: "Detail Title",
                data: ["key": "value"],
                extraParams: [
                    "color": UIColor.red,
                    "count": 42,
                    "isEnabled": true
                ]
            )
            onTap(.detail(params))
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
    let onShowSheet: (SheetType) -> Void
    
    static func == (lhs: TabRow, rhs: TabRow) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
    
    var body: some View {
        print("🔄 TabRow[\(id)] refreshed")
#if DEBUG
        let _ = Self._printChanges()
#endif
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
                // 传递多个参数
                let params = SheetParams(
                    id: id,
                    title: "Detail Title",
                    data: ["key": "value"],
                    extraParams: [
                        "color": UIColor.red,
                        "count": 42,
                        "isEnabled": true
                    ]
                )
                onShowSheet(.profile(params))
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
    let onShowSheet: (SheetType) -> ()  // 使用回调替代环境对象
    
    static func == (lhs: TabContent, rhs: TabContent) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.complexContent == rhs.complexContent
    }
    
    var body: some View {
        print("🔄 TabContent[\(id)] refreshed")
#if DEBUG
        let _ = Self._printChanges()
#endif
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

// MARK: - TabContainerView
struct TabContainerView: View, Equatable {
    let tab: TabConfig
    let onShowSheet: (SheetType) -> ()
    
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
    let onShowSheet: (SheetType) -> ()
    
    var body: some View {
        print("🔄 MainTabView refreshed")
#if DEBUG
        let _ = Self._printChanges()
#endif
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
        )
    ]
    
    var body: some View {
        print("🔄 ContentView refreshed")
#if DEBUG
        let _ = Self._printChanges()
#endif
        return MainTabView(
            tabs: tabs,
            onShowSheet: { sheetManager.showSheet($0) }
        )
//        // sheet展示
//        .sheet(item: Binding(
//            get: { sheetManager.activeSheet?.presentationStyle == .sheet ? sheetManager.activeSheet : nil },
//            set: { sheetManager.activeSheet = $0 }
//        )) { type in
//            presentSheet(type)
//        }
//        // 全屏展示
//        .fullScreenCover(item: Binding(
//            get: { sheetManager.activeSheet?.presentationStyle == .fullScreen ? sheetManager.activeSheet : nil },
//            set: { sheetManager.activeSheet = $0 }
//        )) { type in
//            presentSheet(type)
//        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
