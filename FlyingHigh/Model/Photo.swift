import CloudKit
import Nuvem
import SwiftData

@CKModel
struct Photo {
    @CKAssetField("photo")
    var data: Data?
    
    @CKField("description")
    var description: String?
    
    @CKReferenceField("album", action: .deleteSelf)
    var album: Album?
    
    @CKField("challengeReference")
    var challengeReference: String?
}

@Model
class PhotoModel{
    var data: Data?
    var descriptionPhoto: String?
    var album: AlbumModel?
    var challengeReference: String?
    
    init(data: Data? = nil, descriptionPhoto: String? = nil, album: AlbumModel? = nil, challengeReference: String? = nil) {
        self.data = data
        self.descriptionPhoto = descriptionPhoto
        self.album = album
        self.challengeReference = challengeReference
    }
}
