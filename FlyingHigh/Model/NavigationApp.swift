import SwiftUI
import Observation

//Nome das telas
enum NameViews: Hashable{
    case Init
    case AddInfoAlbum
    case AddChallenge
}


//Router da append com o nome da tela (NameViews) no path
//path: A array de telas que ficam empilhadas
@Observable
class ViewRouter{
    var path = NavigationPath()
    
    func clear(){
        path = .init()
        
    }
    
    func initView(){
        self.clear()
    }
    
    func addInfoAlbum(){
        path.append(NameViews.AddInfoAlbum)
    }
    
    func addChallenge(){
        path.append(NameViews.AddChallenge)
    }
}

//Manager pega o nome da View adicionado pelo ViewRouter e empilha uma tela na navegação
//Único detalhe é a não possibilidade de ficar mandando coisas via Binding ou let para as outras views
enum ViewManagar {
    @ViewBuilder
    static func viewForDestination(_ destination: NameViews) -> some View {
        switch destination {
        case .Init:
            ContentView()
            
        case .AddInfoAlbum:
            AddAlbumView()
        case .AddChallenge:
            SwipeActionButtonView()
        }
    }
}
