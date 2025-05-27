//
//  Mock33.swift
//  TabView_Best
//
//  Created by kidstyo on 2025/4/21.
//

import SwiftUI

enum PresentationStyle {
    case sheet
    case fullScreen
}

struct C_Tab: Identifiable, Hashable, Equatable {
    var id: String
    var name: String
}

struct C_Note: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
}

struct C_Task: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var isComplete: Bool
    var timeStamp: Date
}

// MARK: - 修改 Page_Data 为 ObservableObject
class Page_Data: ObservableObject, Identifiable {
    let id: UUID = UUID()
    
    @Published var notes: [C_Note]
    @Published var tasks: [C_Task]
    
    init(notes: [C_Note], tasks: [C_Task]) {
        self.notes = notes
        self.tasks = tasks
    }
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

// 添加 AlertInfo 结构体
struct AlertInfo: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    
    struct AlertButton: Equatable {
        let title: String
        let role: ButtonRole?
        let action: () -> Void
        
        static func == (lhs: AlertButton, rhs: AlertButton) -> Bool {
            lhs.title == rhs.title && lhs.role == rhs.role
        }
    }
}

struct Mock33: View {
    @StateObject var vm = Mock33_VM()
    @State private var selectTabId: String = ""
    @State private var activeSheet: ClickType?
    @State private var alertInfo: AlertInfo?  // 添加 alert 状态

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        return TabView(selection: $selectTabId) {
            ForEach(vm.pages) { page in
                if let page_data = vm.page_data_dic[page.id] {
                    MockPage(
                        tab: page,
                        page_data: page_data,
                        onClickToFirst: {
                            withAnimation {
                                selectTabId = vm.pages.first?.id ?? ""
                            }
                        },
                        onClick: { clickType in
                            handleClick(clickType, for: page)
                        }
                    )
                    .equatable() // 关键：使用 equatable 修饰符
                    .tag(page.id)
                } else {
                    Text("No data for \(page.name)")
                        .tag(page.id)
                }
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
        // 添加 alert 修饰符
        .alert(item: $alertInfo) { info in
            Alert(
                title: Text(info.title),
                message: Text(info.message),
                primaryButton: .destructive(Text(info.primaryButton.title)) {
                    info.primaryButton.action()
                },
                secondaryButton: .cancel(Text(info.secondaryButton?.title ?? "取消"))
            )
        }
    }
    
    private func handleClick(_ clickType: ClickType, for page: C_Tab) {
        switch clickType {
        case .settings(let clickParams):
            activeSheet = clickType
        case .edit_note(let c_Note):
            if let c_Note = c_Note {
                activeSheet = clickType
            } else {
                withAnimation {
                    // 直接添加到 ObservableObject 中，会自动触发更新
                    vm.page_data_dic[page.id]?.notes.append(C_Note(name: "New Note"))
                }
            }
        case .delete_note(let note):
            // 显示删除确认 alert
            alertInfo = AlertInfo(
                title: "确认删除",
                message: "确定要删除笔记 \"\(note.name)\" 吗？此操作不可撤销。",
                primaryButton: AlertInfo.AlertButton(
                    title: "删除",
                    role: .destructive,
                    action: {
                        // 执行删除操作
                        if let index = vm.page_data_dic[page.id]?.notes.firstIndex(where: {$0 == note}) {
                            withAnimation {
                                vm.page_data_dic[page.id]?.notes.remove(at: index)
                            }
                        }
                    }
                ),
                secondaryButton: AlertInfo.AlertButton(
                    title: "取消",
                    role: .cancel,
                    action: {}
                )
            )
        case .delete_all_notes:
            // 显示删除全部确认 alert
            let notesCount = vm.page_data_dic[page.id]?.notes.count ?? 0
            if notesCount > 0 {
                alertInfo = AlertInfo(
                    title: "确认删除全部",
                    message: "确定要删除全部 \(notesCount) 条笔记吗？此操作不可撤销。",
                    primaryButton: AlertInfo.AlertButton(
                        title: "删除全部",
                        role: .destructive,
                        action: {
                            // 执行删除全部操作
                            withAnimation {
                                vm.page_data_dic[page.id]?.notes.removeAll()
                            }
                        }
                    ),
                    secondaryButton: AlertInfo.AlertButton(
                        title: "取消",
                        role: .cancel,
                        action: {}
                    )
                )
            }
        case .alert(let info):
            alertInfo = info
        default:
            activeSheet = clickType
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
        default: ClickView(type: type)
        }
    }
}

// MARK: - 修改 MockPage，添加 Equatable 支持
struct MockPage: View, Equatable {
    var tab: C_Tab
    @ObservedObject var page_data: Page_Data
    
    var onClickToFirst: () -> ()
    let onClick: (ClickType) -> Void
    
    // 实现 Equatable，只比较 tab，让 page_data 的变化能触发更新
    static func == (lhs: MockPage, rhs: MockPage) -> Bool {
        lhs.tab == rhs.tab
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

            Text(String(UUID().uuidString.suffix(3)))
            
            Section {
                ForEach(page_data.notes){note in
                    Button {
                        onClick(.edit_note(note))
                    } label: {
                        MockPage_Row(note: note, onClick: onClick)
                    }
                }
                
                HStack {
                    Button {
                        onClick(.edit_note(nil))
                    } label: {
                        Text("add note")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    
                    // 添加删除全部按钮
                    if !page_data.notes.isEmpty {
                        Button {
                            onClick(.delete_all_notes)
                        } label: {
                            Text("delete all")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            } header: {
                Text("Page Note: \(page_data.notes.count)")
            }
         
            Button {
                onClickToFirst()
            } label: {
                Text("back to first")
            }
            
            Button {
                onClick(.full_screen)
            } label: {
                Text("full screen")
            }
        }
    }
}

// MARK: - 优化 MockPage_Row
struct MockPage_Row: View, Equatable {
    var note: C_Note
    let onClick: (ClickType) -> Void

    static func == (lhs: MockPage_Row, rhs: MockPage_Row) -> Bool {
        lhs.note.id == rhs.note.id && lhs.note.name == rhs.note.name
    }
    
    var body: some View{
#if DEBUG
let _ = Self._printChanges()
#endif
        return HStack {
            VStack(alignment: .leading) {
                Text(String(UUID().uuidString.suffix(3)))
                    .foregroundColor(.primary)
                Text(note.name)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    onClick(.delete_note(note))
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
            }
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
    case delete_note(C_Note)
    case delete_all_notes  // 新增删除全部 case
    case full_screen
    case alert(AlertInfo)
    
    var id: String {
        switch self {
        case .profile(let params): return "profile_\(params.id)"
        case .settings(let params): return "settings_\(params.id)"
        case .detail(let params): return "detail_\(params.id)"
        case .edit_note(let params): return "edit_note_\(params?.id.uuidString ?? "new")"
        case .delete_note(let params): return "delete_note_\(params.id.uuidString)"
        case .delete_all_notes: return "delete_all_notes"
        case .full_screen: return "full_screen"
        case .alert(let info): return "alert_\(info.id)"
        }
    }
    
    // 添加显示方式属性
    var presentationStyle: PresentationStyle {
        switch self {
        case .profile: return .fullScreen    // 全屏显示
        case .settings: return .sheet        // sheet方式显示
        case .detail, .edit_note: return .sheet          // sheet方式显示
        case .full_screen: return .fullScreen
        case .alert, .delete_all_notes: return .sheet  // alert 不需要这个，但保持一致性
        default: return .sheet
        }
    }
    
    static func == (lhs: ClickType, rhs: ClickType) -> Bool {
        lhs.id == rhs.id
    }
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
                default:
                    Text(type.id)
                        .font(.title)
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
        default: return "Title"
        }
    }
}

#Preview {
    Mock33()
}
