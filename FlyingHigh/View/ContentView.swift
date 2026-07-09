import SwiftUI
import CloudKit
import Nuvem
import SwiftData

struct ContentView: View {
    //Modificar o nome depois qualquer coisa!
    @AppStorage("loadCloudKit") var loadCloudKit = true
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AlbumModel.startDate, order: .reverse) var albumsModel: [AlbumModel]
    
    @Environment(ViewRouter.self) var viewRouter
    @Environment(AlbumViewModel.self) var albumViewModel
    
    //Album e photo apenas para pegar os valores antigos do iCloud
    @State private var albums : [Album.Observable] = []
    @State private var photos : [Photo.Observable] = []
    
    @State private var addAlbum: Bool = false
    @State private var loadingCloudKit = false
    @State private var deletAlbum: Bool = false
    
    var body: some View {
        VStack{
            insideView
                .task {
                    loadingCloudKit = true
                    if loadCloudKit{
                        if albumsModel.isEmpty{
                            
                            //Puxa os albums antigos para por no swiftData novo
                            do {
                                self.albums = try await Album.query(on: .private)
                                    .all()
                                    .map(\.observable)
                            } catch {
                                print(error)
                                print("Não foi possível carregar os albums")
                            }
                            
                            //Puxa todas as fotos antigas para por no swiftData novo
                            do {
                                self.photos = try await Photo.query(on: .private)
                                    .all()
                                    .map(\.observable)
                            } catch {
                                print(error)
                                print("Não foi possível carregar as foto")
                            }
                            
                            //Coloca todas as fotos do antigo CloudKit no novo album do swiftData
                            for album in albums{
                                let albumModel = AlbumModel(title: album.title, startDate: album.startDate, endDate: album.endDate, color: album.color)
                                var photosModel: [PhotoModel] = []
                                
                                for photo in photos{
                                    if photo.$album.id == album.id{
                                        photosModel.append(PhotoModel(data: photo.data, descriptionPhoto: photo.description, challengeReference: photo.challengeReference))
                                    }
                                }
                                albumModel.photos = photosModel
                                modelContext.insert(albumModel)
                                
                                do{
                                    try await album.delete(on: .private)
                                    
                                }catch{
                                    print(error)
                                    print("Não foi possível deletar album")
                                }
                            }
                        }
                    }
                }
                .task{
                    //Puxa os challenges do CloudKit
                    //Caso for para dar problema de internet, usar esse código para carregar os challenges de novo!
                    Task{
                        await loadChallenges()
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
                                ForEach(albumsModel){ album in
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
                            .opacity(albumsModel.isEmpty ? 0 : 1)
                            
                            NoAlbumView()
                                .opacity(albumsModel.isEmpty ? 1 : 0)
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
                        modelContext.delete(albumViewModel.album)
                        try? modelContext.save()
                    }
                }message: {
                    Text("Após confirmar a ação, a experiência será deletada e não poderá ser recuperada.")
                }
            }
        }
    }
    
    func loadChallenges() async{
        if albumViewModel.loadChallenges{
            do {
                albumViewModel.challenges = try await Challenge.query(on: .public)
                    .all()
                    .map(\.observable)
                albumViewModel.loadChallenges = false
                
                //Fazer isso, faz com que o app não funcione se não tiver um pingo de internet
                loadingCloudKit = false
            } catch{
                print(error)
                print("Não foi possível carregar os challenges")
            }
        }
    }
}

//#Preview {
//    ContentView()
//        .environment(ViewRouter())
//}
