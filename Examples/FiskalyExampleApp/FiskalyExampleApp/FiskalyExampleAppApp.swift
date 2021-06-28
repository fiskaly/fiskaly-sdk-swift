//
//  FiskalyExampleAppApp.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 21.06.21.
//

import SwiftUI

@main
struct FiskalyExampleAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(fiskalyzer: Fiskalyzer())
        }
    }
}
