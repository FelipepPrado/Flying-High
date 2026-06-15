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
    
    init(title: String, startDate: Date, endDate: Date) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.record = CKRecord(recordType: "Album")
    }
}

//View Model do Album, serve apenas para salvar as informações
@Observable
class AlbumViewModel{
    var albums: [Album.Observable] = []
    var challenges: [Challenge.Observable] = []
    var loadChallenges: Bool = true
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var photos: [Photo]?
    
    func addAlbum(album: Album) {
        self.albums.append(album.observable)
        self.albums = self.albums.sorted{$0.startDate > $1.startDate}
    }
    
    init(){
        
    }
}
