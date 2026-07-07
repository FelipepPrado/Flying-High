//
//  FlyingHighApp.swift
//  FlyingHigh
//
//  Created by Felipe Prado de Lima on 01/06/26.
//

import SwiftUI
import SwiftData

@main
struct FlyingHighApp: App {
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    
    var sharedModelContainer: ModelContainer = {
            let schema = Schema([
                AlbumModel.self,
                PhotoModel.self
            ])

            let modelConfiguration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Não foi possível criar o ModelContainer: \(error)")
            }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(ColorScheme.light)
                .sheet(isPresented: $isFirstLaunch) {
                    OnboardingView()
                }
        }
        .modelContainer(sharedModelContainer)
        .environment(AlbumViewModel())
        .environment(ViewRouter())
    }
}
