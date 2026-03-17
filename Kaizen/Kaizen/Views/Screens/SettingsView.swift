import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var isNightMode = true
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.kaizenShadow, Color(red: 0.13, green: 0.15, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                KaizenHeader(isHome: false, onBack: { dismiss() })
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Tune the ritual, keep the surface quiet.")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.kaizenFog.opacity(0.7))
                        }

                        HStack(spacing: 14) {
                            statPill(title: "Notifications", value: notificationsEnabled ? "On" : "Off", tint: .kaizenMint)
                            statPill(title: "Mode", value: isNightMode ? "Night" : "Day", tint: .kaizenWood)
                        }

                        settingsSection(title: "Rituals") {
                            SettingsRow(icon: "bell.badge.fill", title: "Notifications", color: .kaizenMint) {
                                Toggle("", isOn: $notificationsEnabled).labelsHidden()
                                    .tint(.kaizenMint)
                            }
                        }

                        settingsSection(title: "Membership") {
                            SettingsRow(icon: "sparkles", title: "Upgrade to Premium", color: .yellow) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.kaizenFog.opacity(0.5))
                            }
                        }

                        settingsSection(title: "Library") {
                            SettingsRow(icon: "video.fill", title: "Saved Videos", color: .kaizenFog) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.kaizenFog.opacity(0.5))
                            }
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("ENVIRONMENT")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.kaizenFog.opacity(0.62))
                                .tracking(2)

                            Button(action: {
                                HapticManager.shared.playWorkoutStart()
                                isNightMode.toggle()
                            }) {
                                HStack(spacing: 16) {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill((isNightMode ? Color.kaizenMint : Color.orange).opacity(0.16))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Image(systemName: isNightMode ? "moon.stars.fill" : "sun.max.fill")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(isNightMode ? .kaizenMint : .orange)
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(isNightMode ? "Night Mode" : "Day Mode")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)

                                        Text("Visual atmosphere only")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.kaizenFog.opacity(0.62))
                                    }

                                    Spacer()

                                    Text(isNightMode ? "Dark" : "Light")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.kaizenCloud)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .kaizenFloatingCapsule(tint: .white.opacity(0.06))
                                }
                                .padding(18)
                            }
                            .buttonStyle(.plain)
                            .kaizenGlassCard(cornerRadius: 26, tint: Color.kaizenMint.opacity(0.06))
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            Text("DANGER ZONE")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.kaizenEmber.opacity(0.8))
                                .tracking(2)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 12) {
                                Button(action: {
                                    HapticManager.shared.playWorkoutStart()
                                }) {
                                    Text("REMOVE ALL DATA")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(.kaizenEmber)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.kaizenEmber.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .stroke(Color.kaizenEmber.opacity(0.24), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text("KAIZEN v1.0")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.kaizenFog.opacity(0.4))
                                .tracking(3)
                            
                            Text("The path of self-improvement is infinite.")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.kaizenFog.opacity(0.28))
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
                .foregroundColor(.kaizenFog.opacity(0.62))
                .tracking(2)
                .padding(.leading, 4)
            
            VStack(spacing: 1) {
                content()
            }
            .padding(4)
            .kaizenGlassCard(cornerRadius: 26, tint: Color.white.opacity(0.05))
        }
    }

    private func statPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.kaizenFog.opacity(0.58))
                .tracking(2)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .kaizenGlassCard(cornerRadius: 22, tint: tint.opacity(0.06))
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
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 38, height: 38)
                
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
