import SwiftUI
import Nuvem

struct EditAlbumView: View {
    var album: Album.Observable
    
    @Environment(\.dismiss) var dismiss
    
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
        .onAppear {
            title = album.title
            startDate = album.startDate
            endDate = album.endDate
        }
        .navigationTitle("Editar Álbum")
        .navigationBarTitleDisplayMode( .inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction){
                Button(role: .confirm){
                    Task{
                        await save()
                    }
                }
                .disabled(title == album.title && startDate == album.startDate && endDate == album.endDate)
            }
        }
    }
    func save() async{
        do{
            album.title = title
            album.startDate = startDate
            album.endDate = endDate
            try await album.save(on: .private)
            dismiss()
        } catch{
            print(error)
        }
    }
}

