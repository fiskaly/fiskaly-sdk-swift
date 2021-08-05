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
    @State var expandPersonalizeTSSResponse:Bool = false
    @State var expandChangeAdminPINResponse:Bool = false
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
                Text("To avoid 'Limit of active TSS reached' errors when creating a TSS, tap 'Disable' to move a TSS to the DISABLED state so you can create a new one, or tap 'Use' to use the existing TSS for operations on the main screen instead of creating a new TSS.").font(.footnote).padding()
            }) {
                ForEach(fiskalyzer.TSSList, id: \._id) { tss in
                    VStack {
                        Text("\(tss._id)").font(.body.smallCaps()).padding(5)
                        HStack {
                            Image(systemName: "checkmark").opacity(fiskalyzer.tssUUID == tss._id ? 1.0 : 0).accessibility(hidden: fiskalyzer.tssUUID != tss._id)
                            Spacer()
                            Text(tss.state.rawValue).multilineTextAlignment(.leading)
                            Spacer()
                            Button("Disable") {
                                fiskalyzer.disableTSS(tss)
                                disabledTSS = tss._id
                                expandDisableTSSResponse = true
                                //these other steps don't always need to be taken, so we don't need to expand them unless they were.
                                expandPersonalizeTSSResponse = fiskalyzer.personalizeTSSResponse != nil
                                expandChangeAdminPINResponse = fiskalyzer.changeAdminPINResponse != nil
                            }.disabled(!fiskalyzer.canDisable(tss)).multilineTextAlignment(.trailing).buttonStyle(BorderlessButtonStyle())
                            Spacer()
                            Button("Use") {
                                fiskalyzer.use(tss: tss)
                            }.disabled(!fiskalyzer.canUse(tss)).multilineTextAlignment(.leading).buttonStyle(BorderlessButtonStyle())
                        }
                    }.frame(minHeight: 50)
                }
            }.textCase(nil)
            Section(header: Text("Disable TSS").font(.headline)) {
                VStack {
                    UUIDView(uuid: $disabledTSS, name: "TSS")
                    ResponseView(response: $fiskalyzer.personalizeTSSResponse,expanded: $expandPersonalizeTSSResponse, name: "Personalize TSS")
                    ResponseView(response: $fiskalyzer.changeAdminPINResponse,expanded: $expandChangeAdminPINResponse, name: "Change Admin PIN")
                    ResponseView(response: $fiskalyzer.disableTSSResponse,expanded: $expandDisableTSSResponse, name: "Disable TSS")
                }
            }.textCase(nil)
        }.listStyle(GroupedListStyle()).navigationBarTitle(Text("List TSS"), displayMode: .inline)
    }
}
