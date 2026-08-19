//
//  ContentView.swift
//  APIs
//
//  Created by Nikunj  on 08/08/26.
//

import SwiftUI
import Foundation

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("TypiCode Ops") {
                    NavigationLink(destination: TypiCodeGetView()) {
                        Label("Read Posts (GET)", systemImage: "arrow.down.circle")
                    }
                    NavigationLink(destination: TypiCodePostView()) {
                        Label("Create Post (POST)", systemImage: "plus.circle")
                    }
                    NavigationLink(destination: TypiCodePutView()) {
                        Label("Update Post (PUT)", systemImage: "pencil.circle")
                    }
                    NavigationLink(destination: TypiCodeDeleteView()) {
                        Label("Delete Post (DELETE)", systemImage: "trash.circle")
                    }
                }
            }
        }
        .navigationTitle("TypiCode APIs")
    }
}

#Preview {
    ContentView()
}
