import SwiftUI

struct EditProfileView: View {
    @Binding var userProfile: UserProfile
    @Environment(\.presentationMode) private var presentationMode
    
    @State var showImagePicker = false
    @State var localImage: UIImage?  // Temporarily holds the newly picked image
    
    // Example number formatter for GPA
    var gpaFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Info")) {
                    TextField("Name", text: $userProfile.name)
                    Stepper("Grade: \(userProfile.grade)", value: $userProfile.grade, in: 1...12)
                    
                    TextField("GPA", value: $userProfile.gpa, formatter: gpaFormatter)
                    TextField("SAT/ACT Score", text: $userProfile.satOrAct)
                    
                    Toggle(isOn: $userProfile.isPublicSchool) {
                        Text("Public School?")
                    }
                }
                
                Section(header: Text("Extracurriculars")) {
                    TextEditor(text: $userProfile.extracurriculars)
                        .frame(minHeight: 80)
                }
                
                Section(header: Text("Optional Fields")) {
                    TextField("Intended Major", text: Binding(
                        get: { userProfile.intendedMajor ?? "" },
                        set: { userProfile.intendedMajor = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Academic Honors", text: Binding(
                        get: { userProfile.academicHonors ?? "" },
                        set: { userProfile.academicHonors = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section(header: Text("Profile Image")) {
                    if let data = userProfile.imageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    } else {
                        Text("No Image Selected")
                    }
                    Button("Upload Image") {
                        showImagePicker = true
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $localImage)
        }
        // Whenever localImage changes, store it in userProfile as Data
        .onChange(of: localImage) { newImage in
            if let uiImage = newImage {
                userProfile.imageData = uiImage.pngData()
            }
        }
    }
}
