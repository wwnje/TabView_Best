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
    @State private var input_title = ""
    @State private var input_content = ""

    @State private var selection_title: Range<String.Index>? = nil
    @State private var selection_content: Range<String.Index>? = nil

    @State private var isFocusTitle = true
    @State private var isFocusContent = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextView(text: $input_title, selection: $selection_title, isFirstResponder: $isFocusTitle, shouldChangeText: shouldChangeText(in:replacementText:))
//                    .focused($focused)
                    .overlay(alignment: .topLeading) {
                        if input_title.isEmpty {
                            Text("input.title")
                                .foregroundColor(.secondary)
                                .padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5))
                        }
                    }
                    .padding(.horizontal)
                
                TextView(text: $input_content, selection: $selection_content, isFirstResponder: $isFocusContent, shouldChangeText: shouldChangeText(in:replacementText:))
//                    .focused($focused)
                    .overlay(alignment: .topLeading) {
                        if input_content.isEmpty {
                            Text("input.content")
                                .foregroundColor(.secondary)
                                .padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5))
                        }
                    }
                    .padding(.horizontal)
//                    MemoInputResourceView(viewModel: viewModel)
            }
            .padding(.bottom, 40)
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
                    isFocusTitle = false
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
        
        let currentText = self.input_title
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
            
            self.input_title = currentText[currentText.startIndex..<range.lowerBound] + "\n" + prefixStr + currentText[range.upperBound..<currentText.endIndex]
            selection_title = self.input_title.index(range.lowerBound, offsetBy: prefixStr.count + 1)..<self.input_title.index(range.upperBound, offsetBy: prefixStr.count + 1)
            return false
        }

        return true
    }
}

#Preview {
    Test_MoeMemos()
}
