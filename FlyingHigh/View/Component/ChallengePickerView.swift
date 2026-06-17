//
//  ChallengePickerView.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 16/06/26.
//

import SwiftUI

struct ChallengePickerView: View {
    
    enum Flavor: String, CaseIterable, Identifiable {
        case chocolate, vanilla, strawberry
        var id: Self { self }
    }

    @State private var selectedFlavor: Flavor = .chocolate
    
    var body: some View {
        
               
            //.clipShape(RoundedRectangle(cornerRadius: 12))
           // .border(.pink)
    }
}

#Preview {
    ChallengePickerView()
}
