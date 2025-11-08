//  TextView.swift
//  MoeMemos
//
//  Created by Mudkip on 2023/6/12.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var selection: Range<String.Index>?
    @Binding var isFirstResponder: Bool

    let shouldChangeText: ((_ range: Range<String.Index>, _ replacementText: String) -> Bool)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: CGRectZero)
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, selection: $selection, isFirstResponder: $isFirstResponder, shouldChangeText: shouldChangeText)
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if text != uiView.text {
            uiView.text = text
        }
        
        if let selection = selection, selection.upperBound <= text.endIndex {
            let range = NSRange(selection, in: text)
            if uiView.selectedRange != range {
                uiView.selectedRange = range
            }
        } else {
            if uiView.selectedRange.upperBound != 0 {
                uiView.selectedRange = NSRange()
            }
        }
        
        // 控制键盘显示/隐藏
        if isFirstResponder && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else if !isFirstResponder && uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }
    
    @MainActor
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @Binding var selection: Range<String.Index>?
        @Binding var isFirstResponder: Bool
        
        let shouldChangeText: ((_ range: Range<String.Index>, _ replacementText: String) -> Bool)?
        
        init(text: Binding<String>, selection: Binding<Range<String.Index>?>, isFirstResponder: Binding<Bool>, shouldChangeText: ((_ range: Range<String.Index>, _ replacementText: String) -> Bool)?) {
            _text = text
            _selection = selection
            _isFirstResponder = isFirstResponder
            self.shouldChangeText = shouldChangeText
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            selection = Range(textView.selectedRange, in: textView.text)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            selection = Range(textView.selectedRange, in: textView.text)
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let shouldChangeText = shouldChangeText, let textRange = Range(range, in: textView.text) {
                return shouldChangeText(textRange, text)
            }
            return true
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.isFirstResponder = true
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.isFirstResponder = false
            }
        }
    }
}

#Preview {
    @Previewable @State var text = "Hello world"
    @Previewable @State var selection: Range<String.Index>? = nil
    @Previewable @State var isFirstResponder = true

    TextView(text: $text, selection: $selection, isFirstResponder: $isFirstResponder, shouldChangeText: nil)
}
