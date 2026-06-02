import SwiftUI

struct AddAlbumView: View {
    var albums: [Album.Observable]
    @State var title: String = ""
    @State var startDate: Date = Date.now
    @State var endDate: Date = Date.now
    @State var path = NavigationPath()
    @State private var ispresented: Bool = false
    @State var addInfo: Bool = false
    @State var addAlbum: Bool = false


    
    var body: some View {
            Form{
                Section("Detalhes da viagem"){
                    TextField("Name", text: $title)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add info", systemImage: "arrow.right"){
                        addInfo.toggle()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonStyle(.glassProminent)
            .tint(.blue)
            
            .navigationDestination(isPresented: $addInfo){
            }
    }
}
