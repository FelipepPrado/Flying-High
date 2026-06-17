//
//  CustonColor.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 16/06/26.
//

import SwiftUI
import SwiftData


struct CustonColorPicker: App {
    var sharedModelContainer: ModelContainer={
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let modelConfigurationICloudOff = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        
        let ICloudToken = FileManager.default.ubiquityIdentityToken
        
        if ICloudToken == nil {
            do{
                return try ModelContainer (for: schema, configurations: [modelConfigurationICloudOff])
            }catch {
                fatalError("Não foi possível criar o ModelContainer, \(error)")
            }
        }else{
            do{
                return try ModelContainer (for: schema, configurations: [modelConfiguration])

            } catch{
                fatalError("Não foi possível criar o ModelContainer, \(error)")

            }
        }
        
        
    }()
    
    var body: some Scene {
        WindowGroup{
            ContentView()
        }
            .modelContainer(sharedModelContainer)
    }
}


