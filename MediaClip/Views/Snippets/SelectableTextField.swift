import SwiftUI
import AppKit

struct SelectableTextField: NSViewRepresentable {
    @Binding var text: String
    var onCommit: () -> Void
    var onCancel: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.isBordered = true
        textField.bezelStyle = .roundedBezel
        textField.font = .systemFont(ofSize: 13)
        textField.focusRingType = .exterior
        textField.stringValue = text
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if !context.coordinator.hasActivated {
            nsView.stringValue = text
            context.coordinator.hasActivated = true
            DispatchQueue.main.async {
                guard let window = nsView.window else { return }
                window.makeFirstResponder(nsView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    nsView.currentEditor()?.selectAll(nil)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onCommit: onCommit, onCancel: onCancel)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        var onCommit: () -> Void
        var onCancel: () -> Void
        var hasActivated = false

        init(text: Binding<String>, onCommit: @escaping () -> Void, onCancel: @escaping () -> Void) {
            _text = text
            self.onCommit = onCommit
            self.onCancel = onCancel
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                text = textField.stringValue
            }
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            onCommit()
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                onCancel()
                return true
            }
            return false
        }
    }
}
