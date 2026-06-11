import SwiftUI
import Nuvem

struct CardAlbumView: View {
    var album: Album.Observable
    
    @State private var photos: [Photo.Observable] = []
    @State private var progress: Double = 0
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            NavigationLink(destination: AlbumView(album: album, progress: $progress)){
                Group {
                    HStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 20) {
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
                                .padding(.leading, 2)
                                HStack(alignment: .center, spacing: 6){
                                    ProgressView(value: progress)
                                        .progressViewStyle(CustomProgressBar())
                                        .frame(height: 12)
                                        
                                    let progressText = String(format:"%.0f", (progress*100).rounded())
                                    Text("\(progressText)%")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                }
                                
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal,20)
                            Spacer()
                            
                        }
                        .overlay {
                            TrailingBorder()
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [12, 10]))
                                .foregroundStyle(.gray)
                        }
                        
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
    }
    
    func loadPhotos() async {
        do {
            self.photos = try await Photo.query(on: .private)
                .filter(\.$album == album.id)
                .all()
                .map(\.observable)
            returnProgress()
        } catch {
            print(error)
        }
    }
    
    func returnProgress(){
        var completedChallenges: Int = 0
        if !(photos.isEmpty){
            for photo in photos {
                if photo.data != nil{
                    completedChallenges += 1
                }
            }
            progress = Double(completedChallenges) / Double(photos.count)
        }
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

struct CustomProgressBar: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 12)
                    .foregroundStyle(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Rectangle()
                    .frame(width: width * CGFloat(configuration.fractionCompleted ?? 0.0), height: 12)
                    .foregroundStyle(Color(.systemGray))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
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
