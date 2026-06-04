import SwiftUI
import CloudKit
import Nuvem

struct ContentView: View {
    @Environment(ViewRouter.self) var viewRouter
    
    @State private var albums : [Album.Observable] = []
    @State private var addAlbum: Bool = false
    
    var body: some View {
        @Bindable var path = viewRouter
        NavigationStack(path: $path.path){
            ZStack{
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView{
                    ForEach(albums){ album in
                        CardAlbum(album: album)
                    }
                    .task {
                        do {
                            self.albums = try await Album.query(on: .private)
                                .all()
                                .map(\.observable)
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Albums")
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestination(for: NameViews.self){
                destination in
                ViewManagar.viewForDestination(destination)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Album", systemImage: "plus"){
                        viewRouter.addInfoAlbum()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonStyle(.glassProminent)
                    .tint(.blue)
                }
            }
        }
    }
}
