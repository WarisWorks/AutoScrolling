//
//  ContentView.swift
//  AutoScrolling
//
//  Created by Waris on 2023/02/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            Home()
        }
        .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
