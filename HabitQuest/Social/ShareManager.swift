import Foundation
import Social

/// Social sharing manager for HabitQuest
class ShareManager {
    static let shared = ShareManager()

    private init() {}

    // MARK: - Share Achievement

    func shareAchievement(_ achievement: Achievement, completion: @escaping (Bool) -> Void) {
        let text = generateAchievementText(achievement)
        let image = generateAchievementImage(achievement)

        share(text: text, image: image, completion: completion)
    }

    // MARK: - Share Streak

    func shareStreak(_ streak: Int, habit: String, completion: @escaping (Bool) -> Void) {
        let text = """
        🔥 \(streak)-day streak on \(habit)!

        Loving HabitQuest! Join me in building better habits.
        #HabitQuest #Productivity
        """

        let image = generateStreakImage(streak: streak, habit: habit)

        share(text: text, image: image, completion: completion)
    }

    // MARK: - Share Milestone

    // MARK: - Share Milestone

    func shareMilestone(_ milestone: StreakMilestone, completion: @escaping (Bool) -> Void) {
        let text = "🎉 \(milestone.title)! \(milestone.description) #HabitQuest"
        let image = generateMilestoneImage(milestone)

        share(text: text, image: image, completion: completion)
    }

    // MARK: - Share Methods

    private func share(text: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        var items: [Any] = [text]
        if let image = image {
            items.append(image)
        }

        // iOS Share Sheet
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        activityVC.completionWithItemsHandler = { _, completed, _, _ in
            completion(completed)
        }

        // Present from top view controller
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            topVC.present(activityVC, animated: true)
        }
    }

    // MARK: - Image Generation

    private func generateAchievementImage(_ achievement: Achievement) -> UIImage? {
        let size = CGSize(width: 1200, height: 630) // Social media optimized
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Background gradient
            let colors = [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: 0, y: size.height),
                options: []
            )

            // Achievement text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 60, weight: .bold),
                .foregroundColor: UIColor.white
            ]

            let text = achievement.name as NSString
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }

    private func generateStreakImage(streak: Int, habit: String) -> UIImage? {
        let size = CGSize(width: 1200, height: 630)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Background
            UIColor.systemOrange.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Streak number
            let streakText = "\(streak)" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 120, weight: .heavy),
                .foregroundColor: UIColor.white
            ]

            let textSize = streakText.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: 200,
                width: textSize.width,
                height: textSize.height
            )
            streakText.draw(in: textRect, withAttributes: attributes)

            // Fire emoji
            let emoji = "🔥" as NSString
            let emojiAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 80)
            ]
            let emojiSize = emoji.size(withAttributes: emojiAttributes)
            let emojiRect = CGRect(
                x: (size.width - emojiSize.width) / 2,
                y: 350,
                width: emojiSize.width,
                height: emojiSize.height
            )
            emoji.draw(in: emojiRect, withAttributes: emojiAttributes)
        }
    }

    private func generateMilestoneImage(_ milestone: StreakMilestone) -> UIImage? {
        generateStreakImage(streak: milestone.streakCount, habit: "Achievement")
    }

    private func generateAchievementText(_ achievement: Achievement) -> String {
        """
        🏆 Achievement Unlocked: \(achievement.name)

        \(achievement.achievementDescription)

        #HabitQuest #Productivity #Goals
        """
    }
}
