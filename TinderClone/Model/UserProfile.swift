import SwiftUI

struct UserProfile: Codable, Equatable {
    // Basic fields
    var name: String
    var grade: Int
    var gpa: Double
    var satOrAct: Int
    var extracurriculars: String
    var isPublicSchool: Bool
    
    // Optional fields
    var intendedMajor: String?
    var academicHonors: String?
    
    // Image data stored as Data
    var imageData: Data?
}
