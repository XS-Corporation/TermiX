import SwiftUI

struct PasswordPromptView: View {
    @Binding var password: String
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter sudo password")
                .font(.headline)
            
            SecureField("Password", text: $password, onCommit: onSubmit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.go)
            
            Button("Submit") {
                onSubmit()
            }
        }
        .padding()
        .frame(width: 300)
    }
}

