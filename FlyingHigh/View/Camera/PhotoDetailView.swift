//
//  PhotoDetailView.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 15/06/26.
//

import SwiftUI
import Nuvem

struct PhotoDetailView: View {
    let photo: Photo.Observable
    let challengeTitle: String
    var album: Album.Observable
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var shareURL: URL?
    private let footerHeight: CGFloat = 180.0
    
    var body: some View {
        ZStack {
            Color(.bgPrimary).ignoresSafeArea()
            GeometryReader { geometry in
                VStack(spacing: 24){
                    Spacer()
                    if let imageData = photo.data,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .scaleEffect(scale)
                            .offset(offset)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newScale = lastScale * value
                                        scale = min(max(newScale, 1), 5)
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if scale > 1 {
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    if scale > 1 {
                                        scale = 1
                                        lastScale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        scale = 2
                                        lastScale = 2
                                    }
                                }
                            }
                    }
                    if let description = photo.description,
                       !description.isEmpty {
                        ScrollView {
                            Text(description)
                                .font(.body.bold())
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.primaryBrown)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                        .frame(maxHeight: 96)
                        .background(.bgTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let imageData = photo.data,
                   let jpegData = UIImage(data: imageData)?.jpegData(compressionQuality: 0.5) {
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent("\(challengeTitle.replacingOccurrences(of: " ", with: "_")).jpeg")
                    ShareLink(
                        item: tempURL,
                        preview: SharePreview(
                            challengeTitle,
                            image: Image(uiImage: UIImage(data: imageData) ?? UIImage())
                        )
                    )
                    .onAppear {
                        try? jpegData.write(to: tempURL)
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text(challengeTitle)
                    .font(.custom("YoungSerif-Regular", size: 17))
                    .foregroundStyle(.primaryBrown)
            }
        }
    }
}
