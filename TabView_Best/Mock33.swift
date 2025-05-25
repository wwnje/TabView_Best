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

struct Mock33: View {
    @StateObject var vm = Mock33_VM()
    @State private var openSheet: Bool = false
    @State private var selectTabId: String = ""
    
    @StateObject private var sheetManager = ClickObject()

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        TabView(selection: $selectTabId) {
            ForEach(vm.pages) { page in
                MockPage(tab: page, page_data: vm.page_data_dic[page.id], onClickToFirst: {
                    selectTabId = vm.pages.first?.id ?? ""
                }, openSheet: {
                    openSheet = true
                }, onClick: {click_type in
                    switch click_type {
                    case .profile(let clickParams):
                        break
                    case .settings(let clickParams):
                        break
                    case .detail(let clickParams):
                        break
                    case .edit_note(let c_Note):
                        if let c_Note = c_Note{
//                            openSheet = true
                            sheetManager.showSheet(click_type)
                        }
                        else{
                            vm.page_data_dic[page.id]?.notes.append(C_Note(name: "New Note"))
                        }
                    }
                })
                .tag(page.id)  // 直接使用 page.id，不需要 .uuidString
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onAppear(perform: {
            // 设置默认选中的 tab
            selectTabId = vm.pages.first?.id ?? ""
        })
        .sheet(isPresented: $openSheet) {
            Text("This is sheet")
        }
        // sheet展示
        .sheet(item: Binding(
            get: { sheetManager.activeSheet?.presentationStyle == .sheet ? sheetManager.activeSheet : nil },
            set: { sheetManager.activeSheet = $0 }
        )) { type in
            presentSheet(type)
        }
        // 全屏展示
        .fullScreenCover(item: Binding(
            get: { sheetManager.activeSheet?.presentationStyle == .fullScreen ? sheetManager.activeSheet : nil },
            set: { sheetManager.activeSheet = $0 }
        )) { type in
            presentSheet(type)
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

struct MockPage: View {
    var tab: C_Tab
    var page_data: Page_Data?
    
    var onClickToFirst: () -> ()
    var openSheet: () -> ()
    let onClick: (ClickType) -> Void

    var body: some View{
#if DEBUG
let _ = Self._printChanges()
#endif
        List {
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
                        Text(note.name)
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
            
            Button {
                openSheet()
            } label: {
                Text("open sheet")
            }
        }
    }
}

#Preview {
    Mock33()
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
        case .edit_note(let params): return "edit_note_\(params?.id)"
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

// MARK: - ClickObject
final class ClickObject: ObservableObject {
    @Published var activeSheet: ClickType?
    
    func showSheet(_ type: ClickType) {
        print("📤 Showing sheet: \(type.id)")
        activeSheet = type
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
        let params = extractParams(from: type)
        NavigationView {
            VStack {
                if let params = params{
                    Text("ID: \(params.id)")
                    if let title = params.title {
                        Text("Title: \(title)")
                    }
                    if let data = params.data {
                        Text("Data: \(String(describing: data))")
                    }
                    // 使用extraParams
                    ForEach(Array(params.extraParams.keys), id: \.self) { key in
                        Text("\(key): \(String(describing: params.extraParams[key]!))")
                    }
                }
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
    
    private func extractParams(from type: ClickType) -> ClickParams? {
        switch type {
        case .profile(let params): return params
        case .settings(let params): return params
        case .detail(let params): return params
        case .edit_note(let params): return nil
        }
    }
}
