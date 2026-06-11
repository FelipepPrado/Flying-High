//
//  CameraModel.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 05/06/26.
//

import AVFoundation
import SwiftUI
import Photos
internal import Combine


class CameraModel: ObservableObject {
    
    let camera = CameraManager()
    
    @Published var maxPhotos = 3
    @Published var photosTaken = 0
    @Published var previewImage: Image?
    @Published var photoToken: PhotoData?
    @Published var exposureValue: Float = 0
    @Published var currentChallengeTitle: String?
    
    init() {
        Task {
            await handleCameraPreviews()
        }
        
        Task {
            await handleCameraPhotos()
        }
    }
    
    var photosRemaining: Int {
        maxPhotos - photosTaken
    }
    
    var canTakePhoto: Bool {
        photosTaken < maxPhotos
    }
    
    var isLastAttempt: Bool {
        photosTaken == maxPhotos - 1
    }
    
    func registerPhotoTaken() {
        guard canTakePhoto else { return }
        photosTaken += 1
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0.image }

        for await image in imageStream {
            Task { @MainActor in
                previewImage = image
            }
        }
    }
    
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            Task { @MainActor in
                if canTakePhoto {
                    photosTaken += 1
                    photoToken = photoData
                }
            }
        }
    }
    
    func retryPhoto() {
        photoToken = nil
    }
    
    func cancelPhotoSession() {
        photoToken = nil
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }
        guard let cgImage = photo.cgImageRepresentation(),
              let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation)
        else { return nil }
        
        let imageOrientation = UIImage.Orientation(cgImageOrientation)
        let uiImage = UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
        let image = Image(uiImage: uiImage)
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        guard let compressedImageData = uiImage.jpegData(compressionQuality: 0.5) else {
            return nil
        }
        return PhotoData(image: image, imageData: compressedImageData, imageSize: imageSize)
    }
}


fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}


fileprivate extension UIImage.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}


struct PhotoData {
    var image: Image
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}



