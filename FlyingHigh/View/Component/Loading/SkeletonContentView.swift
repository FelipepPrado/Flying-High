//
//  SkeletonContentView.swift
//  FlyingHigh
//
//  Created by Amanda Fonseca Coelho on 18/06/26.
//

import SwiftUI

struct SkeletonContentView: View {
    var body: some View {
        ZStack {
            Color(.bgPrimary).ignoresSafeArea()
            VStack(spacing: 20) {
                SkeletonView()
                    .frame(height: 217)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay{
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.bgPrimary)
                                    .padding(.bottom, 50)
                                    .offset(x: 15)
                            }
                        }
                    }
                    .overlay{
                        VStack {
                            Spacer()
                            HStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.bgPrimary)
                                    .padding(.bottom, 50)
                                    .offset(x: -15)
                                Spacer()
                            }
                        }
                    }
                SkeletonView()
                    .frame(height: 217)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay{
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.bgPrimary)
                                    .padding(.bottom, 50)
                                    .offset(x: 15)
                            }
                        }
                    }
                    .overlay{
                        VStack {
                            Spacer()
                            HStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.bgPrimary)
                                    .padding(.bottom, 50)
                                    .offset(x: -15)
                                Spacer()
                            }
                        }
                    }
                Spacer()
            }
            .padding()
        }
        
    }
}


#Preview {
    SkeletonContentView()
}
