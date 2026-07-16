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
    
    @State private var addAlbum: Bool = false
    @State private var loadingCloudKit = false
    @State private var deletAlbum: Bool = false
    
    var body: some View {
        VStack{
            insideView
                .task {
                    loadingCloudKit = true
                    //Carrega as coisas antigas da Nuvem, obviamente se a pessoal tiver!
                    if loadCloudKit{
                        print("Carregando os albums antigos do CloudKit...")
                        await getAlbumsForCloudKit()
                    }
                    
                    //Modiquei para essa task acontecer aqui, para que a puxada de coisas do CloudKit seja sequencial
                    //Puxa os challeges da Nuvem
                    await loadChallenges()
                }
        }
    }
    
    func getAlbumsForCloudKit() async{
        //Puxa os albums antigos para por no swiftData novo
        do {
            let albums = try await Album.query(on: .private)
                .all()
                .map(\.observable)
            
            let photos = try await Photo.query(on: .private)
                .all()
                .map(\.observable)
            
            //Se já de início o albums for vazio e o photos for vazio ele já para a função
            if albums.isEmpty && photos.isEmpty{
                print("Sem album e sem foto para carregar!")
                loadCloudKit = false
                return
            }
            
            let localeAlbums = try modelContext.fetch(FetchDescriptor<AlbumModel>())
            
            //Coloca todas as fotos do antigo CloudKit no novo album do swiftData
            for album in albums{
                
                //Verifico se já existe o album no Banco de Dados locais e se existe vou verificar se ta faltando algo
                //Lembrando que pra ele chegar de novo aqui, quer dizer que ocorreu um erro no meio do caminho!
                //Por isso to fazendo esse processo (Chatasso)
                if let haveAlbum = localeAlbums.first(where: { $0.id == album.id }){
                    
                    //Se o haveAlbum for nil eu tenho que inicializar pq se não, eu não vou conseguir por a foto via append
                    if haveAlbum.photos == nil{
                        haveAlbum.photos = []
                    }
                    
                    for photo in photos {
                        if photo.$album.id == album.id {
                            let havePhoto =
                            haveAlbum.photos?.contains(where: {$0.challengeReference == photo.challengeReference})
                            ?? false
                            
                            // Se NÃO existir, adicionamos a foto a esse álbum
                            if !havePhoto {
                                let newPhoto = PhotoModel(
                                    data: photo.data,
                                    descriptionPhoto: photo.description,
                                    challengeReference: photo.challengeReference
                                )
                                haveAlbum.photos?.append(newPhoto)
                            }
                        }
                    }
                }
                //Basicamente se o album não existe no banco de dados loca, ele apenas faz o processo simples se criar e inserir no banco de dados
                else{
                    let albumModel = AlbumModel(id: album.id, title: album.title, startDate: album.startDate, endDate: album.endDate, color: album.color)
                    var photosModel: [PhotoModel] = []
                    
                    for photo in photos{
                        if photo.$album.id == album.id{
                            photosModel.append(PhotoModel(data: photo.data, descriptionPhoto: photo.description, challengeReference: photo.challengeReference))
                        }
                    }
                    albumModel.photos = photosModel
                    modelContext.insert(albumModel)
                }
            }
            
            try modelContext.save()
            
            for album in albums{
                try await album.delete(on: .private)
            }
            
            print("Tudo ok, CloudKit antigo carregado!")
            loadCloudKit = false
        } catch {
            print(error)
            print("Não foi possível carregar completamente o CloudKit antigo")
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
                //Apesar de que deve ter alguma maneira de reverter isso, caso dê erro de internet, ele mostrar um refresh
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
