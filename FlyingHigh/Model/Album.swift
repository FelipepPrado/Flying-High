import CloudKit
import Nuvem

@CKModel
struct Album{
    @CKField("title")
    var title: String
    
    @CKField("startDate")
    var startDate: Date
    
    @CKField("endDate")
    var endDate: Date

    @CKReferenceListField("photos")
    var photos: [Photo]?
    
    //Os challenges selecionados seram relacionados as photos
//    @CKReferenceListField("challenges")
//    var challenges: [Challenge]? //Tem que ser opcional?
    
}
