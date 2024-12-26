import Foundation
import StoreKit

final class SubscriptionViewModel: ObservableObject {
    private let paymentManager = PaymentManager.shared
    private let subscriptionManager = SubscriptionManager.shared
    
    // MARK: - Published Properties
    
    @Published var selectedPlan: SubscriptionPlan?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    @Published var availablePlans: [SubscriptionPlan] = []
    
    // MARK: - Computed Properties
    
    var isEnterprise: Bool {
        subscriptionManager.currentSubscription == .enterprise
    }
    
    // MARK: - Initialization
    
    init() {
        loadPlans()
    }
    
    // MARK: - Public Methods
    
    func selectPlan(_ plan: SubscriptionPlan) {
        selectedPlan = plan
        subscribe(to: plan)
    }
    
    func contactEnterpriseSales() {
        // Open enterprise sales contact form or email
        if let url = URL(string: "https://ibiome.com/enterprise") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPlans() {
        // Personal Plan
        let personalPlan = SubscriptionPlan(
            id: "personal",
            name: "Personal",
            description: "Perfect for individual health tracking",
            price: 9.99,
            interval: .monthly,
            features: [
                SubscriptionFeature(
                    description: "Advanced Health Analytics",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "Custom Visualizations",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "Data Export",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "Priority Support",
                    isIncluded: true
                )
            ],
            tier: .personal
        )
        
        // Research Plan
        let researchPlan = SubscriptionPlan(
            id: "research",
            name: "Research",
            description: "Advanced tools for researchers",
            price: 49.99,
            interval: .monthly,
            features: [
                SubscriptionFeature(
                    description: "All Personal Features",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "Batch Processing",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "ML Pipelines",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "Research API Access",
                    isIncluded: true
                )
            ],
            tier: .research
        )
        
        // Enterprise Plan
        let enterprisePlan = SubscriptionPlan(
            id: "enterprise",
            name: "Enterprise",
            description: "Custom solutions for organizations",
            price: 99.99,
            interval: .monthly,
            features: [
                SubscriptionFeature(
                    description: "All Research Features",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "Custom Integration",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "Dedicated Support",
                    isIncluded: true
                ),
                SubscriptionFeature(
                    description: "SLA Guarantee",
                    isIncluded: true
                )
            ],
            tier: .enterprise
        )
        
        availablePlans = [personalPlan, researchPlan, enterprisePlan]
    }
    
    private func subscribe(to plan: SubscriptionPlan) {
        Task {
            do {
                isLoading = true
                try await paymentManager.subscribe(to: plan.tier)
                
                await MainActor.run {
                    showSuccess(for: plan)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError(error)
                    isLoading = false
                }
            }
        }
    }
    
    private func showSuccess(for plan: SubscriptionPlan) {
        alertMessage = "Successfully subscribed to \(plan.name) plan!"
        showAlert = true
    }
    
    private func handleError(_ error: Error) {
        alertMessage = error.localizedDescription
        showAlert = true
    }
}

// MARK: - Preview Helper

extension SubscriptionViewModel {
    static var preview: SubscriptionViewModel {
        let viewModel = SubscriptionViewModel()
        // Add preview data
        return viewModel
    }
}
