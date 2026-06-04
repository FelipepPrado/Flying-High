import CloudKit
import Nuvem

@CKModel
struct Challenge{
    @CKField("title")
    var title: String
    
    @CKAssetField("icon")
    var icon: Data
    
    @CKField("selected")
    var selected: Int //Vou tratar como boolean 0 ou 1
}
