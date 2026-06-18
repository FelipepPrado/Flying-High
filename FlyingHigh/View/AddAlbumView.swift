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
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack (spacing: 0){
                Rectangle()
                    .fill(Color(selectedColor))
                    .frame(height: 24)
                
                VStack (spacing: 26){
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nome da experiência")
                            .fontWeight(.medium)
                            .padding(.leading,8)
                        TextField(text: $title, label: {
                            Text("Digite o nome")
                                .foregroundStyle(Color(.systemGray3))
                        })
                            .fontWeight(.medium)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(.systemGray5), lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    HStack (alignment: .top){
                        VStack (alignment: .leading, spacing: 26) {
                            VStack (alignment: .leading, spacing: 12) {
                                Text("Data da Ida")
                                    .fontWeight(.medium)
                                    .padding(.leading,8)
                                HStack {
                                    Text(startDate.formatted(.dateTime.day().month().year()))
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: 170)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(.systemGray5), lineWidth: 2)
                                    )
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
                                    .fontWeight(.medium)
                                    .padding(.leading,8)
                                HStack {
                                    Text(endDate.formatted(.dateTime.day().month().year()))
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: 170)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(.systemGray5), lineWidth: 2)
                                    )
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
                        
                        RoundedRectangle(cornerRadius: 60)
                            .stroke(Color(.systemGray5), lineWidth: 2)
                            .frame(width: 120, height: 120)
                            
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 6)
                }
                .padding(.top, 30)
                .padding(.bottom, 100)
                .background(.white)
                
                HStack(spacing: 0) {
                    Image(.ticketCut)
                    Rectangle()
                        .fill(Color(.white))
                        .frame(height: 40)
                    Image(.ticketCut)
                        .scaleEffect(x: -1, y: 1)
                }
                .overlay(BottomBorder()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [12, 10]))
                    .foregroundStyle(.gray)
                )
                
                HStack(alignment: .bottom){
                    CustonColorView(selectedColor: $selectedColor)
                    Spacer()
                    Text("Nome do App")
                        .font(.system(size: 13, weight: .semibold))
                }
                .padding(EdgeInsets(top: 4, leading: 16, bottom: 16, trailing: 22))
                .background(.white)
                
                Rectangle()
                    .fill(Color(selectedColor))
                    .frame(height: 24)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 2)
            .padding(.horizontal, 24)
        }
        .navigationTitle("Adicionar Experiência")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Emitir Ticket"){
                    albumViewModel.title = title
                    albumViewModel.startDate = startDate
                    albumViewModel.endDate = endDate
                    albumViewModel.color = selectedColor
                    
                    viewRouter.addChallenge()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 4)
                .disabled(title.isEmpty || endDate < startDate)
                .buttonStyle(.borderedProminent)
                .buttonStyle(.glassProminent)
                .tint(.blue)
            }
        }
        .onTapGesture {
            dismissKeyboard()
        }
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
