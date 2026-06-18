import SwiftUI
import Nuvem

struct CardAlbumView: View {
    var album: Album.Observable
    
    @State private var photos: [Photo.Observable] = []
    @State private var progress: Double = 0
    
    var body: some View {
        ZStack{
            //Color(.bgPrimary).ignoresSafeArea()
            NavigationLink(destination: AlbumView(album: album, progress: $progress)){
                Group {
                    VStack(alignment: .leading, spacing: 0) {
                        Rectangle()
                            .fill(Color(.userBlue))
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(album.title)
                                    .font(Font.custom("YoungSerif-Regular", size: 34, relativeTo: .largeTitle))
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                    .lineSpacing(-4)
                                    .lineHeight(.multiple(factor: 1.2))
                                    .foregroundStyle(.primaryBrown)
                                    .multilineTextAlignment(.leading)
                                Text("\(album.startDate.formatted(.dateTime.day().month().year())) - \(album.endDate.formatted(.dateTime.day().month().year()))")
                                    .font(.callout)
                                    .foregroundStyle(.primaryBrown)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 22)
                            .padding(.vertical, 24)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.bgTertiary))
                        
                        HStack(spacing: 0) {
                            Image(.ticketCut)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 15, height: 30)
                                .colorMultiply(.bgTertiary)
                            Rectangle()
                                .fill(Color(.bgTertiary))
                                .frame(height: 30)
                            Image(.ticketCut)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 15, height: 30)
                                .colorMultiply(.bgTertiary)
                                .scaleEffect(x: -1, y: 1)
                        }
                        .overlay(BottomBorder()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [12, 10]))
                            .foregroundStyle(.primaryBrown)
                        )
                        
                        HStack(alignment: .center, spacing: 6){
                            ProgressView(value: progress)
                                .progressViewStyle(CustomProgressBar(progressHeight: 12, backgroundColor: .bgSecondary, progressColor: .userBlue))
                                .frame(height: 12)
                            
                            let progressText = String(format:"%.0f", (progress*100).rounded())
                            Text("\(progressText)%")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                        .background(Color(.bgTertiary))
                        
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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

struct CustomProgressBar: ProgressViewStyle {
    let progressHeight: Int
    let backgroundColor: Color
    let progressColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: CGFloat(progressHeight))
                    .foregroundStyle(Color(backgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(progressHeight)/2))
                Rectangle()
                    .frame(width: width * CGFloat(configuration.fractionCompleted ?? 0.0), height: CGFloat(progressHeight))
                    .foregroundStyle(Color(progressColor))
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(progressHeight)/2))
            }
        }
    }
}

#Preview {
    let album = Album(
        title: "Nome da Experiência",
        startDate: .now,
        endDate: .now,
        color: "user-red"
    )
    CardAlbumView(album: album.observable)
}
