import Foundation

/// Core logic for calculating fitness metrics and health analytics
public enum FitnessAnalyticsService {
    
    /// Calculate Body Mass Index (BMI)
    public static func calculateBMI(weightInKg: Double, heightInMeters: Double) -> Double? {
        guard heightInMeters > 0 else { return nil }
        return weightInKg / (heightInMeters * heightInMeters)
    }
    
    /// Categorize BMI result
    public static func categorizeBMI(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    /// Estimate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
    public static func estimateBMR(
        weightInKg: Double,
        heightInCm: Double,
        age: Int,
        gender: String
    ) -> Double {
        let baseBMR = (10 * weightInKg) + (6.25 * heightInCm) - (5.0 * Double(age))
        if gender.lowercased() == "male" {
            return baseBMR + 5
        } else {
            return baseBMR - 161
        }
    }
    
    /// Calculate Total Daily Energy Expenditure (TDEE) based on activity level
    public static func calculateTDEE(bmr: Double, activityMultiplier: Double) -> Double {
        return bmr * activityMultiplier
    }
    
    /// Map steps to approximate distance (meters)
    public static func stepsToMeters(_ steps: Int, stepLengthInMeters: Double = 0.76) -> Double {
        return Double(steps) * stepLengthInMeters
    }
    
    /// Map steps to approximate calories burned
    public static func stepsToCalories(_ steps: Int) -> Int {
        // Rough estimate: 2000 steps ~ 100 calories
        return Int(Double(steps) * 0.05)
    }
}
