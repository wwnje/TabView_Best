import SwiftUI

enum Page_Header_Type: String, CaseIterable {
    case note_day
    case task_day
    case task_week
}

enum Test_PresentationStyle {
    case sheet
    case fullScreen
}

struct App_Page: Identifiable, Hashable, Equatable {
    var id: String
    
    // tab_name
    var name: String
}

struct C_Book: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
}

struct C_Task: Identifiable, Equatable {
    var id: UUID = UUID()
    var task_type: String
    var name: String
    var isComplete: Bool
}

@Observable
class Test_Page_Data: Identifiable {
    let id: UUID = UUID()
    
    var notes: [C_Book]
    var page_headers: [Page_Header_Type] = []
    var task_dic: [Page_Header_Type: [C_Task]]
    
    init(notes: [C_Book], page_headers: [Page_Header_Type], task_dic: [Page_Header_Type : [C_Task]]) {
        self.notes = notes
        self.page_headers = page_headers
        self.task_dic = task_dic
    }
}

enum PageType: String, CaseIterable {
    case today
    case week
    case year
    case life
    case box
}

@Observable
class Test_Home_VM {
    var pages: [App_Page]
    var page_data_dic: [String: Test_Page_Data]
    
    init() {
        var pps: [App_Page] = []
        for pageType in PageType.allCases{
            pps.append(App_Page(id: pageType.rawValue, name: pageType.rawValue))
        }
        
        var headers: [Page_Header_Type] = []
        for headerType in Page_Header_Type.allCases{
            headers.append(headerType)
        }
        
        var pdatadic: [String: Test_Page_Data] = [:]
        for pageType in PageType.allCases{
            let task_dic: [Page_Header_Type: [C_Task]] = [
                Page_Header_Type.task_day:
                    [C_Task(task_type: Page_Header_Type.task_day.rawValue, name: "Hello Day Task", isComplete: true)],
                Page_Header_Type.task_week:
                    [C_Task(task_type: Page_Header_Type.task_week.rawValue, name: "Hello Week Task", isComplete: true)]]
            pdatadic[pageType.rawValue] = Test_Page_Data(notes: [C_Book(name: "Note Test")], page_headers: headers, task_dic: task_dic )
        }
        
        self.pages = pps
        self.page_data_dic = pdatadic
    }
    
    func add_note(pageId: String){
        let newNote = C_Book(name: "New Note")
        page_data_dic[pageId]?.notes.append(newNote)
        print("add note: \(newNote.id)")
    }
    
    func add_task(pageId: String, header_type: Page_Header_Type){
        let newTask = C_Task(task_type: header_type.rawValue, name: "Hello Task: \(String(UUID().uuidString.suffix(3)))", isComplete: true)
        page_data_dic[pageId]?.task_dic[header_type]?.append(newTask)
    }
}

struct Test_Home_Page: View, Equatable {
    var tab: App_Page
    var page_data: Test_Page_Data
    
    var onClickToFirst: () -> ()
    let onClick: (Test_Click_Type) -> Void
    
    // 实现 Equatable，只比较 tab，让 page_data 的变化能触发更新
    static func == (lhs: Test_Home_Page, rhs: Test_Home_Page) -> Bool {
        lhs.tab == rhs.tab
    }
    
    var body: some View{
#if DEBUG
        let _ = Self._printChanges()
#endif
        List {
            Section {
                Text(tab.name)
                    .font(.largeTitle)
            }
            
            Text("Page ID: \(String(UUID().uuidString.suffix(3)))")
            
            ForEach(page_data.page_headers, id: \.self) { header_type in
                if header_type == .note_day {
                    Block_Note(notes: page_data.notes, onClick: onClick)
                } else {
                    Block_Task(
                        tasks: page_data.task_dic[header_type] ?? [],
                        header_type: header_type,
                        onClick: onClick
                    )
                }
            }

        }
        .listStyle(.plain)
        .overlay(alignment: .top) {
            HStack {
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
            .buttonStyle(.borderedProminent)
        }
    }
}

struct Block_Note: View, Equatable {
    var notes: [C_Book]
    let onClick: (Test_Click_Type) -> Void
    
    static func == (lhs: Block_Note, rhs: Block_Note) -> Bool {
        lhs.notes == rhs.notes
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Section {
            Text("Block ID: \(String(UUID().uuidString.suffix(3)))")

            ForEach(notes) { note in
                Button {
                    onClick(.edit_note(note))
                } label: {
                    Page_Note_Row(note: note, onClick: onClick)
                }
                .contextMenu {
                    Button {
//                        if let index = notes.firstIndex(where: {$0 == note}){
//                            notes[index].name = "Note: \(UUID().uuidString.prefix(3))"
//                        }
                    } label: {
                        Text("rename")
                    }
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
                
                Button {
                    onClick(.delete_all_notes)
                } label: {
                    Text("delete all")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        } header: {
            Text("Notes: \(notes.count)")
        }
    }
}

struct Block_Task: View, Equatable {
    var tasks: [C_Task]
    let header_type: Page_Header_Type
    let onClick: (Test_Click_Type) -> Void
    
    // 只比较当前 header_type 对应的 tasks
    static func == (lhs: Block_Task, rhs: Block_Task) -> Bool {
        lhs.tasks == rhs.tasks && lhs.header_type == rhs.header_type
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Section {
            Text("Block ID: \(String(UUID().uuidString.suffix(3)))")

            ForEach(tasks) { task in
                Button {
                    onClick(.edit_task(header_type, task))
                } label: {
                    Page_Task_Row(task: task, onClick: onClick)
                }
                .contextMenu {
//                    Button {
//                        if let index = tasks.firstIndex(where: { $0 == task }) {
//                            tasks[index].name = "Task: \(UUID().uuidString.prefix(3))"
//                        }
//                    } label: {
//                        Text("rename")
//                    }
                }
            }
            
            HStack {
                Button {
                    onClick(.edit_task(header_type, nil))
                } label: {
                    Text("add task")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                    
                Button {
                    onClick(.delete_all_tasks(header_type))
                } label: {
                    Text("delete all")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        } header: {
            Text("\(header_type.rawValue): \(tasks.count)")
        }
    }
}


struct Page_Note_Row: View, Equatable {
    var note: C_Book
    let onClick: (Test_Click_Type) -> Void
    
    static func == (lhs: Page_Note_Row, rhs: Page_Note_Row) -> Bool {
        lhs.note.id == rhs.note.id && lhs.note.name == rhs.note.name
    }
    
    var body: some View{
#if DEBUG
        let _ = Self._printChanges()
#endif
        HStack {
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
                    .foregroundStyle(.red)
            }
        }
    }
}

struct Page_Task_Row: View, Equatable {
    var task: C_Task
    let onClick: (Test_Click_Type) -> Void
    
    static func == (lhs: Page_Task_Row, rhs: Page_Task_Row) -> Bool {
        lhs.task.id == rhs.task.id && lhs.task.name == rhs.task.name
    }
    
    var body: some View{
#if DEBUG
        let _ = Self._printChanges()
#endif
        HStack {
            VStack(alignment: .leading) {
                Text(String(UUID().uuidString.suffix(3)))
                    .foregroundColor(.primary)
                Text(task.name)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    onClick(.delete_task(task))
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
    }
}

struct ClickView: View {
    let type: Test_Click_Type
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        let params = extractParams(from: type)
        NavigationView {
            VStack(spacing: 20) {
                if let params = params{
                    Text("ID: \(params.id)")
                    if let title = params.title {
                        Text("Title: \(title)")
                    }
                    if let data = params.data {
                        Text("Data: \(String(describing: data))")
                    }
                    
                    ForEach(Array(params.extraParams.keys), id: \.self) { key in
                        Text("\(key): \(String(describing: params.extraParams[key]!))")
                    }
                }
                
                switch type {
                case .profile(let params):
                    Text("Profile View")
                        .font(.title)
                    Text("ID: \(params.id)")
                    if let title = params.title {
                        Text("Title: \(title)")
                    }
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
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func extractParams(from type: Test_Click_Type) -> ClickParams? {
        switch type {
        case .profile(let params): return params
        case .detail(let params): return params
        default: return nil
        }
    }
    
    private var navigationTitle: String {
        switch type {
        case .profile: return "Profile"
        case .detail: return "Detail"
        case .edit_note(let note): return note != nil ? "Edit Note" : "New Note"
        default: return "Title"
        }
    }
}

struct Test_iOS_Home: View {
    @State var vm = Test_Home_VM()
    @State private var selectTabId: String = ""
    @State private var activeSheet: Test_Click_Type?
    @State private var alertInfo: Test_Alert_Info?  // 添加 alert 状态
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        return TabView(selection: $selectTabId) {
            ForEach(vm.pages) { page in
                if let page_data = vm.page_data_dic[page.id] {
                    Test_Home_Page(
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
        .tabViewStyle(.page(indexDisplayMode: .never))
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
    
    @ViewBuilder
    private func presentSheet(_ type: Test_Click_Type) -> some View {
        switch type {
        case .profile(let params):
            ClickView(type: type)
        case .detail(_):
            ClickView(type: type)
        case .edit_note(_):
            ClickView(type: type)
        default: ClickView(type: type)
        }
    }
}

extension Test_iOS_Home{
    private func handleClick(_ clickType: Test_Click_Type, for page: App_Page) {
        switch clickType {
        case .edit_note(let c_Note):
            if let _ = c_Note {
                activeSheet = clickType
            } else {
                withAnimation {
                    vm.add_note(pageId: page.id)
                }
            }
        case .delete_note(let note):
            alertInfo = Test_Alert_Info(
                title: "确认删除",
                message: "确定要删除笔记 \"\(note.name)\" 吗？此操作不可撤销。",
                primaryButton: Test_Alert_Info.AlertButton(
                    title: "删除",
                    role: .destructive,
                    action: {
                        if let index = vm.page_data_dic[page.id]?.notes.firstIndex(where: {$0 == note}) {
                            withAnimation {vm.page_data_dic[page.id]?.notes.remove(at: index)}
                        }
                    }
                ),
                secondaryButton: Test_Alert_Info.AlertButton(
                    title: "取消",
                    role: .cancel,
                    action: {}
                )
            )
        case .delete_task(let task):
            alertInfo = Test_Alert_Info(
                title: "确认删除",
                message: "确定要删除task \"\(task.name)\" 吗？此操作不可撤销。",
                primaryButton: Test_Alert_Info.AlertButton(
                    title: "删除",
                    role: .destructive,
                    action: {
                        if let header_type = Page_Header_Type(rawValue: task.task_type){
                            if let index = vm.page_data_dic[page.id]?.task_dic[header_type]?.firstIndex(where: {$0 == task}) {
                                withAnimation {
                                    vm.page_data_dic[page.id]?.task_dic[header_type]?.remove(at: index)
                                }
                            }
                        }
                    }
                ),
                secondaryButton: Test_Alert_Info.AlertButton(
                    title: "取消",
                    role: .cancel,
                    action: {}
                )
            )
        case .delete_all_notes:
            alertInfo = Test_Alert_Info(
                title: "确认删除全部",
                message: "确定要删除全部 \(vm.page_data_dic[page.id]?.notes.count ?? 0) 条笔记吗？此操作不可撤销。",
                primaryButton: Test_Alert_Info.AlertButton(
                    title: "删除全部",
                    role: .destructive,
                    action: {
                        withAnimation {
                            vm.page_data_dic[page.id]?.notes.removeAll()
                        }
                    }
                ),
                secondaryButton: Test_Alert_Info.AlertButton(
                    title: "取消",
                    role: .cancel,
                    action: {}
                )
            )
        case .delete_all_tasks(let header):
            alertInfo = Test_Alert_Info(
                title: "确认删除全部",
                message: "确定要删除全部 \(vm.page_data_dic[page.id]?.task_dic[header]?.count ?? 0) 条笔记吗？此操作不可撤销。",
                primaryButton: Test_Alert_Info.AlertButton(
                    title: "删除全部",
                    role: .destructive,
                    action: {
                        withAnimation {
                            vm.page_data_dic[page.id]?.task_dic[header]?.removeAll()
                        }
                    }
                ),
                secondaryButton: Test_Alert_Info.AlertButton(
                    title: "取消",
                    role: .cancel,
                    action: {}
                )
            )
        case .alert(let info):
            alertInfo = info
        case .profile(_):
            activeSheet = clickType
        case .detail(_):
            activeSheet = clickType
        case .edit_task(let header_type, let c_Task):
            if let _ = c_Task {
                activeSheet = clickType
            } else {
                withAnimation {
                    vm.add_task(pageId: page.id, header_type: header_type)
                }
            }
        case .full_screen:
            activeSheet = clickType
        }
    }
}

struct Test_Alert_Info: Identifiable, Equatable {
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

enum Test_Click_Type: Identifiable, Equatable {
    case profile(ClickParams)
    case detail(ClickParams)
    case edit_note(C_Book?)
    case delete_note(C_Book)
    case delete_all_notes
    
    case delete_task(C_Task)
    case delete_all_tasks(Page_Header_Type)

    case edit_task(Page_Header_Type, C_Task?)
    
    case full_screen
    case alert(Test_Alert_Info)
    
    var id: String {
        switch self {
        case .profile(let params): return "profile_\(params.id)"
        case .detail(let params): return "detail_\(params.id)"
            
        case .edit_note(let params): return "edit_note_\(params?.id.uuidString ?? "new")"
        case .delete_note(let params): return "delete_note_\(params.id.uuidString)"
            
        case .delete_all_notes: return "delete_all_notes"
            
        case .edit_task(_, let task): return "edit_task_\(task?.id.uuidString ?? "new")"
        case .delete_task(let params): return "delete_task_\(params.id.uuidString)"
            
        case .full_screen: return "full_screen"
        case .alert(let info): return "alert_\(info.id)"
        case .delete_all_tasks(let header):
            return "delete_all_tasks_\(header.rawValue)"
        }
    }
    
    // 添加显示方式属性
    var presentationStyle: Test_PresentationStyle {
        switch self {
        case .profile: return .fullScreen    // 全屏显示
        case .detail, .edit_note: return .sheet          // sheet方式显示
        case .full_screen: return .fullScreen
        case .alert, .delete_all_notes: return .sheet  // alert 不需要这个，但保持一致性
        default: return .sheet
        }
    }
    
    static func == (lhs: Test_Click_Type, rhs: Test_Click_Type) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    Test_iOS_Home()
}
