//
//  FlyingHighApp.swift
//  FlyingHigh
//
//  Created by Felipe Prado de Lima on 01/06/26.
//

import SwiftUI

@main
struct FlyingHighApp: App {
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(ColorScheme.light)
                .sheet(isPresented: $isFirstLaunch) {
                    OnboardingView()
                }
        }
        .environment(AlbumViewModel())
        .environment(ViewRouter())
    }
}
