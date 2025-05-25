//
//  Mock33.swift
//  TabView_Best
//
//  Created by kidstyo on 2025/4/21.
//

import SwiftUI

struct C_Tab: Identifiable, Hashable {
    var id: String
    var name: String
}

struct C_Note: Identifiable {
    var id: UUID = UUID()
    var name: String
}

struct C_Task: Identifiable {
    var id: UUID = UUID()
    var name: String
    var isComplete: Bool
    var timeStamp: Date
}

struct Page_Data: Identifiable {
    var id: UUID = UUID()

    var notes: [C_Note]
    var tasks: [C_Task]
}

enum PageType: String, CaseIterable {
    case today
    case week
    case year
}

class Mock33_VM: ObservableObject {
    @Published var pages: [C_Tab]
    @Published var page_data_dic: [String: Page_Data]

    init() {
        var pps: [C_Tab] = []
        var pdatadic: [String: Page_Data] = [:]
        for pageType in PageType.allCases{
            pps.append(C_Tab(id: pageType.rawValue, name: pageType.rawValue))
            pdatadic[pageType.rawValue] = Page_Data(notes: [C_Note(name: "Note Test")], tasks: [C_Task(name: "Hello Task", isComplete: true, timeStamp: .init())])
        }
 
        self.pages = pps
        self.page_data_dic = pdatadic
    }
}

// MARK: - 包装器视图，使用 Equatable
struct MockPageContainer: View, Equatable {
    let tab: C_Tab
    let page_data: Page_Data?
    let onClickToFirst: () -> ()
    let onShowSheet: (ClickType) -> Void
    
    static func == (lhs: MockPageContainer, rhs: MockPageContainer) -> Bool {
        lhs.tab == rhs.tab && lhs.page_data?.id == rhs.page_data?.id
    }
    
    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        return MockPage(
            tab: tab,
            page_data: page_data,
            onClickToFirst: onClickToFirst,
            onClick: onShowSheet
        )
    }
}

struct Mock33: View {
    @StateObject var vm = Mock33_VM()
    @State private var selectTabId: String = ""
    @State private var activeSheet: ClickType? // 直接使用 @State

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        return TabView(selection: $selectTabId) {
            ForEach(vm.pages) { page in
                MockPageContainer(
                    tab: page,
                    page_data: vm.page_data_dic[page.id],
                    onClickToFirst: {
                        selectTabId = vm.pages.first?.id ?? ""
                    },
                    onShowSheet: { clickType in
                        handleClick(clickType, for: page)
                    }
                )
                .equatable() // 关键：使用 equatable 修饰符
                .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onAppear(perform: {
            // 设置默认选中的 tab
            selectTabId = vm.pages.first?.id ?? ""
        })
        // sheet展示
        .sheet(item: Binding(
            get: { activeSheet?.presentationStyle == .sheet ? activeSheet : nil },
            set: { activeSheet = $0 }
        )) { type in
            presentSheet(type)
        }
        // 全屏展示
        .fullScreenCover(item: Binding(
            get: { activeSheet?.presentationStyle == .fullScreen ? activeSheet : nil },
            set: { activeSheet = $0 }
        )) { type in
            presentSheet(type)
        }
    }
    
    private func handleClick(_ clickType: ClickType, for page: C_Tab) {
        switch clickType {
        case .profile(let clickParams):
            activeSheet = clickType
        case .settings(let clickParams):
            activeSheet = clickType
        case .detail(let clickParams):
            activeSheet = clickType
        case .edit_note(let c_Note):
            if let c_Note = c_Note {
                activeSheet = clickType
            } else {
                vm.page_data_dic[page.id]?.notes.append(C_Note(name: "New Note"))
            }
        }
    }
    
    @ViewBuilder
    private func presentSheet(_ type: ClickType) -> some View {
        switch type {
        case .profile(let params):
            ClickView(type: type)
        case .settings(let params):
            ClickView(type: type)
        case .detail(_):
            ClickView(type: type)
        case .edit_note(_):
            ClickView(type: type)
        }
    }
}

// MARK: - 优化 MockPage，使其支持 Equatable
struct MockPage: View, Equatable {
    var tab: C_Tab
    var page_data: Page_Data?
    
    var onClickToFirst: () -> ()
    let onClick: (ClickType) -> Void
    
    static func == (lhs: MockPage, rhs: MockPage) -> Bool {
        lhs.tab == rhs.tab && lhs.page_data?.id == rhs.page_data?.id
    }

    var body: some View{
#if DEBUG
let _ = Self._printChanges()
#endif
        return List {
            Section {
                Text(tab.name)
                    .font(.title)
            }

            Text(UUID().uuidString)
            
            Section {
                ForEach(page_data?.notes ?? []){note in
                    Button {
                        onClick(.edit_note(note))
                    } label: {
                        MockPage_Row(note: note)
                    }
                }
                
                Button {
                    onClick(.edit_note(nil))
                } label: {
                    Text("add note")
                }
                .buttonStyle(.borderedProminent)
            } header: {
                Text("Page Note: \(page_data?.notes.count ?? 0)")
            }
         
            Button {
                onClickToFirst()
            } label: {
                Text("back to first")
            }
        }
    }
}

// MARK: - 优化 MockPage_Row
struct MockPage_Row: View, Equatable {
    var note: C_Note
    @State private var rowUUID = UUID() // 使用 @State 保持 UUID 稳定
    
    static func == (lhs: MockPage_Row, rhs: MockPage_Row) -> Bool {
        lhs.note.id == rhs.note.id && lhs.note.name == rhs.note.name
    }
    
    var body: some View{
#if DEBUG
let _ = Self._printChanges()
#endif
        return HStack {
            Text(rowUUID.uuidString) // 使用稳定的 UUID
            Text(note.name)
        }
    }
}

// MARK: - 其余代码保持不变
struct ClickParams {
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

enum ClickType: Identifiable, Equatable {
    case profile(ClickParams)
    case settings(ClickParams)
    case detail(ClickParams)
    case edit_note(C_Note?)
    
    var id: String {
        switch self {
        case .profile(let params): return "profile_\(params.id)"
        case .settings(let params): return "settings_\(params.id)"
        case .detail(let params): return "detail_\(params.id)"
        case .edit_note(let params): return "edit_note_\(params?.id.uuidString ?? "new")"
        }
    }
    
    // 添加显示方式属性
    var presentationStyle: PresentationStyle {
        switch self {
        case .profile: return .fullScreen    // 全屏显示
        case .settings: return .sheet        // sheet方式显示
        case .detail, .edit_note: return .sheet          // sheet方式显示
        }
    }
    
    static func == (lhs: ClickType, rhs: ClickType) -> Bool {
        lhs.id == rhs.id
    }
}

// 添加 PresentationStyle 枚举
enum PresentationStyle {
    case sheet
    case fullScreen
}

// MARK: - ClickView
struct ClickView: View {
    let type: ClickType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        NavigationView {
            VStack(spacing: 20) {
                switch type {
                case .profile(let params):
                    Text("Profile View")
                        .font(.title)
                    Text("ID: \(params.id)")
                    if let title = params.title {
                        Text("Title: \(title)")
                    }
                    
                case .settings(let params):
                    Text("Settings View")
                        .font(.title)
                    Text("ID: \(params.id)")
                    
                case .detail(let params):
                    Text("Detail View")
                        .font(.title)
                    Text("ID: \(params.id)")
                    
                case .edit_note(let note):
                    Text("Edit Note")
                        .font(.title)
                    if let note = note {
                        Text("Editing: \(note.name)")
                        Text("ID: \(note.id.uuidString)")
                    } else {
                        Text("Creating New Note")
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(navigationTitle)
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
    
    private var navigationTitle: String {
        switch type {
        case .profile: return "Profile"
        case .settings: return "Settings"
        case .detail: return "Detail"
        case .edit_note(let note): return note != nil ? "Edit Note" : "New Note"
        }
    }
}

#Preview {
    Mock33()
}
