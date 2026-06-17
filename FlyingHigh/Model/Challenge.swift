import CloudKit
import Nuvem
import SwiftUI

@CKModel
struct Challenge{
    @CKField("title")
    var title: String
    
    @CKAssetField("icon")
    var icon: UIImage
}
