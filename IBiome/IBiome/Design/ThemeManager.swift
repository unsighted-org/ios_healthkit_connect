import SwiftUI

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: ThemeMode = .system
    @Published var userInterfaceStyle: ColorScheme = .light
    @AppStorage("selectedTheme") private var savedTheme: String = ThemeMode.system.rawValue
    
    // Dynamic color system
    @Published var colors: ThemeColors
    
    private init() {
        self.colors = ThemeColors()
        loadSavedTheme()
    }
    
    func setTheme(_ theme: ThemeMode) {
        currentTheme = theme
        savedTheme = theme.rawValue
        updateColors()
    }
    
    private func loadSavedTheme() {
        if let theme = ThemeMode(rawValue: savedTheme) {
            currentTheme = theme
            updateColors()
        }
    }
    
    private func updateColors() {
        colors = ThemeColors(theme: currentTheme)
    }
}

// MARK: - Theme Mode
enum ThemeMode: String {
    case light
    case dark
    case system
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - Theme Colors
struct ThemeColors {
    // Primary Colors
    let primary = Color("BiomePrimary", bundle: .main)
    let secondary = Color("BiomeSecondary", bundle: .main)
    let accent = Color("BiomeAccent", bundle: .main)
    
    // Background Colors
    let background = Color("BiomeBackground", bundle: .main)
    let secondaryBackground = Color("BiomeSecondaryBackground", bundle: .main)
    let tertiaryBackground = Color("BiomeTertiaryBackground", bundle: .main)
    
    // Text Colors
    let primaryText = Color("BiomePrimaryText", bundle: .main)
    let secondaryText = Color("BiomeSecondaryText", bundle: .main)
    let tertiaryText = Color("BiomeTertiaryText", bundle: .main)
    
    // Status Colors
    let success = Color("BiomeSuccess", bundle: .main)
    let warning = Color("BiomeWarning", bundle: .main)
    let error = Color("BiomeError", bundle: .main)
    let info = Color("BiomeInfo", bundle: .main)
    
    // Health Colors
    let heart = Color("BiomeHeart", bundle: .main)
    let activity = Color("BiomeActivity", bundle: .main)
    let sleep = Color("BiomeSleep", bundle: .main)
    let mindfulness = Color("BiomeMindfulness", bundle: .main)
    
    // Environmental Colors
    let nature = Color("BiomeNature", bundle: .main)
    let water = Color("BiomeWater", bundle: .main)
    let air = Color("BiomeAir", bundle: .main)
    let earth = Color("BiomeEarth", bundle: .main)
    
    init(theme: ThemeMode = .system) {
        // Colors are handled by asset catalog with dark/light variants
    }
}

// MARK: - Typography
struct Typography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
}

// MARK: - Layout
struct Layout {
    // Spacing
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
    
    // Corner Radius
    static let radiusXS: CGFloat = 4
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 24
    static let radiusXXL: CGFloat = 32
    
    // Shadows
    static let shadowSM: CGFloat = 2
    static let shadowMD: CGFloat = 4
    static let shadowLG: CGFloat = 8
    static let shadowXL: CGFloat = 16
}

// MARK: - Animation
struct BiomeAnimation {
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let easeOut = Animation.easeOut(duration: 0.2)
    static let easeIn = Animation.easeIn(duration: 0.2)
    static let easeInOut = Animation.easeInOut(duration: 0.3)
}

// MARK: - View Modifiers
struct BiomeCardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .padding(Layout.md)
            .background(themeManager.colors.secondaryBackground)
            .cornerRadius(Layout.radiusMD)
            .shadow(
                color: colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.1),
                radius: Layout.shadowMD,
                x: 0,
                y: Layout.shadowSM
            )
    }
}

struct BiomeButtonStyle: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    let type: ButtonType
    
    enum ButtonType {
        case primary
        case secondary
        case tertiary
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Layout.md)
            .padding(.vertical, Layout.sm)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(Layout.radiusSM)
            .animation(BiomeAnimation.spring, value: type)
    }
    
    private var backgroundColor: Color {
        switch type {
        case .primary:
            return themeManager.colors.primary
        case .secondary:
            return themeManager.colors.secondary
        case .tertiary:
            return .clear
        }
    }
    
    private var foregroundColor: Color {
        switch type {
        case .primary, .secondary:
            return .white
        case .tertiary:
            return themeManager.colors.primary
        }
    }
}

// MARK: - View Extensions
extension View {
    func biomeCard() -> some View {
        modifier(BiomeCardStyle())
    }
    
    func biomeButton(_ type: BiomeButtonStyle.ButtonType = .primary) -> some View {
        modifier(BiomeButtonStyle(type: type))
    }
}
