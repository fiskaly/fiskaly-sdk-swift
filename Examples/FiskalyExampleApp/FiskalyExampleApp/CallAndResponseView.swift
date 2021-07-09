//
//  CallAndResponseView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 09.07.21.
//

import SwiftUI

/// Displays a button with an action, then some custom content, then the response from that action, in a view that is expanded once the action completes
struct CallAndResponseView<Content>: View where Content : View {
    var name:String
    @Binding var response:RequestResponse?
    @State var expanded:Bool = false
    let action: () -> Void
    @ViewBuilder var content: () -> Content
    var body: some View {
        Button(name) {
            action()
            expanded = true
        }
        content()
        ResponseView(response: $response, expanded: $expanded, name: name)
    }
}
