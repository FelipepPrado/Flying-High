import CloudKit
import Nuvem

@CKModel
struct Challenge{
    @CKField("title")
    var title: String
    
    @CKAssetField("icon")
    var icon: Data
}
