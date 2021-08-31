//
//  UUIDView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import SwiftUI

struct UUIDView: View {
    @Binding var uuid:String?
    var name:String
    var body: some View {
        Text("\(name) UUID:")
        Text("\(uuid ?? "—")").font(.body.smallCaps())
    }
}
