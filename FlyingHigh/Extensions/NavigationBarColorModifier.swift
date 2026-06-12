//
//  NavigationBarColorModifier.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 12/06/26.
//

import SwiftUI

extension View {
    func navigationTitleColor(_ color: UIColor) -> some View {
        self.modifier(NavigationBarColorModifier(color: color))
    }
}

struct NavigationBarColorModifier: ViewModifier {
    var color: UIColor

    func body(content: Content) -> some View {
        content
            .onAppear {
                let coloredAppearance = UINavigationBarAppearance()
                coloredAppearance.titleTextAttributes = [.foregroundColor: color]
                coloredAppearance.largeTitleTextAttributes = [.foregroundColor: color]

                UINavigationBar.appearance().standardAppearance = coloredAppearance
                UINavigationBar.appearance().compactAppearance = coloredAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
            }
    }
}
