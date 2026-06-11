import SwiftUI
import CloudKit
import Nuvem

struct AddChallengesView: View {
    @Environment(AlbumViewModel.self) var albumViewModel
    @Environment(ViewRouter.self) var viewRouter
    
    @State var challenges : [Challenge.Observable] = []
    @State var selectedChallenges: [Challenge.Observable] = []
//    @State var photos : [Photo.Observable] = []
    @State var isChecked: Bool = false
    
    var body: some View {
        
        
        ///tela na qual apresenta os desafios com seus ícones e categorias
        ///
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView{
                ForEach(challenges){ challenge in
                    CardChallenge(challenge: challenge, selectedChallenges: $selectedChallenges)
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
            .padding()
        }
        .navigationTitle("Selecionar Desafios")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .confirmationAction){
                Button(role: .confirm){
                    Task{
                        await save()
                    }
                    viewRouter.initView()
                }
                .accessibilityLabel(Text("Salvar informações"))
            }
        }
    }
    
    func save() async{
        var album: Album
        do{
            album = Album(
                title: albumViewModel.title ?? "",
                startDate: albumViewModel.startDate ?? Date.now,
                endDate: albumViewModel.endDate ?? Date.now,
            )
            try await album.save(on: .private)
            albumViewModel.addAlbum(album: album)
        } catch{
            print(error)
        }
        
        var photos: [any CKModel] = []
//        for challenge in challenges {
//            if challenge.selected == 1 {
//                let photo = Photo(data: nil, description: "", album: album, challengeReference: challenge.id)
//                photos.append(photo)
//            }
//        }
        for challenge in selectedChallenges {
            let photo = Photo(data: nil, description: "", album: album, challengeReference: challenge.id)
            photos.append(photo)
        }
        do {
            try await photos.save(on: .private)
        } catch {
            print(error)
        }
        Task{
            try await Task.sleep(for: .seconds(3))
        }
    }
}
