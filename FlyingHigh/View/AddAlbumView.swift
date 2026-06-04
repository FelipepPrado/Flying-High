import SwiftUI

struct AddAlbumView: View {
    @Environment(AlbumViewModel.self) var albumViewModel
    @Environment(ViewRouter.self) var viewRouter
    
    @State var title: String = ""
    @State var startDate: Date = Date.now
    @State var endDate: Date = Date.now
    @State var addChallenges: Bool = false

    var body: some View {
            Form{
                Section("Informações da viagem"){
                    TextField("Name", text: $title)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
            }
            .navigationTitle("Criar Álbum")
            .navigationBarTitleDisplayMode( .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Challenges", systemImage: "arrow.right"){
                        albumViewModel.title = title
                        albumViewModel.startDate = startDate
                        albumViewModel.endDate = endDate
                        
                        viewRouter.addChallenge()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonStyle(.glassProminent)
                    .tint(.blue)
                }
            }
    }
}
