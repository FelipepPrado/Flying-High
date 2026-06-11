import SwiftUI
import Nuvem

struct CardChallenge: View {
    var challenge: Challenge.Observable
    @Binding var selectedChallenges: [Challenge.Observable]
    
    //Variável para ser usada p/ observar o estado para o VoiceOver
    @State private var isChecked: Bool = false
    @State private var selected: Bool = false
    
    var body: some View {
        Button(action:{
            print(selected)
            selected.toggle()
            print()
            if selected{
                selectedChallenges.append(challenge)
            }
            else{
                selectedChallenges.removeAll(where: {$0.id == challenge.id})
            }
            isChecked = selected
        }){
            ///Essa é a árrea que tem tem os botoes de check junto com o nome de cada categoria
            HStack(spacing: 16){
                if selected{
                    Image(systemName: "checkmark.circle.fill")
                }
                else{
                    Image(systemName: "checkmark.circle")
                }
                
                HStack(spacing: 12){
                    if let icon = UIImage(data: challenge.icon){
                        Image(uiImage: icon)
                    }
                    Text(challenge.title)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .accessibilityRepresentation {
            Toggle(isOn: $isChecked) {
                Text("\(challenge.title)")
            }
        }
        
    }
}

