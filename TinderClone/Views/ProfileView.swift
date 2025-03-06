import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @Binding var isLoggedIn: Bool
    
    @State private var userProfile: UserProfile = {
        if let data = UserDefaults.standard.data(forKey: "UserProfileKey"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return decoded
        } else {
            return UserProfile(
                name: "John Doe",
                grade: 11,
                gpa: 3.8,
                satOrAct: "SAT: 1450",
                extracurriculars: "Soccer team, Debate Club, Robotics",
                isPublicSchool: true,
                intendedMajor: "Computer Science",
                academicHonors: "National Merit Semifinalist",
                imageData: nil
            )
        }
    }()
    
    @State private var showEditProfile = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 1) Profile Image
                if let data = userProfile.imageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                        .shadow(radius: 5)
                } else {
                    Image("img_jd")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                        .shadow(radius: 5)
                }
                
                // 2) Display relevant fields
                VStack(spacing: 5) {
                    Text("\(userProfile.name), Grade \(userProfile.grade)")
                        .font(.system(size: 25))
                        .fontWeight(.heavy)
                    
                    Text("GPA: \(userProfile.gpa, specifier: "%.2f") | \(userProfile.satOrAct)")
                    Text(userProfile.extracurriculars)
                    
                    Text(userProfile.isPublicSchool ? "Public School" : "Private School")
                        .foregroundColor(.secondary)
                    
                    if let major = userProfile.intendedMajor {
                        Text("Intended Major: \(major)")
                    }
                    if let honors = userProfile.academicHonors {
                        Text("Honors: \(honors)")
                    }
                }
                
                // 3) Example row with "Settings" & "Edit Info"
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
                
                // 4) Log Out button at the bottom
                Button(action: logOut) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding() // so the content isn't flush against screen edges
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(userProfile: $userProfile)
        }
        .onChange(of: userProfile) { newValue in
            saveUserProfile(newValue)
        }
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            // If you want to navigate to login, do so in your app logic, e.g.:
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
