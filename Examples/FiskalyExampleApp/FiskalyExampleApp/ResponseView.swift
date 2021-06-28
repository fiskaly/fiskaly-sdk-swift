//
//  ResponseView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import SwiftUI

struct ResponseView: View {
    @Binding var status:Int?
    @Binding var response:String?
    @Binding var expanded:Bool
    var name:String
    var body: some View {
        DisclosureGroup("\(name) Results", isExpanded:$expanded) {
            Text("status: \(status?.description ?? "unknown")")
            Text("response:")
            ScrollView {
                Text("\(response ?? "unknown")").font(.footnote)
            }.frame(maxHeight: 100).padding()
        }.padding()
    }
}
