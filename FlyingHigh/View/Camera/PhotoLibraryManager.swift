import Photos
import UIKit

final class PhotoLibraryManager {

    func requestAuthorization() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {

        case .authorized:
            return true

        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            return status == .authorized

        case .limited:
            return true

        default:
            return false
        }
    }

    func saveImages(_ images: [UIImage]) async throws {
        print("Entrou no save e vai pedir autorização")

        let authorized = await requestAuthorization()
        
        print("Passou da autorização")
        guard authorized else {
            print("autorização negada")
            throw NSError(
                domain: "PhotoLibrary",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                    "Permissão negada."
                ]
            )
        }
        
        print("autorização permitida")

        try await PHPhotoLibrary.shared().performChanges {
            for image in images {
                PHAssetChangeRequest.creationRequestForAsset(
                    from: image
                )
            }
        }
    }
}
