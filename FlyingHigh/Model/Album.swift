import CloudKit
import Nuvem
import Observation

@CKModel
struct Album{
    @CKField("title")
    var title: String
    
    @CKField("startDate")
    var startDate: Date
    
    @CKField("endDate")
    var endDate: Date
}

//View Model do Album, serve apenas para salvar as informações
@Observable
class AlbumViewModel{
    var albums: [Album.Observable] = []
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var photos: [Photo]?
    
    init(){
        
    }
}
