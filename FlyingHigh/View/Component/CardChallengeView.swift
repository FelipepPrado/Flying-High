import SwiftUI
import Nuvem

struct CardChallenge: View {
    var challenge: Challenge.Observable
    
    //Variável para ser usada p/ observar o estado para o VoiceOver
    @State private var isCked: Bool = false
    
    var body: some View {
        Button(action:{
            if challenge.selected == 1{
                challenge.selected = 0
            }
            else{
                challenge.selected = 1
            }
        }){
            ///Essa é a árrea que tem tem os botoes de check junto com o nome de cada categoria
        
            HStack(spacing: 16){
                if challenge.selected == 0{
                    Image(systemName: "checkmark.circle")
                }
                else{
                    Image(systemName: "checkmark.circle.fill")
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
    }
}

