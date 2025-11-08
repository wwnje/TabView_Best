//
//  Test_Edit.swift
//  Today_3x3_Design
//
//  Created by kidstyo on 2025/11/7.
//

import SwiftUI

/*
 参考 IceCubes，Moemeno
 */
struct Test_MoeMemos: View {
    @State private var name = "Taylor Swift"
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputActive)
                        .padding(.horizontal)
//                    MemoInputResourceView(viewModel: viewModel)
                }
                .padding(.bottom, 40)
                
                toolbar()
            }

//                .toolbar {
//                    ToolbarItemGroup(placement: .keyboard) {
//                        Spacer()
//                        Button("Done") {
//                            isInputActive = false
//                        }
//                    }
//                }
//                .safeAreaInset(edge: .bottom) {
//                    Button("233") {
//                        isInputActive = false
//                    }
//                }
        }
    }
    
    @ViewBuilder
    private func toolbar() -> some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .center) {
                Button {
                } label: {
                    Image(systemName: "checkmark.square")
                }
                
                Button {
                } label: {
                    Image(systemName: "photo.on.rectangle")
                }
                
                Button {
                } label: {
                    Image(systemName: "camera")
                }
                
                Spacer()
            }
            .frame(height: 20)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    Test_MoeMemos()
}
