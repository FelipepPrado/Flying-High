import SwiftUI
import CloudKit
import Nuvem

struct ContentView: View {
    @Environment(ViewRouter.self) var viewRouter
    @Environment(AlbumViewModel.self) var albumViewModel
    
    @State private var albums : [Album.Observable] = []
    @State private var addAlbum: Bool = false
    @State private var loadingCloudKit = false
    
    var body: some View {
        insideView
            .task {
                do {
                    loadingCloudKit = true
                    self.albums = try await Album.query(on: .private)
                        .all()
                        .map(\.observable)
                    albumViewModel.albums = albums.sorted{$0.startDate > $1.startDate}
                        
                } catch {
                    print(error)
                }
                loadingCloudKit = false
            }
            .task{
                if albumViewModel.loadChallenges{
                    do {
                        albumViewModel.challenges = try await Challenge.query(on: .public)
                            .all()
                            .map(\.observable)
                        albumViewModel.loadChallenges = false
                    } catch{
                        print(error)
                    }
                }
            }
        
    }
    
    
    var insideView: some View {
        Group{
            if loadingCloudKit{
                LoadingScreen()
            }
            else{
                @Bindable var path = viewRouter
                NavigationStack(path: $path.path){
                    ZStack{
                        Color(.bgPrimary).ignoresSafeArea()
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                ForEach(albumViewModel.albums){ album in
                                    CardAlbumView(album: album)
                                }
                               
                            }
                            .shadow(color: .black.opacity(0.2),radius: 10, x: 0, y: 2)
                            .padding()
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
                    .navigationDestination(for: NameViews.self){
                        destination in
                        ViewManagar.viewForDestination(destination)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Adcionar experiência", systemImage: "plus"){
                                viewRouter.addInfoAlbum()
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonStyle(.glassProminent)
                            .tint(.accent)
                        }
                        ToolbarItem(placement: .principal) {
                            Text("Minhas Experiências")
                                .font(.custom("YoungSerif-Regular", size: 17))
                                .foregroundStyle(.primaryBrown)
                        }
                    }

                }
            }
            
        }
        
        
    }
}

//#Preview {
//    ContentView()
//        .environment(ViewRouter())
//}
