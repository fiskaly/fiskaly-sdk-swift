//
//  CallAndResponseView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 09.07.21.
//

import SwiftUI

enum ActionStatus {
    case unavailable, successful, unsuccessful, available
}

/// Displays a button with an action, then some custom content, then the response from that action, in a view that is expanded once the action completes
struct CallAndResponseView<Content>: View where Content : View {
    var name:String
    @Binding var response:RequestResponse?
    @State var expanded:Bool = false
    let action: () -> Void
    @ViewBuilder var content: () -> Content
    @Environment(\.isEnabled) var isEnabled
    private var status:ActionStatus {
        get {
            if let response = response {
                return (response.status == 200) ? .successful:.unsuccessful
            }
            return self.isEnabled ? .available : .unavailable
        }
    }
    
    func statusIconName(for status:ActionStatus) -> String {
        switch status {
        case .unavailable:
            return "xmark"
        case .successful:
            return "checkmark"
        case .unsuccessful:
            return "exclamationmark.triangle"
        case .available:
            return "arrow.right"
        }
    }
    
    func color(for status:ActionStatus) -> Color {
        switch status {
        case .unavailable:
            return .secondary
        case .successful:
            return .green
        case .unsuccessful:
            return .red
        case .available:
            return .orange
        }
    }
    
    var body: some View {
        Button(action: {
            action()
            expanded = true
        }) {
            HStack(spacing: 10) {
                Image(systemName: statusIconName(for:status)).accentColor(color(for: status))
                Text(name)
            }
        }
        content()
        ResponseView(response: $response, expanded: $expanded, name: name)
    }
}
