import SwiftUI
import Nuvem

struct EditAlbumView: View {
    var album: Album.Observable
    @Environment(\.dismiss) var dismiss
    
    @State var title: String = ""
    @State var startDate: Date = Date.now
    @State var endDate: Date = Date.now
    @State var selectedColor: String = "user-blue"
    @State var addChallenges: Bool = false
    
    var body: some View {
        ZStack{
            Color(.bgPrimary).ignoresSafeArea()
            VStack (spacing: 0){
                Rectangle()
                    .fill(Color(selectedColor))
                    .frame(height: 24)
                
                VStack (spacing: 26){
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nome da experiência")
                            .fontWeight(.semibold)
                            .padding(.leading,8)
                            .font(Font.body.smallCaps())
                            .foregroundStyle(.primaryBrown)
                        TextField(text: $title, label: {
                            Text("Digite o nome")
                                .fontWeight(.medium)
                                .foregroundStyle(Color(.tertiaryBrown))
                        })
                        .foregroundStyle(Color(.primaryBrown))
                        .fontWeight(.medium)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    HStack (alignment: .top){
                        VStack (alignment: .leading, spacing: 26) {
                            VStack (alignment: .leading, spacing: 12) {
                                Text("Data da Ida")
                                    .fontWeight(.semibold)
                                    .padding(.leading,8)
                                    .font(Font.body.smallCaps())
                                    .foregroundStyle(.primaryBrown)
                                HStack {
                                    Text(format(startDate))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primaryBrown)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: 170)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                .overlay {
                                    DatePicker(
                                        "Selecione uma data de ida",
                                        selection: $startDate,
                                        in: Date.now...,
                                        displayedComponents: .date,
                                    )
                                    .labelsHidden()
                                    .colorMultiply(.clear)
                                }
                            }
                            
                            VStack (alignment: .leading, spacing: 12) {
                                Text("Data da Volta")
                                    .fontWeight(.semibold)
                                    .padding(.leading,8)
                                    .font(Font.body.smallCaps())
                                    .foregroundStyle(.primaryBrown)
                                HStack {
                                    Text(format(endDate))
                                        .fontWeight(.medium)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primaryBrown)
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: 170)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                .overlay {
                                    DatePicker(
                                        "Selecione uma data de volta",
                                        selection: $endDate,
                                        in: startDate...,
                                        displayedComponents: .date
                                    )
                                    .labelsHidden()
                                    .colorMultiply(.clear)
                                    .onChange(of: startDate) {
                                        if startDate > endDate{
                                            endDate = startDate
                                        }
                                    }
                                }
                                
                            }
                        }
                        Spacer()
                        
                        Image("stamp-ticket")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .accessibilityHidden(true)
                        
                    }
                    
                    CustonColorView(selectedColor: $selectedColor)
                }
                .padding(.top, 30)
                .padding(.bottom, 40)
                .padding(.horizontal, 20)
                
                .background(.bgTertiary)
                
                HStack(spacing: 0) {
                    Image(.ticketCut)
                        .colorMultiply(.bgTertiary)
                    Rectangle()
                        .fill(Color(.bgTertiary))
                        .frame(height: 40)
                    Image(.ticketCut)
                        .scaleEffect(x: -1, y: 1)
                        .colorMultiply(.bgTertiary)
                }
                .overlay(BottomBorder()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [12, 10]))
                    .foregroundStyle(.primaryBrown)
                )
                
                HStack(alignment: .bottom){
                    Spacer()
                    Text("Desvio")
                        .font(.custom("YoungSerif-Regular", size: 13))
                        .foregroundStyle(.primaryBrown)
                }
                .padding(EdgeInsets(top: 4, leading: 22, bottom: 16, trailing: 22))
                .background(.bgTertiary)
                
                Rectangle()
                    .fill(Color(selectedColor))
                    .frame(height: 24)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 2)
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            title = album.title
            startDate = album.startDate
            endDate = album.endDate
            selectedColor = album.color ?? "user-color"
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Atualizar Ticket"){
                    Task{
                        await save()
                    }
                }
                .disabled(title == album.title && startDate == album.startDate && endDate == album.endDate && selectedColor == album.color)
                .padding(.horizontal, 32)
                .padding(.vertical, 4)
                .buttonStyle(.borderedProminent)
                .buttonStyle(.glassProminent)
                .tint(.accent)
            }
            ToolbarItem(placement: .principal) {
                Text("Editar Experiência")
                    .font(.custom("YoungSerif-Regular", size: 17))
                    .foregroundStyle(.primaryBrown)
            }
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    func format(_ date: Date) -> String {
        date.formatted(
            .verbatim(
                "\(day: .defaultDigits) \(month: .abbreviated) \(year: .defaultDigits)",
                locale: .current,
                timeZone: .current,
                calendar: .current,
            )
        )
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func save() async{
        do{
            album.title = title
            album.startDate = startDate
            album.endDate = endDate
            album.color = selectedColor
            try await album.save(on: .private)
            dismiss()
        } catch{
            print(error)
        }
    }
}

