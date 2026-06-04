import SwiftUI
import Nuvem

struct AlbumView: View {
    var album: Album.Observable
    @State private var photos: [Photo.Observable] = []
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView{
                ForEach(photos){ photo in
                    VStack(alignment: .center, spacing: 4){
                        if let icon = UIImage(data: photo.challenge?.icon ?? Data()){
                            Image(uiImage: icon)
                        }
                        Text(photo.challenge?.title ?? "Sem valor")
                    }
                }
                .task {
                    do {
                        self.photos = try await Photo.query(on: .private)
                            .all()
                            .map(\.observable)
                    } catch {
                        print(error)
                    }
                }
            }
            
        }
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
