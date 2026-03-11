import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var isNightMode = true
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 0) {
                KaizenHeader(isHome: false, onBack: { dismiss() })
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) {
                        // Title Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("1% BETTER EVERY DAY")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.kaizenGray.opacity(0.6))
                                .tracking(2)
                        }
                        .padding(.top, 8)
                        
                        // Rituals Section
                        
                        // Rituals Section
                        settingsSection(title: "Rituals") {
                            SettingsRow(icon: "bell.fill", title: "Notifications", color: .kaizenSage) {
                                Toggle("", isOn: $notificationsEnabled).labelsHidden()
                            }
                        }
                        
                        // Evolution Section
                        settingsSection(title: "Evolution") {
                            SettingsRow(icon: "crown.fill", title: "Upgrade to Premium", color: .yellow) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.kaizenGray.opacity(0.4))
                            }
                        }
                        
                        // Archives Section
                        settingsSection(title: "Archives") {
                            SettingsRow(icon: "video.fill", title: "Saved Videos", color: .kaizenGray) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.kaizenGray.opacity(0.4))
                            }
                        }
                        
                        // Danger Zone
                        VStack(alignment: .leading, spacing: 20) {
                            Text("DANGER ZONE")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.red.opacity(0.6))
                                .tracking(1)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 12) {
                                // Theme Toggle
                                Button(action: {
                                    HapticManager.shared.playWorkoutStart()
                                    isNightMode.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: isNightMode ? "moon.fill" : "sun.max.fill")
                                        Text(isNightMode ? "Night Mode" : "Day Mode")
                                            .font(.system(size: 14, weight: .bold))
                                        Spacer()
                                        Circle()
                                            .fill(isNightMode ? Color.kaizenSage : Color.orange)
                                            .frame(width: 8, height: 8)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.04))
                                    .cornerRadius(16)
                                    .foregroundColor(.white)
                                }
                                
                                // Remove Data
                                Button(action: {
                                    HapticManager.shared.playWorkoutStart()
                                    // Action for removal
                                }) {
                                    Text("REMOVE ALL DATA")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        
                        // App Info
                        VStack(spacing: 8) {
                            Text("KAIZEN v1.0")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.kaizenGray.opacity(0.4))
                                .tracking(3)
                            
                            Text("The path of self-improvement is infinite.")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.kaizenGray.opacity(0.3))
                                .italic()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackFix())
        .onSwipeBack {
            HapticManager.shared.playWorkoutStart()
            dismiss()
        }
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.kaizenGray)
                .tracking(1)
                .padding(.leading, 4)
            
            VStack(spacing: 1) {
                content()
            }
            .background(Color.white.opacity(0.04))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    let color: Color
    let trailing: Trailing
    
    init(icon: String, title: String, color: Color, @ViewBuilder trailing: () -> Trailing) {
        self.icon = icon
        self.title = title
        self.color = color
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
}
