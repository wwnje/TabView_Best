//
//  ContentView.swift
//  TabView_Best
//
//  Created by kidstyo on 2025/3/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var SO = SheetObject()
    @StateObject private var SO_OnClick = SheetObject()

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        TabView {
            TabContentView(name: "Tab 1", showSheet: .profile, onClick: { st in SO_OnClick.showSheet(st)})
                .tabItem {
                    Label("Tab 1", systemImage: "1.circle")
                }
            
            TabContentView(name: "Tab 2", showSheet: .settings, onClick: { st in SO_OnClick.showSheet(st)})
                .tabItem {
                    Label("Tab 2", systemImage: "2.circle")
                }
            
            TabContentView(name: "Tab 3", showSheet: .detail("123"), onClick: { st in SO_OnClick.showSheet(st)})
                .tabItem {
                    Label("Tab 3", systemImage: "3.circle")
                }
        }
        .sheet(item: $SO.activeSheet) { type in
            VStack {
                Text("SO")
                Text(type.id)
            }
        }
        .sheet(item: $SO_OnClick.activeSheet) { type in
            VStack {
                Text("SO_OnClick")
                Text(type.id)
            }
        }
        .environmentObject(SO)
    }
}

#Preview {
    ContentView()
}

class SheetObject: ObservableObject{
    @Published var activeSheet: SheetType?
    
    init() {
        print("SheetObject init")
    }
    
    func showSheet(_ type: SheetType, data: Any? = nil) {
        activeSheet = type
    }
}

enum SheetType: Identifiable {
    case profile
    case settings
    case detail(String) // 带参数的sheet类型
    
    var id: String {
        switch self {
        case .profile: return "profile"
        case .settings: return "settings"
        case .detail(let id): return "detail_\(id)"
        }
    }
}

struct TabContentView: View {
    @EnvironmentObject private var SO: SheetObject
    var name: String
    var showSheet: SheetType
    
    var onClick: (SheetType) -> ()
    
    @StateObject private var SO_Self = SheetObject()

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            Text(UUID().uuidString)
            Text("SO: \(SO.activeSheet?.id ?? "nil")")
            Text("SO_Self: \(SO_Self.activeSheet?.id ?? "nil")")

            Text(name)

            Button("Show Detail") {
                SO.showSheet(showSheet)
            }
            
            Button("Show Detail Self") {
                SO_Self.showSheet(showSheet)
            }
            
            Button("onClick") {
                onClick(showSheet)
            }
        }
        .onAppear {
            print("appeared")
        }
        .sheet(item: $SO_Self.activeSheet) { type in
            VStack {
                Text("\(type.id) self")
                Divider()
                Text("SO: \(SO.activeSheet?.id ?? "nil")")
                Text("SO_Self: \(SO_Self.activeSheet?.id ?? "nil")")
            }
        }
    }
}
