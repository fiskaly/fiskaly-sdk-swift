//
//  AuthenticateClientView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 16.07.21.
//

import Foundation

import SwiftUI

struct AuthenticateClientView : View {
    @ObservedObject var fiskalyzer:FiskalyzerV2
    var body: some View {
        CallAndResponseView(name: "Authenticate Client", response: $fiskalyzer.authenticateClientResponse) {
            fiskalyzer.authenticateClient()
        } content: {
        }
    }
}
