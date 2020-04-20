import SwiftUI

struct ContentView: View {
    var body: some View {
        Text(fullText)
    }
    
    var fullText: String = ""

    init(text: String) {
        self.fullText = text
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(text: "")
    }
}
