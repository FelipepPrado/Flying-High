import SwiftUI
import Nuvem

struct CardAlbum: View {
    var album: Album.Observable
    
    var body: some View {
        NavigationLink(destination: AlbumView(album: album)){
            Group {
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
            .accessibilityElement(children: .combine)
        }
    }
}

