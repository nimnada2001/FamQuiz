//
//  Question.swift
//  Multi-User Family Quiz Arena
//
//  Model representing quiz questions and answers
//  Includes placeholder quiz data for demonstration
//

import Foundation

/// Represents a single quiz question with multiple choice answers
struct Question: Identifiable, Codable {
    let id: UUID
    let text: String
    let answers: [String] // Array of 4 possible answers
    let correctAnswerIndex: Int // 0-3 indicating correct answer
    let category: QuizCategory
    let difficulty: Difficulty
    let explanation: String? // Optional explanation for learning

    init(id: UUID = UUID(), text: String, answers: [String], correctAnswerIndex: Int, category: QuizCategory, difficulty: Difficulty = .medium, explanation: String? = nil) {
        self.id = id
        self.text = text
        self.answers = answers
        self.correctAnswerIndex = correctAnswerIndex
        self.category = category
        self.difficulty = difficulty
        self.explanation = explanation
    }
}

/// Quiz categories for organizing questions
enum QuizCategory: String, Codable, CaseIterable {
    case science = "Science"
    case history = "History"
    case geography = "Geography"
    case entertainment = "Entertainment"
    case sports = "Sports"
    case generalKnowledge = "General Knowledge"

    var emoji: String {
        switch self {
        case .science: return "🔬"
        case .history: return "📜"
        case .geography: return "🌍"
        case .entertainment: return "🎬"
        case .sports: return "⚽️"
        case .generalKnowledge: return "🧠"
        }
    }

    var color: String {
        switch self {
        case .science: return "blue"
        case .history: return "purple"
        case .geography: return "green"
        case .entertainment: return "pink"
        case .sports: return "orange"
        case .generalKnowledge: return "yellow"
        }
    }
}

/// Difficulty levels for questions
enum Difficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

/// Quiz game configuration
struct QuizConfig {
    var numberOfQuestions: Int = 10
    var timePerQuestion: TimeInterval = 15.0
    var pointsForCorrect: Int = 100
    var bonusForSpeed: Bool = true // Award bonus points for fast answers
    var categories: [QuizCategory] = QuizCategory.allCases
}

// MARK: - Placeholder Quiz Data

extension Question {
    /// Returns a collection of Sri Lankan quiz questions
    static var sampleQuestions: [Question] {
        return [
            // History Questions - Sri Lanka
            Question(
                text: "In which year did Sri Lanka gain independence?",
                answers: ["1945", "1948", "1950", "1956"],
                correctAnswerIndex: 1,
                category: .history,
                difficulty: .easy,
                explanation: "Sri Lanka gained independence from British rule on February 4, 1948."
            ),
            Question(
                text: "Who was the first Prime Minister of independent Ceylon (Sri Lanka)?",
                answers: ["D.S. Senanayake", "S.W.R.D. Bandaranaike", "Dudley Senanayake", "J.R. Jayewardene"],
                correctAnswerIndex: 0,
                category: .history,
                difficulty: .medium,
                explanation: "D.S. Senanayake became the first Prime Minister in 1947."
            ),
            Question(
                text: "Which ancient kingdom was famous for the rock fortress Sigiriya?",
                answers: ["Polonnaruwa", "Anuradhapura", "Kandy", "None - it was built by King Kashyapa"],
                correctAnswerIndex: 3,
                category: .history,
                difficulty: .medium,
                explanation: "Sigiriya was built by King Kashyapa I in the 5th century."
            ),
            Question(
                text: "When did Sri Lanka become a republic?",
                answers: ["1948", "1956", "1972", "1978"],
                correctAnswerIndex: 2,
                category: .history,
                difficulty: .hard
            ),

            // Geography Questions - Sri Lanka
            Question(
                text: "What is the capital of Sri Lanka?",
                answers: ["Colombo", "Sri Jayawardenepura Kotte", "Kandy", "Galle"],
                correctAnswerIndex: 1,
                category: .geography,
                difficulty: .medium,
                explanation: "Sri Jayawardenepura Kotte is the administrative capital, while Colombo is the commercial capital."
            ),
            Question(
                text: "Which is the highest mountain in Sri Lanka?",
                answers: ["Adam's Peak", "Pidurutalagala", "Horton Plains", "Knuckles Range"],
                correctAnswerIndex: 1,
                category: .geography,
                difficulty: .medium,
                explanation: "Pidurutalagala stands at 2,524 meters (8,281 feet)."
            ),
            Question(
                text: "How many provinces are there in Sri Lanka?",
                answers: ["7", "9", "11", "13"],
                correctAnswerIndex: 1,
                category: .geography,
                difficulty: .easy
            ),
            Question(
                text: "Which river is the longest in Sri Lanka?",
                answers: ["Kelani River", "Mahaweli River", "Kalu River", "Gin River"],
                correctAnswerIndex: 1,
                category: .geography,
                difficulty: .medium,
                explanation: "The Mahaweli River is approximately 335 km long."
            ),
            Question(
                text: "Which ancient city was the first capital of Sri Lanka?",
                answers: ["Polonnaruwa", "Anuradhapura", "Sigiriya", "Kandy"],
                correctAnswerIndex: 1,
                category: .geography,
                difficulty: .easy
            ),

            // Sports Questions - Sri Lanka Cricket
            Question(
                text: "In which year did Sri Lanka win the Cricket World Cup?",
                answers: ["1992", "1996", "1999", "2007"],
                correctAnswerIndex: 1,
                category: .sports,
                difficulty: .easy,
                explanation: "Sri Lanka won the 1996 Cricket World Cup by defeating Australia in the final."
            ),
            Question(
                text: "Who is known as the 'Mahela' among Sri Lankan cricketers?",
                answers: ["Sanath Jayasuriya", "Kumar Sangakkara", "Mahela Jayawardene", "Muttiah Muralitharan"],
                correctAnswerIndex: 2,
                category: .sports,
                difficulty: .easy
            ),
            Question(
                text: "Which Sri Lankan cricketer holds the record for most Test wickets?",
                answers: ["Chaminda Vaas", "Muttiah Muralitharan", "Rangana Herath", "Lasith Malinga"],
                correctAnswerIndex: 1,
                category: .sports,
                difficulty: .easy,
                explanation: "Muttiah Muralitharan has 800 Test wickets, the most by any bowler."
            ),
            Question(
                text: "What is the main cricket stadium in Colombo called?",
                answers: ["Galle International Stadium", "R. Premadasa Stadium", "Pallekele Stadium", "SSC Ground"],
                correctAnswerIndex: 1,
                category: .sports,
                difficulty: .medium
            ),

            // Entertainment/Culture Questions - Sri Lanka
            Question(
                text: "What is the traditional New Year celebrated in Sri Lanka called?",
                answers: ["Vesak", "Aluth Avurudda", "Poson", "Esala Perahera"],
                correctAnswerIndex: 1,
                category: .entertainment,
                difficulty: .easy,
                explanation: "Aluth Avurudda (Sinhala and Tamil New Year) is celebrated in April."
            ),
            Question(
                text: "Which famous Sri Lankan dish is made with rice and curry?",
                answers: ["Kottu Roti", "Hoppers", "Rice and Curry", "Lamprais"],
                correctAnswerIndex: 2,
                category: .entertainment,
                difficulty: .easy
            ),
            Question(
                text: "What is the traditional dance form of Kandy called?",
                answers: ["Bharatanatyam", "Kandyan Dance", "Low Country Dance", "Sabaragamuwa Dance"],
                correctAnswerIndex: 1,
                category: .entertainment,
                difficulty: .medium
            ),

            // General Knowledge Questions - Sri Lanka
            Question(
                text: "What is the national flower of Sri Lanka?",
                answers: ["Lotus", "Blue Water Lily", "Orchid", "Jasmine"],
                correctAnswerIndex: 1,
                category: .generalKnowledge,
                difficulty: .medium,
                explanation: "The Blue Water Lily (Nil Manel) is the national flower."
            ),
            Question(
                text: "Which temple houses the sacred tooth relic of Buddha?",
                answers: ["Kelaniya Temple", "Temple of the Tooth", "Ruwanwelisaya", "Jetavanarama"],
                correctAnswerIndex: 1,
                category: .generalKnowledge,
                difficulty: .easy,
                explanation: "The Temple of the Tooth (Sri Dalada Maligawa) is in Kandy."
            ),
            Question(
                text: "What is the former name of Sri Lanka?",
                answers: ["Burma", "Ceylon", "Siam", "Bengal"],
                correctAnswerIndex: 1,
                category: .generalKnowledge,
                difficulty: .easy
            ),
            Question(
                text: "Which animal is prominently featured in Sri Lankan wildlife?",
                answers: ["Tiger", "Elephant", "Lion", "Panda"],
                correctAnswerIndex: 1,
                category: .generalKnowledge,
                difficulty: .easy,
                explanation: "Sri Lankan elephants are a subspecies of Asian elephants."
            ),
            Question(
                text: "What is Sri Lanka's national sport?",
                answers: ["Cricket", "Volleyball", "Football", "Athletics"],
                correctAnswerIndex: 1,
                category: .generalKnowledge,
                difficulty: .medium,
                explanation: "Volleyball is the national sport, though cricket is more popular."
            )
        ]
    }
}
