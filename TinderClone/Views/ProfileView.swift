import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @Binding var isLoggedIn: Bool
    
    @State private var userProfile: UserProfile = {
        // 1) Try to load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "UserProfileKey"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return decoded
        } else {
            // 2) Fallback to a blank/minimal profile
            return UserProfile(
                name: "",
                grade: 9,
                gpa: 0.0,
                satOrAct: "",
                extracurriculars: "",
                isPublicSchool: false,
                intendedMajor: nil,
                academicHonors: nil,
                imageData: nil
            )
        }
    }()
    
    @State private var showEditProfile = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Profile Image
                if let data = userProfile.imageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                        .shadow(radius: 5)
                } else {
                    // Placeholder image
                    Image("img_jd")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                        .shadow(radius: 5)
                }
                
                // Display fields
                VStack(spacing: 5) {
                    Text("\(userProfile.name.isEmpty ? "Name not set" : userProfile.name), Grade \(userProfile.grade)")
                        .font(.system(size: 25))
                        .fontWeight(.heavy)
                    
                    Text("GPA: \(userProfile.gpa, specifier: "%.2f") | \(userProfile.satOrAct.isEmpty ? "No SAT/ACT" : userProfile.satOrAct)")
                    Text(userProfile.extracurriculars.isEmpty ? "No extracurriculars" : userProfile.extracurriculars)
                    
                    Text(userProfile.isPublicSchool ? "Public School" : "Private School")
                        .foregroundColor(.secondary)
                    
                    if let major = userProfile.intendedMajor, !major.isEmpty {
                        Text("Intended Major: \(major)")
                    }
                    if let honors = userProfile.academicHonors, !honors.isEmpty {
                        Text("Honors: \(honors)")
                    }
                }
                
                // Buttons
                HStack(spacing: 50) {
                    VStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 35, weight: .heavy))
                            .foregroundColor(.gray)
                            .frame(width: 70, height: 70)
                            .modifier(ButtonBG())
                            .cornerRadius(35)
                            .modifier(ThemeShadow())
                        Text("Settings")
                    }
                    Spacer()
                    VStack(spacing: 8) {
                        Button(action: {
                            showEditProfile = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 35, weight: .heavy))
                                .foregroundColor(.gray)
                                .frame(width: 70, height: 70)
                                .modifier(ButtonBG())
                                .cornerRadius(35)
                                .modifier(ThemeShadow())
                        }
                        Text("Edit Info")
                    }
                }
                .padding(.horizontal, 35)
                
                // Log Out
                Button(action: logOut) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showEditProfile) {
            // Pass userProfile binding to EditProfileView
            EditProfileView(userProfile: $userProfile)
        }
        .onChange(of: userProfile) { newValue in
            saveUserProfile(newValue)
        }
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            // Clear user defaults
            UserDefaults.standard.removeObject(forKey: "UserProfileKey")
            isLoggedIn = false
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }

    
    private func saveUserProfile(_ profile: UserProfile) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "UserProfileKey")
        }
    }
}
