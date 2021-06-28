//
//  ContentView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 21.06.21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var fiskalyzer:Fiskalyzer
    var body: some View {
        TabView {
            V1View(fiskalyzer: fiskalyzer).tabItem {
                Label("V1", systemImage: "1.circle")
            }.tag(0)
            V2View(fiskalyzer: fiskalyzer).tabItem {
                Label("V2", systemImage: "2.circle")
            }.tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fiskalyzer: Fiskalyzer())
    }
}
