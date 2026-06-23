import SwiftUI
import CloudKit
import Nuvem

struct ContentView: View {
    @Environment(ViewRouter.self) var viewRouter
    @Environment(AlbumViewModel.self) var albumViewModel
    
    @State private var albums : [Album.Observable] = []
    @State private var addAlbum: Bool = false
    @State private var loadingCloudKit = false
    @State private var deletAlbum: Bool = false
    
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
            @Bindable var path = viewRouter
            NavigationStack(path: $path.path){
                ZStack{
                    Color(.bgPrimary).ignoresSafeArea()
                    
                    if loadingCloudKit{
                        SkeletonContentView()
                    }
                    else{
                        ZStack{
                            List {
                                ForEach(albumViewModel.albums){ album in
                                    CardAlbumView(album: album)
                                        .shadow(color: .black.opacity(0.2),radius: 10, x: 0, y: 2)
                                        .padding()
                                        .listRowBackground(EmptyView())
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        .navigationLinkIndicatorVisibility(.hidden)
                                        .swipeActions{
                                            Button("Excluir", systemImage: "trash.fill"){
                                                albumViewModel.album = album
                                                deletAlbum.toggle()
                                            }
                                            .tint(.red)
                                            
                                            Button("Editar", systemImage: "square.and.pencil"){
                                                albumViewModel.album = album
                                                viewRouter.editAlbum()
                                            }
                                            .tint(Color.accent)
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .opacity(albumViewModel.albums.isEmpty ? 0 : 1)
                            
                            NoAlbumView()
                                .opacity(albumViewModel.albums.isEmpty ? 1 : 0)
                        }
                    }
                }
                .toolbarTitleDisplayMode(.inline)
                .navigationDestination(for: NameViews.self){
                    destination in
                    ViewManagar.viewForDestination(destination)
                }
                .toolbar {
                    if !loadingCloudKit {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Adicionar experiência", systemImage: "plus"){
                                viewRouter.addInfoAlbum()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accent)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Minhas Experiências")
                            .font(.custom("YoungSerif-Regular", size: 17))
                            .foregroundStyle(.primaryBrown)
                    }
                }
                .alert(
                    "Deseja mesmo excluir a Experiência?",
                    isPresented: $deletAlbum
                ) {
                    Button("Cancelar",role: .cancel) {}
                    
                    Button("Deletar", role: .destructive){
                        Task{
                            await deletAlbum()
                        }
                    }
                }message: {
                    Text("Após confirmar a ação, a experiência será deletado e não poderá ser recuperado.")
                }
            }
        }
    }
    
    func deletAlbum() async{
        do{
            try await albumViewModel.album.delete(on: .private)
            albumViewModel.albums.removeAll(where: { $0.id == albumViewModel.album.id })
        }
        catch{
            print(error)
        }
    }
}

//#Preview {
//    ContentView()
//        .environment(ViewRouter())
//}
