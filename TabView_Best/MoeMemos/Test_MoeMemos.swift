//
//  Test_Edit.swift
//  Today_3x3_Design
//
//  Created by kidstyo on 2025/11/7.
//

import SwiftUI

let listItemSymbolList = ["- [ ] ", "- [x] ", "- [X] ", "* ", "- "]

/*
 参考 IceCubes，Moemeno
 */
struct Test_MoeMemos: View {
    @State private var name = "Taylor Swift"
    @FocusState var isInputActive: Bool
    
    @State private var text = ""
    @State private var selection: Range<String.Index>? = nil
    
    @FocusState private var focused: Bool
    

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextView(text: $text, selection: $selection, shouldChangeText: shouldChangeText(in:replacementText:))
                    .focused($focused)
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("input.placeholder")
                                .foregroundColor(.secondary)
                                .padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5))
                        }
                    }
                    .padding(.horizontal)
//                    MemoInputResourceView(viewModel: viewModel)
            }
            .padding(.bottom, 40)
            .task {
                focused = true
            }

//                .toolbar {
//                    ToolbarItemGroup(placement: .keyboard) {
//                        Spacer()
//                        Button("Done") {
//                            isInputActive = false
//                        }
//                    }
//                }
                .safeAreaInset(edge: .bottom) {
                    toolbar()

                }
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
                    focused = false
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
    
    private func shouldChangeText(in range: Range<String.Index>, replacementText text: String) -> Bool {
        if text != "\n" || range.upperBound != range.lowerBound {
            return true
        }
        
        let currentText = self.text
        let contentBefore = currentText[currentText.startIndex..<range.lowerBound]
        let lastLineBreak = contentBefore.lastIndex(of: "\n")
        let nextLineBreak = currentText[range.lowerBound...].firstIndex(of: "\n") ?? currentText.endIndex
        let currentLine: Substring
        if let lastLineBreak = lastLineBreak {
            currentLine = currentText[currentText.index(after: lastLineBreak)..<nextLineBreak]
        } else {
            currentLine = currentText[currentText.startIndex..<nextLineBreak]
        }
        
        for prefixStr in listItemSymbolList {
            if (!currentLine.hasPrefix(prefixStr)) {
                continue
            }
            
            if currentLine.count <= prefixStr.count || currentText.index(currentLine.startIndex, offsetBy: prefixStr.count) >= range.lowerBound {
                break
            }
            
            self.text = currentText[currentText.startIndex..<range.lowerBound] + "\n" + prefixStr + currentText[range.upperBound..<currentText.endIndex]
            selection = self.text.index(range.lowerBound, offsetBy: prefixStr.count + 1)..<self.text.index(range.upperBound, offsetBy: prefixStr.count + 1)
            return false
        }

        return true
    }
}

#Preview {
    Test_MoeMemos()
}
