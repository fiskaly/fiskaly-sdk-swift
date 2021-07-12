//
//  AuthenticateAdminView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 12.07.21.
//

import SwiftUI

struct AuthenticateAdminView : View {
    @ObservedObject var fiskalyzer:FiskalyzerV2
    var body: some View {
        CallAndResponseView(name: "Authenticate Admin", response: $fiskalyzer.authenticateAdminResponse) {
            fiskalyzer.authenticateAdmin()
        } content: {
            Text("Admin status: \(fiskalyzer.adminStatus)")
        }
    }
}
