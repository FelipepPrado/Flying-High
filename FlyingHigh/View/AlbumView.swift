import SwiftUI
import Nuvem

struct AlbumView: View {
    var album: Album
    @State private var photos: [Photo.Observable] = []
    @State private var challenges: [Challenge.Observable] = []
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView{
                ForEach(photos){ photo in
                    VStack(alignment: .center, spacing: 4){
                        if photo.data == nil{
                            let challenge = getChallenge(challengeReference: photo.challengeReference)
                            if challenge != nil {
                                VStack(alignment: .center, spacing: 4){
                                    if let icon = UIImage(data: challenge?.icon ?? Data()){
                                        Image(uiImage: icon)
                                    }
                                    Text(challenge?.title ?? "Sem valor")
                                }
                                .frame(minWidth: 180, minHeight: 240)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .task {
                    do {
                        self.photos = try await Photo.query(on: .private)
                            .filter(\.$album == album.id)
                            .all()
                            .map(\.observable)
                    } catch {
                        print(error)
                    }
                }
                .task {
                    do {
                        self.challenges = try await Challenge.query(on: .public)
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
    
    func getChallenge(challengeReference : String?) -> Challenge.Observable?{
        //        print(challengeReference)
        if let challenge = challenges.first(where: {$0.id == challengeReference}){
            print("desafio encontrado")
            print(challenge.title)
            return challenge
        }
        
        return nil
    }
}
