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
    
    @CKField("color")
    var color: String?
    
    init(title: String, startDate: Date, endDate: Date, color: String?) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
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
    var color: String?
    var photos: [Photo]?
    
    func addAlbum(album: Album) {
        self.albums.append(album.observable)
        self.albums = self.albums.sorted{$0.startDate > $1.startDate}
    }
    
    init(){
        
    }
}
