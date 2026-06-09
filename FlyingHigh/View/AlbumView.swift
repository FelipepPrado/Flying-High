import SwiftUI
import Nuvem

struct AlbumView: View {
    var album: Album.Observable
    @State private var photos: [Photo.Observable] = []
    @State private var challenges: [Challenge.Observable] = []
    @State private var selectedChallenge: Challenge.Observable?
    @State private var showingCamera = false
    @State private var editAlbum = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView{
                LazyVGrid(columns: columns, spacing: 10){
                    ForEach(photos) { photo in
                        if photo.data == nil{
                            let challenge = getChallenge(challengeReference: photo.challengeReference)
                            if let challenge = challenge {
                                Button(action: {
                                    selectedChallenge = challenge
                                    showingCamera = true
                                }){
                                    VStack(alignment: .center, spacing: 4){
                                        if let icon = UIImage(data: challenge.icon){
                                            Image(uiImage: icon)
                                        }
                                        Text(challenge.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(minWidth: 180, minHeight: 240)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
//        .fullScreenCover(isPresented: $showingCamera) {
//            if let challenge = selectedChallenge {
//                CameraView(challengeTitle: challenge.title)
//            }
//        }
        .navigationDestination(isPresented: $showingCamera){
            CameraView(challengeTitle: selectedChallenge?.title ?? "Sem título")
        }
        .navigationDestination(isPresented: $editAlbum){
            EditAlbumView(album: album)
        }
//        .fullScreenCover(isPresented: $showingCamera) {
//            if let challenge = selectedChallenge {
//                CameraView(challengeTitle: challenge.title)
//            }
//        }
        .task {
            await loadPhotos()
        }
        .task {
            await loadChallenges()
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
    
    func loadChallenges() async {
        do {
            self.challenges = try await Challenge.query(on: .public)
                .all()
                .map(\.observable)
        } catch {
            print(error)
        }
    }
    
    func getChallenge(challengeReference: String?) -> Challenge.Observable? {
        guard let challengeReference = challengeReference else { return nil }
        return challenges.first(where: { $0.id == challengeReference })
    }
}
//
//extension Button {
//    
//}
