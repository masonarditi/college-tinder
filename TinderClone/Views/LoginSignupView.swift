import SwiftUI
import FirebaseAuth

struct LoginSignUpView: View {
    @Binding var isLoggedIn: Bool  // We get this from TinderCloneApp

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Firebase Email/Password Auth")
                    .font(.title)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = errorMessage {
                    Text(error).foregroundColor(.red)
                }

                if isLoading {
                    ProgressView("Processing...")
                }

                HStack(spacing: 40) {
                    Button("Log In") {
                        signIn()
                    }
                    Button("Sign Up") {
                        signUp()
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .navigationTitle("Login / Sign Up")
        }
    }

    private func signIn() {
        errorMessage = nil
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                // Sign-in success => set isLoggedIn to true
                isLoggedIn = true
            }
        }
    }

    private func signUp() {
        errorMessage = nil
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                // Sign-up success => set isLoggedIn to true
                isLoggedIn = true
            }
        }
    }
}
