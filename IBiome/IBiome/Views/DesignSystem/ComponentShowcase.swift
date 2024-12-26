import SwiftUI

struct ComponentShowcase: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Layout.xl) {
                    // Typography
                    typographySection
                    
                    // Colors
                    colorSection
                    
                    // Components
                    componentSection
                    
                    // Cards
                    cardSection
                    
                    // Buttons
                    buttonSection
                }
                .padding()
            }
            .navigationTitle("Design System")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Light") { themeManager.setTheme(.light) }
                        Button("Dark") { themeManager.setTheme(.dark) }
                        Button("System") { themeManager.setTheme(.system) }
                    } label: {
                        Image(systemName: "circle.lefthalf.filled")
                    }
                }
            }
        }
    }
    
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: Layout.md) {
            Text("Typography").font(Typography.title1)
            
            Group {
                Text("Large Title").font(Typography.largeTitle)
                Text("Title 1").font(Typography.title1)
                Text("Title 2").font(Typography.title2)
                Text("Title 3").font(Typography.title3)
                Text("Headline").font(Typography.headline)
                Text("Body").font(Typography.body)
                Text("Callout").font(Typography.callout)
                Text("Subheadline").font(Typography.subheadline)
                Text("Footnote").font(Typography.footnote)
                Text("Caption").font(Typography.caption1)
            }
        }
        .biomeCard()
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: Layout.md) {
            Text("Colors").font(Typography.title1)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Layout.md) {
                ColorSwatch("Primary", color: themeManager.colors.primary)
                ColorSwatch("Secondary", color: themeManager.colors.secondary)
                ColorSwatch("Accent", color: themeManager.colors.accent)
                ColorSwatch("Background", color: themeManager.colors.background)
                ColorSwatch("Success", color: themeManager.colors.success)
                ColorSwatch("Warning", color: themeManager.colors.warning)
                ColorSwatch("Error", color: themeManager.colors.error)
                ColorSwatch("Info", color: themeManager.colors.info)
            }
        }
        .biomeCard()
    }
    
    private var componentSection: some View {
        VStack(alignment: .leading, spacing: Layout.md) {
            Text("Components").font(Typography.title1)
            
            // Progress Indicators
            HStack(spacing: Layout.md) {
                ProgressView()
                ProgressView(value: 0.7)
                    .progressViewStyle(.circular)
                    .tint(themeManager.colors.primary)
            }
            
            // Toggles and Sliders
            Toggle("Toggle", isOn: .constant(true))
            Slider(value: .constant(0.5))
                .tint(themeManager.colors.primary)
            
            // Segmented Control
            Picker("Options", selection: $selectedTab) {
                Text("First").tag(0)
                Text("Second").tag(1)
                Text("Third").tag(2)
            }
            .pickerStyle(.segmented)
        }
        .biomeCard()
    }
    
    private var cardSection: some View {
        VStack(alignment: .leading, spacing: Layout.md) {
            Text("Cards").font(Typography.title1)
            
            // Simple Card
            VStack(alignment: .leading, spacing: Layout.sm) {
                Text("Simple Card")
                    .font(Typography.headline)
                Text("This is a simple card with some content.")
                    .font(Typography.body)
            }
            .biomeCard()
            
            // Interactive Card
            Button {
                // Action
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Interactive Card")
                            .font(Typography.headline)
                        Text("Tap me!")
                            .font(Typography.subheadline)
                            .foregroundColor(themeManager.colors.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(themeManager.colors.primary)
                }
            }
            .biomeCard()
        }
        .biomeCard()
    }
    
    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: Layout.md) {
            Text("Buttons").font(Typography.title1)
            
            Button("Primary Button") { }
                .biomeButton(.primary)
            
            Button("Secondary Button") { }
                .biomeButton(.secondary)
            
            Button("Tertiary Button") { }
                .biomeButton(.tertiary)
        }
        .biomeCard()
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color
    
    init(_ name: String, color: Color) {
        self.name = name
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: Layout.xxs) {
            RoundedRectangle(cornerRadius: Layout.radiusXS)
                .fill(color)
                .frame(height: 60)
            Text(name)
                .font(Typography.caption1)
        }
    }
}

#Preview {
    ComponentShowcase()
}
