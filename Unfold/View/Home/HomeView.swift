//
//  HomeView.swift
//  Unfold
//
//  Created by Rostislav on 13.10.2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Unfold! 🎉")
                    .font(.title)
                    .padding()

                Button("Log out") {
                    Task {
                        print("Log out pressed")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
