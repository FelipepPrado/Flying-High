import SwiftUI
import Nuvem

struct CardAlbum: View {
    var album: Album
    
    var body: some View {
        NavigationLink(destination: AlbumView(album: album)){
            HStack {
                VStack(alignment: .leading) {
                    Text(album.title)
                    HStack{
                        Text("\(album.startDate.formatted(.dateTime.day().month().year())) -")
                        Text("\(album.endDate.formatted(.dateTime.day().month().year()))")
                    }
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 12, trailing: 16))
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
    }
}

