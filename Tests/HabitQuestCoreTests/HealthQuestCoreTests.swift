import Testing
@testable import HabitQuestCore

struct HealthQuestCoreTests {
    @Test
    func modelInitialization() {
        let profile = HealthProfile(name: "Test User")
        #expect(profile.name == "Test User")
    }

    @Test
    func bMICalculation() {
        let bmi = FitnessAnalyticsService.calculateBMI(weightInKg: 70.0, heightInMeters: 1.75)
        #expect(bmi != nil)
        if let bmi {
            #expect(bmi > 22.0 && bmi < 23.0)
        }
    }
}
