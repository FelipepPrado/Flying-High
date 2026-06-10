import SwiftUI
import Nuvem

struct CardAlbumView: View {
    var album: Album.Observable
    
    @State private var photos: [Photo.Observable] = []
    
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
                                ProgressView(value: returnProgress())
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
                .task{
                    await loadPhotos()
                }
            }
        }
    
    func loadPhotos() async {
        do {
            self.photos = try await Photo.query(on: .private)
                .filter(\.$album == album.id)
                .all()
                .map(\.observable)
        } catch {
            print(error)
        }
    }
    
    func returnProgress() -> Double{
        var completedChallenges: Int = 0
        for photo in photos {
            if photo.data != nil{
                completedChallenges += 1
            }
        }
        print(Double(completedChallenges) / Double(photos.count))
        return Double(completedChallenges) / Double(photos.count)
    }
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
