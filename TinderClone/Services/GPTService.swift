import Foundation

class GPTService {
    // (A) Insert your OpenAI API key here
    private let apiKey = "YOUR_OPENAI_API_KEY"

    // (B) A shared instance (singleton) if you want easy global access
    static let shared = GPTService()

    // (C) The main function to check admission
    func checkAdmission(profile: UserProfile, collegeName: String, completion: @escaping (Bool) -> Void) {
        
        // Step 1: Build a prompt from userProfile + collegeName
        let prompt = buildPrompt(profile: profile, collegeName: collegeName)

        // Step 2: Prepare the JSON body
        let requestBody: [String: Any] = [
            "model": "text-davinci-003", // or "gpt-3.5-turbo" with a different endpoint
            "prompt": prompt,
            "max_tokens": 10,
            "temperature": 0.0
        ]

        // Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Error: Could not serialize JSON")
            completion(false)
            return
        }

        // Step 3: Create the URL
        guard let url = URL(string: "https://api.openai.com/v1/completions") else {
            completion(false)
            return
        }

        // Step 4: Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        // Attach body
        request.httpBody = jsonData

        // Step 5: Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for basic errors
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let data = data else {
                completion(false)
                return
            }

            // Step 6: Parse JSON response
            do {
                // Typically: { "choices": [ { "text": "..."} ], ... }
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let text = choices.first?["text"] as? String {
                    
                    // Step 7: Decide if it's a "yes" or "no"
                    let lower = text.lowercased()
                    let isYes = lower.contains("yes")
                    completion(isYes)
                } else {
                    completion(false)
                }
            } catch {
                print("JSON parse error: \(error.localizedDescription)")
                completion(false)
            }
        }

        task.resume()
    }

    // Helper function to build the prompt
    private func buildPrompt(profile: UserProfile, collegeName: String) -> String {
        return """
        The student has these stats:
        Name: \(profile.name)
        Grade: \(profile.grade)
        GPA: \(profile.gpa)
        SAT/ACT: \(profile.satOrAct)
        Extracurriculars: \(profile.extracurriculars)
        Public school: \(profile.isPublicSchool ? "Yes" : "No")

        Based on these stats, do you think they will get admitted to \(collegeName)? 
        Answer ONLY yes or no.
        """
    }
}
