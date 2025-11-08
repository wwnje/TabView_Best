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

    private var titleHeight: CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let lineHeight = font.lineHeight
        return lineHeight * 3 + 16 // 3行 + padding
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextView(
                    text: $input_title,
                    selection: $selection_title,
                    isFirstResponder: $isFocusTitle,
                    shouldChangeText: shouldChangeTextForTitle
                )
                .frame(height: titleHeight)
                .overlay(alignment: .topLeading) {
                    if input_title.isEmpty {
                        Text("input.title")
                            .foregroundColor(.secondary)
                            .padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5))
                    }
                }
                .padding(.horizontal)
                
                TextView(
                    text: $input_content,
                    selection: $selection_content,
                    isFirstResponder: $isFocusContent,
                    shouldChangeText: shouldChangeTextForContent
                )
                .overlay(alignment: .topLeading) {
                    if input_content.isEmpty {
                        Text("input.content")
                            .foregroundColor(.secondary)
                            .padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5))
                    }
                }
                .padding(.horizontal)
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
                    insert(tag: nil)
                } label: {
                    Image(systemName: "number")
                }
                
                Button {
                    toggleTodoItem()
                } label: {
                    Image(systemName: "checkmark.square")
                }
                
                Spacer()

                Button {
                    isFocusTitle = false
                    isFocusContent = false
                } label: {
                    Text("close")
                }
            }
            .frame(height: 20)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - 插入标签
    private func insert(tag: String?) {
        if isFocusTitle {
            insertTag(tag, into: $input_title, selection: $selection_title)
        } else if isFocusContent {
            insertTag(tag, into: $input_content, selection: $selection_content)
        }
    }
    
    private func insertTag(
        _ tag: String?,
        into text: Binding<String>,
        selection: Binding<Range<String.Index>?>
    ) {
        let tagText = "#\(tag ?? "") "
        guard let currentSelection = selection.wrappedValue else {
            text.wrappedValue += tagText
            return
        }
        
        text.wrappedValue = text.wrappedValue.replacingCharacters(in: currentSelection, with: tagText)
        let index = text.wrappedValue.index(currentSelection.lowerBound, offsetBy: tagText.count)
        selection.wrappedValue = index..<text.wrappedValue.index(currentSelection.lowerBound, offsetBy: tagText.count)
    }
    
    // MARK: - 切换待办事项
    private func toggleTodoItem() {
        if isFocusTitle {
            toggleTodoItemInText($input_title, selection: $selection_title)
        } else if isFocusContent {
            toggleTodoItemInText($input_content, selection: $selection_content)
        }
    }
    
    private func toggleTodoItemInText(
        _ text: Binding<String>,
        selection: Binding<Range<String.Index>?>
    ) {
        let currentText = text.wrappedValue
        guard let currentSelection = selection.wrappedValue else { return }
        
        let contentBefore = currentText[currentText.startIndex..<currentSelection.lowerBound]
        let lastLineBreak = contentBefore.lastIndex(of: "\n")
        let nextLineBreak = currentText[currentSelection.lowerBound...].firstIndex(of: "\n") ?? currentText.endIndex
        let currentLine: Substring
        if let lastLineBreak = lastLineBreak {
            currentLine = currentText[currentText.index(after: lastLineBreak)..<nextLineBreak]
        } else {
            currentLine = currentText[currentText.startIndex..<nextLineBreak]
        }
    
        let contentBeforeCurrentLine = currentText[currentText.startIndex..<currentLine.startIndex]
        let contentAfterCurrentLine = currentText[nextLineBreak..<currentText.endIndex]
        
        for prefixStr in listItemSymbolList {
            if !currentLine.hasPrefix(prefixStr) {
                continue
            }
            
            if prefixStr == "- [ ] " {
                text.wrappedValue = contentBeforeCurrentLine + "- [x] " + currentLine[currentLine.index(currentLine.startIndex, offsetBy: prefixStr.count)..<currentLine.endIndex] + contentAfterCurrentLine
                return
            }
            
            let offset = "- [ ] ".count - prefixStr.count
            text.wrappedValue = contentBeforeCurrentLine + "- [ ] " + currentLine[currentLine.index(currentLine.startIndex, offsetBy: prefixStr.count)..<currentLine.endIndex] + contentAfterCurrentLine
            selection.wrappedValue = text.wrappedValue.index(currentSelection.lowerBound, offsetBy: offset)..<text.wrappedValue.index(currentSelection.upperBound, offsetBy: offset)
            return
        }
        
        text.wrappedValue = contentBeforeCurrentLine + "- [ ] " + currentLine + contentAfterCurrentLine
        selection.wrappedValue = text.wrappedValue.index(currentSelection.lowerBound, offsetBy: "- [ ] ".count)..<text.wrappedValue.index(currentSelection.upperBound, offsetBy: "- [ ] ".count)
    }
    
    // MARK: - Title 的处理方法
    private func shouldChangeTextForTitle(in range: Range<String.Index>, replacementText text: String) -> Bool {
        handleListItemAutoCompletion(
            text: text,
            range: range,
            currentText: $input_title,
            selection: $selection_title
        )
    }
    
    // MARK: - Content 的处理方法
    private func shouldChangeTextForContent(in range: Range<String.Index>, replacementText text: String) -> Bool {
        handleListItemAutoCompletion(
            text: text,
            range: range,
            currentText: $input_content,
            selection: $selection_content
        )
    }
    
    // MARK: - 通用的列表项自动补全逻辑
    private func handleListItemAutoCompletion(
        text: String,
        range: Range<String.Index>,
        currentText: Binding<String>,
        selection: Binding<Range<String.Index>?>
    ) -> Bool {
        if text != "\n" || range.upperBound != range.lowerBound {
            return true
        }
        
        let textValue = currentText.wrappedValue
        let contentBefore = textValue[textValue.startIndex..<range.lowerBound]
        let lastLineBreak = contentBefore.lastIndex(of: "\n")
        let nextLineBreak = textValue[range.lowerBound...].firstIndex(of: "\n") ?? textValue.endIndex
        let currentLine: Substring
        if let lastLineBreak = lastLineBreak {
            currentLine = textValue[textValue.index(after: lastLineBreak)..<nextLineBreak]
        } else {
            currentLine = textValue[textValue.startIndex..<nextLineBreak]
        }
        
        for prefixStr in listItemSymbolList {
            if !currentLine.hasPrefix(prefixStr) {
                continue
            }
            
            if currentLine.count <= prefixStr.count || textValue.index(currentLine.startIndex, offsetBy: prefixStr.count) >= range.lowerBound {
                break
            }
            
            currentText.wrappedValue = textValue[textValue.startIndex..<range.lowerBound] + "\n" + prefixStr + textValue[range.upperBound..<textValue.endIndex]
            selection.wrappedValue = currentText.wrappedValue.index(range.lowerBound, offsetBy: prefixStr.count + 1)..<currentText.wrappedValue.index(range.upperBound, offsetBy: prefixStr.count + 1)
            return false
        }

        return true
    }
}

#Preview {
    Test_MoeMemos()
}
