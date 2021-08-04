//
//  LogView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 13.07.21.
//

import SwiftUI
import MobileCoreServices

struct LogView: View {
    @ObservedObject var fiskalyzer:Fiskalyzer
    var name:String
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                Text(fiskalyzer.log).font(.footnote).id("log")
                    .onAppear {
                        scrollView.scrollTo("log", anchor: .bottom)
                }
            }
        }.frame(maxWidth: .infinity)
        .navigationBarTitle(Text("Log"), displayMode: .inline)
        .padding([.leading, .trailing], 10)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: {
                fiskalyzer.clearLog()
            }, label: {
                Image(systemName:"trash").accessibility(hint: Text("clears the log"))
            })
            Button(action: {
                UIPasteboard.general.setValue(fiskalyzer.log,
                                              forPasteboardType: kUTTypePlainText as String)
            }, label: {
                Image(systemName:"doc.on.doc")
            })
            }
        }
    }
}
