import SwiftUI

struct AddAlbumView: View {
    @Environment(AlbumViewModel.self) var albumViewModel
    @Environment(ViewRouter.self) var viewRouter
    @Environment(\.dismiss) var dismiss
    
    @State var title: String = ""
    @State var startDate: Date = Date.now
    @State var endDate: Date = Date.now
    @State var selectedColor: String = "user-blue"
    @State var addChallenges: Bool = false
    @State var confirmDismiss: Bool = false
    
    var body: some View {
        ZStack{
            Color(.bgPrimary).ignoresSafeArea()
            VStack (spacing: 0){
                Rectangle()
                    .fill(Color(selectedColor))
                    .frame(height: 24)
                
                VStack (spacing: 22){
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nome da experiência")
                            .fontWeight(.semibold)
                            .padding(.leading,8)
                            .font(Font.body.smallCaps())
                            .foregroundStyle(.primaryBrown)
                            .accessibilityHidden(true)
                        TextField(text: $title,
                                  label: {
                            Text("Digite o nome da experiência")
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
                                        .accessibilityHidden(true)

                                        
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: 170)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                .overlay {
                                    DatePicker(
                                        "Clique aqui para escolher uma data de ida",
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
                                        .accessibilityHidden(true)

                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: 170)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                .overlay {
                                    DatePicker(
                                        "Clique aqui para escolher uma data de volta",
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
                        .accessibilityHidden(true)
                }
                .padding(.top, 30)
                .padding(.bottom, 40)
                .padding(.horizontal, 20)
                
                .background(.bgTertiary)
                
                HStack(spacing: 0) {
                    Image(.ticketCut)
                        .colorMultiply(.bgTertiary)
                        .accessibilityHidden(true)
                    Rectangle()
                        .fill(Color(.bgTertiary))
                        .frame(height: 40)
                    Image(.ticketCut)
                        .scaleEffect(x: -1, y: 1)
                        .colorMultiply(.bgTertiary)
                        .accessibilityHidden(true)
                }
                .overlay(BottomBorder()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [12, 10]))
                    .foregroundStyle(.primaryBrown)
                )
                
                HStack(alignment: .bottom){
                    Spacer()
                    Text("Desvio")
                        .accessibilityHidden(true)
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading){
                Button("Retornar a tela de albums", systemImage: "chevron.left"){
                    if title.isEmpty {
                        dismiss()
                    }
                    else{
                        confirmDismiss = true
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Emitir Ticket"){
                    albumViewModel.title = title
                    albumViewModel.startDate = startDate
                    albumViewModel.endDate = endDate
                    albumViewModel.color = selectedColor
                    viewRouter.addChallenge()
                }
                .accessibilityLabel(Text("Clique aqui para 'Emitir Ticket'"))
                .padding(.horizontal, 32)
                .padding(.vertical, 4)
                .disabled(title.isEmpty || endDate < startDate)
                .buttonStyle(.borderedProminent)
                .buttonStyle(.glassProminent)
                .tint(.accent)
            }
            ToolbarItem(placement: .principal) {
                Text("Adicionar Experiência")
                    .font(.custom("YoungSerif-Regular", size: 17))
                    .foregroundStyle(.primaryBrown)
            }
        }
        .onTapGesture {
            dismissKeyboard()
        }
        .alert(
            "",
            isPresented: $confirmDismiss
        ){
            Button("Descartar", role: .destructive){
                dismiss()
            }

        }message: {
            Text("Tem certeza de que deseja descartar esta nova experiência?")
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
}

struct BottomBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX+20, y: rect.maxY/2))
        path.addLine(to: CGPoint(x: rect.maxX-20, y: rect.maxY/2))
        
        return path
    }
}

#Preview {
    AddAlbumView()
        .environment(AlbumViewModel())
        .environment(ViewRouter())
}
