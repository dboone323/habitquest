func calculateOptimalDifficulty(
    analysis: PlayerBehaviorAnalysis,
    aiInsights: AIInsights,
    currentDifficulty: AIAdaptiveDifficulty
) -> AIAdaptiveDifficulty {
    // Weight different factors
    let successWeight = 0.3
    let reactionWeight = 0.25
    let predictionWeight = 0.25
    let aiWeight = 0.2

    // Calculate difficulty score based on performance
    var difficultyScore = 0.0

    // Success rate contribution (lower success = easier difficulty)
    difficultyScore += (1.0 - analysis.successRate) * successWeight

    // Reaction time contribution (slower reactions = easier difficulty)
    let normalizedReactionTime = min(analysis.averageReactionTime / 2.0, 1.0) // Cap at 2 seconds
    difficultyScore += normalizedReactionTime * reactionWeight

    // Prediction-based adjustments
    let predictionAdjustment = calculatePredictionAdjustment(predictions: analysis.predictions)
    difficultyScore += predictionAdjustment * predictionWeight

    // AI insights contribution
    let aiDifficultyScore = difficultyScoreFromAI(aiInsights.recommendedDifficulty)
    difficultyScore += aiDifficultyScore * aiWeight

    // Calculate confidence
    lastAdjustmentConfidence = calculateConfidence(analysis: analysis, aiInsights: aiInsights)

    // Convert score to difficulty level
    return difficultyFromScore(difficultyScore)
}

private func calculatePredictionAdjustment(predictions: PlayerBehaviorPredictions) -> Double {
    var adjustment = 0.0

    // Adjust based on predicted risk level
    switch predictions.riskAssessment {
    case .conservative:
        adjustment += 0.2 // Make slightly easier for conservative players
    case .moderate:
        adjustment += 0.0 // No adjustment
    case .adventurous:
        adjustment -= 0.1 // Make slightly harder for adventurous players
    case .reckless:
        adjustment -= 0.2 // Make significantly harder for reckless players
    }

    // Adjust based on pattern recognition
    for pattern in predictions.patternRecognition {
        switch pattern {
        case .hesitant:
            adjustment += 0.15 // Easier for hesitant players
        case .aggressive:
            adjustment -= 0.1 // Harder for aggressive players
        case .methodical:
            adjustment += 0.05 // Slightly easier for methodical players
        case .chaotic:
            adjustment -= 0.05 // Slightly harder for chaotic players
        }
    }

    // Scale by confidence
    return adjustment * predictions.confidence
}
