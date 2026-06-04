//
//  FlyingHighApp.swift
//  FlyingHigh
//
//  Created by Felipe Prado de Lima on 01/06/26.
//

import SwiftUI

@main
struct FlyingHighApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(AlbumViewModel())
        .environment(ViewRouter())
    }
}
