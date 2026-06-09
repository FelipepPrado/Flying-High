import CloudKit
import Nuvem

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
