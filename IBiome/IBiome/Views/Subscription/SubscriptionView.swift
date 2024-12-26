import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Plans
                    plansSection
                    
                    // MARK: - Enterprise
                    if !viewModel.isEnterprise {
                        enterpriseSection
                    }
                    
                    // MARK: - Features
                    featuresSection
                }
                .padding()
            }
            .navigationTitle("Subscription Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Subscription", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image("subscription_header")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
            
            Text("Unlock Premium Features")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Choose the plan that best fits your needs")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Plans Section
    
    private var plansSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.availablePlans) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: viewModel.selectedPlan == plan,
                    action: {
                        viewModel.selectPlan(plan)
                    }
                )
            }
        }
    }
    
    // MARK: - Enterprise Section
    
    private var enterpriseSection: some View {
        VStack(spacing: 16) {
            Text("Need Enterprise Features?")
                .font(.headline)
            
            Button {
                viewModel.contactEnterpriseSales()
            } label: {
                Text("Contact Sales")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Text("Custom solutions for businesses and organizations")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(.headline)
            
            ForEach(viewModel.selectedPlan?.features ?? []) { feature in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text(feature.description)
                        .font(.subheadline)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.name)
                        .font(.headline)
                    
                    Text(plan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(plan.priceDescription)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Types

struct SubscriptionPlan: Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let interval: SubscriptionInterval
    let features: [SubscriptionFeature]
    let tier: SubscriptionManager.SubscriptionTier
    
    var priceDescription: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        
        let priceString = formatter.string(from: price as NSDecimalNumber) ?? ""
        return "\(priceString)/\(interval.description)"
    }
}

enum SubscriptionInterval: String {
    case monthly
    case yearly
    
    var description: String {
        switch self {
        case .monthly: return "month"
        case .yearly: return "year"
        }
    }
}

struct SubscriptionFeature: Identifiable {
    let id = UUID()
    let description: String
    let isIncluded: Bool
}
