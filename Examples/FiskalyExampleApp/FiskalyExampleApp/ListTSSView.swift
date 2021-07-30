//
//  ListTSSView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 14.07.21.
//

import SwiftUI

struct ListTSSView: View {
    @ObservedObject var fiskalyzer:FiskalyzerV2
    @State var expandListTSSResponse:Bool = false
    @State var expandDisableTSSResponse:Bool = false
    @State var disabledTSS:String? = nil
    var body: some View {
        List {
            Section(header:Text("List TSS").font(.headline) ) {
                VStack {
                    fiskalyzer.error.map { Text($0).foregroundColor(.red) }
                    ResponseView(response: $fiskalyzer.listTSSResponse,expanded: $expandListTSSResponse, name: "List TSS").onAppear() {
                        fiskalyzer.listTSS()
                        expandListTSSResponse = true
                    }
                }
            }.textCase(nil)
            Section(header:
            VStack {
                Text("TSS found").font(.headline)
                Text("Disable any with status CREATED, UNINITIALIZED, or INITIALIZED to avoid 'Limit of active TSS reached' errors.").font(.footnote).padding()
            }) {
                ForEach(fiskalyzer.TSSList, id: \._id) { tss in
                    VStack {
                        Text("\(tss._id)").font(.body.smallCaps()).padding(5)
                        HStack {
                            Text(tss.state).multilineTextAlignment(.leading)
                            Spacer()
                            Button("Disable") {
                                fiskalyzer.disableTSS(tss)
                                disabledTSS = tss._id
                                expandDisableTSSResponse = true
                            }.disabled(!fiskalyzer.canDisable(tss)).multilineTextAlignment(.trailing)
                        }
                    }.frame(minHeight: 50)
                }
            }.textCase(nil)
            Section(header: Text("Disable TSS").font(.headline)) {
                VStack {
                    UUIDView(uuid: $disabledTSS, name: "TSS")
                    ResponseView(response: $fiskalyzer.disableTSSResponse,expanded: $expandDisableTSSResponse, name: "Disable TSS")
                }
            }.textCase(nil)
        }.listStyle(GroupedListStyle())
    }
}
