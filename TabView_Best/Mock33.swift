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

enum PageType: String, CaseIterable {
    case today
    case week
}

class Mock33_VM: ObservableObject {
    @Published var noteDic: [String: [C_Note]]
    @Published var taskDic: [String: [C_Task]]
    
    @Published var pages: [C_Tab]

    init() {
        pages = [C_Tab(id: PageType.today.rawValue, name: "Today"), C_Tab(id: PageType.week.rawValue, name: "Week")]
        for page in PageType.allCases {
            
        }
    }
}

struct Mock33: View {
    @State private var selectTabId: String = ""
    
    var body: some View {
        TabView(selection: $selectTabId) {
            ForEach(pages, id: \.self){page in
                MockPage(tab: page)
                    .tag(page.id.uuidString)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct MockPage: View {
    var tab: C_Tab
    
    var body: some View{
        List {
            Text(tab.name)
            Text(UUID().uuidString)
        }
    }
}

#Preview {
    Mock33()
}
