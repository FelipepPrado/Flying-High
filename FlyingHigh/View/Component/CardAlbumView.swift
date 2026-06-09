import SwiftUI
import Nuvem

struct CardAlbumView: View {
    var album: Album.Observable
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            NavigationLink(destination: AlbumView(album: album)){
                Group {
                    HStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(album.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.leading)
                                Text("\(album.startDate.formatted(.dateTime.day().month().year())) - \(album.endDate.formatted(.dateTime.day().month().year()))")
                                    .font(.callout)
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 20)
                            .padding(.leading,20)
                            Spacer()
                        }
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 0)
                                    .strokeBorder(
                                        Color(.gray),
                                        style: .init(
                                            lineWidth: 2,
                                            dash: [12, 10]
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 0)
                                    .fill(Color(.white))
                                    .offset(x: -2)
                            }
                        }
                        
                        Rectangle()
                            .fill(Color.gray)
                            .frame(maxHeight: .infinity)
                            .frame(width: 20)
                            .padding(.leading, 42)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

#Preview {
    let album = Album(
        title: "Guaramiranga",
        startDate: .now,
        endDate: .now,
    )
    CardAlbumView(album: album.observable)
}
