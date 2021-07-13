//
//  ShowLogView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 13.07.21.
//

import Foundation

import SwiftUI

struct ShowLogView: View {
    @ObservedObject var fiskalyzer:Fiskalyzer
    var body: some View {
        NavigationLink(
            destination: LogView(fiskalyzer: fiskalyzer, name: "Log")) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                Text("Show Log")
            }
        }.padding()
    }
}
