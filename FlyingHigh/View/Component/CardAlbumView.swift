import SwiftUI
import Nuvem

struct CardAlbumView: View {
    var album: Album.Observable
    
    var body: some View {
//        ZStack{
//            Color(.systemGroupedBackground).ignoresSafeArea()
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
                        .overlay(TrailingBorder()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [12, 10]))
                            .foregroundStyle(.gray)
                        )
                        
                        Rectangle()
                            .fill(Color(.systemGray3))
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
//    }
}

struct TrailingBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY-5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        return path
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
