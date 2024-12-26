import Foundation

// MARK: - Analysis Types

struct HealthInsights {
    let trends: [HealthTrend]
    let correlations: [HealthCorrelation]
    let anomalies: [HealthAnomaly]
    
    init(trends: [HealthTrend] = [], correlations: [HealthCorrelation] = [], anomalies: [HealthAnomaly] = []) {
        self.trends = trends
        self.correlations = correlations
        self.anomalies = anomalies
    }
}

struct HealthPredictions {
    let shortTerm: [HealthPrediction]
    let longTerm: [HealthPrediction]
    let confidence: Double
    
    init(shortTerm: [HealthPrediction] = [], longTerm: [HealthPrediction] = [], confidence: Double = 0.0) {
        self.shortTerm = shortTerm
        self.longTerm = longTerm
        self.confidence = confidence
    }
}

struct HealthRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let priority: RecommendationPriority
    let category: RecommendationCategory
    let impact: Double
    let timeframe: TimeInterval
    
    init(title: String = "", description: String = "", priority: RecommendationPriority = .medium, 
         category: RecommendationCategory = .general, impact: Double = 0.0, timeframe: TimeInterval = 0) {
        self.title = title
        self.description = description
        self.priority = priority
        self.category = category
        self.impact = impact
        self.timeframe = timeframe
    }
}

// MARK: - Supporting Types

struct HealthTrend {
    let metric: HealthMetric
    let direction: TrendDirection
    let magnitude: Double
    let period: TimeInterval
}

struct HealthCorrelation {
    let factorA: HealthFactor
    let factorB: HealthFactor
    let strength: Double
    let type: CorrelationType
}

struct HealthAnomaly {
    let metric: HealthMetric
    let value: Double
    let expectedRange: ClosedRange<Double>
    let timestamp: Date
}

struct HealthPrediction {
    let metric: HealthMetric
    let value: Double
    let confidence: Double
    let timeframe: TimeInterval
}

enum HealthMetric {
    case steps
    case heartRate
    case weight
    case sleep
    case activity
    case stress
    case nutrition
}

enum HealthFactor {
    case exercise
    case diet
    case sleep
    case stress
    case environment
    case social
    case work
}

enum TrendDirection {
    case increasing
    case decreasing
    case stable
    case fluctuating
}

enum CorrelationType {
    case positive
    case negative
    case none
}

enum RecommendationPriority {
    case high
    case medium
    case low
}

enum RecommendationCategory {
    case exercise
    case nutrition
    case sleep
    case stress
    case lifestyle
    case environment
    case general
}

// MARK: - Context Types

struct AnalysisContext {
    let timeframe: TimeInterval
    let factors: [HealthFactor]
    let location: Bool
    let environmental: Bool
    
    init(timeframe: TimeInterval = 604800, // 1 week
         factors: [HealthFactor] = [],
         location: Bool = false,
         environmental: Bool = false) {
        self.timeframe = timeframe
        self.factors = factors
        self.location = location
        self.environmental = environmental
    }
}

struct RecommendationContext {
    let goal: HealthGoal
    let constraints: [HealthConstraint]
    let preferences: UserPreferences
    
    init(goal: HealthGoal = .general,
         constraints: [HealthConstraint] = [],
         preferences: UserPreferences = UserPreferences()) {
        self.goal = goal
        self.constraints = constraints
        self.preferences = preferences
    }
}

enum HealthGoal {
    case weightLoss
    case muscleGain
    case endurance
    case stress
    case sleep
    case general
}

enum HealthConstraint {
    case time
    case location
    case equipment
    case medical
    case dietary
}

struct UserPreferences {
    let exerciseTypes: [String]
    let dietaryRestrictions: [String]
    let timePreferences: [TimeInterval]
    
    init(exerciseTypes: [String] = [],
         dietaryRestrictions: [String] = [],
         timePreferences: [TimeInterval] = []) {
        self.exerciseTypes = exerciseTypes
        self.dietaryRestrictions = dietaryRestrictions
        self.timePreferences = timePreferences
    }
}
