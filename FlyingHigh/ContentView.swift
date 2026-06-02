import SwiftUI
import CloudKit
import Nuvem

struct ContentView: View {
    @State var albums : [Album.Observable] = []
    @State var challenges : [Challenge.Observable] = [] //Não vai printar, pois não existe
    @State var selectedChallenges: [Challenge.Observable] = []
    @State var addAlbum: Bool = false
//    @State var challenges: [Challenge.Observable] = []
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(albums){ album in
                    Text(album.title)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Album", systemImage: "plus"){
                        addAlbum.toggle()
                    }
                }
            }
            .task {
                do {
                    self.albums = try await Album.query(on: .default)
                        .all()
                        .map(\.observable)
                } catch {
                    print(error)
                }
            }
            .navigationTitle("Albums")
            .navigationDestination(isPresented: $addAlbum){
                AddAlbumView(albums: albums)
            }
        }
    }
}

struct AddAlbumView: View {
    var albums: [Album.Observable]
    @State var title: String = ""
    @State var startDate: Date = Date.now
    @State var endDate: Date = Date.now
    
    var body: some View {
        Form{
            Section{
                TextField("Name", text: $title)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
            }
        }
    }
}


//#Preview {
//    ContentView()
//}
