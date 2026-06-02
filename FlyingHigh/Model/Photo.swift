import CloudKit
import Nuvem

@CKModel
struct Photo {
    @CKAssetField("photo")
    var data: Data?
    
    @CKReferenceField("challenge")
    var challenge: Challenge?
    
    @CKField("description")
    var description: String?
}
