//
//  ResponseView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import SwiftUI

struct ResponseView: View {
    @Binding var response:RequestResponse?
    @Binding var expanded:Bool
    var name:String
    var body: some View {
        DisclosureGroup("\(name) Results", isExpanded:$expanded) {
            Text("status: \(response?.status.description ?? "unknown")")
            Text("response:")
            ScrollView {
                Text("\(response?.response ?? "unknown")").font(.footnote)
            }.frame(maxHeight: 100).padding()
        }.padding()
    }
}
