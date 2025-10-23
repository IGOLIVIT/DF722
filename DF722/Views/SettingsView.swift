//
//  SettingsView.swift
//  VaultRise
//
//  Created by Cursor AI
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingStatistics = false
    @State private var showingResetAlert = false
    @State private var animateAppear = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.primaryBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.accentGold)
                            .scaleEffect(animateAppear ? 1 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateAppear)
                        
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(animateAppear ? 1 : 0)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Settings Cards
                    VStack(spacing: 16) {
                        // Statistics Card
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            showingStatistics = true
                        }) {
                            SettingsCard(
                                icon: "chart.bar.fill",
                                title: "View Statistics",
                                subtitle: "See your savings progress",
                                iconColor: AppTheme.accentGold
                            )
                        }
                        .opacity(animateAppear ? 1 : 0)
                        .offset(y: animateAppear ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateAppear)
                        
                        // Reset Progress Card
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            showingResetAlert = true
                        }) {
                            SettingsCard(
                                icon: "arrow.counterclockwise.circle.fill",
                                title: "Reset Progress",
                                subtitle: "Clear all goals and data",
                                iconColor: AppTheme.accentRuby
                            )
                        }
                        .opacity(animateAppear ? 1 : 0)
                        .offset(y: animateAppear ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateAppear)
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingStatistics) {
            StatisticsView()
        }
        .alert("Reset All Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            Button("Reset", role: .destructive) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                dataManager.resetAllData()
            }
        } message: {
            Text("Are you sure? All data will be erased. This action cannot be undone.")
        }
        .onAppear {
            withAnimation {
                animateAppear = true
            }
        }
    }
}

// MARK: - Settings Card
struct SettingsCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(20)
        .background(AppTheme.cardGradient)
        .cornerRadius(20)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
    }
}

// MARK: - Statistics View
struct StatisticsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var animateAppear = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(AppTheme.accentGold)
                                .scaleEffect(animateAppear ? 1 : 0.5)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateAppear)
                            
                            Text("Your Statistics")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(animateAppear ? 1 : 0)
                            
                            Text("Track your financial journey")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .opacity(animateAppear ? 1 : 0)
                        }
                        .padding(.top, 20)
                        
                        // Stats Grid
                        VStack(spacing: 16) {
                            StatCard(
                                icon: "dollarsign.circle.fill",
                                title: "Total Saved",
                                value: formatCurrency(dataManager.totalSaved),
                                gradient: AppTheme.goldGradient,
                                delay: 0.1
                            )
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateAppear)
                            
                            HStack(spacing: 16) {
                                StatCard(
                                    icon: "flag.circle.fill",
                                    title: "Active Goals",
                                    value: "\(dataManager.activeGoalsCount)",
                                    gradient: AppTheme.rubyGradient,
                                    delay: 0.2,
                                    compact: true
                                )
                                .opacity(animateAppear ? 1 : 0)
                                .offset(y: animateAppear ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateAppear)
                                
                                StatCard(
                                    icon: "checkmark.circle.fill",
                                    title: "Completed",
                                    value: "\(dataManager.completedGoalsCount)",
                                    gradient: AppTheme.goldGradient,
                                    delay: 0.3,
                                    compact: true
                                )
                                .opacity(animateAppear ? 1 : 0)
                                .offset(y: animateAppear ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateAppear)
                            }
                            
                            StatCard(
                                icon: "speedometer",
                                title: "Daily Avg Savings",
                                value: formatCurrency(dataManager.averageSavingSpeed),
                                gradient: AppTheme.rubyGradient,
                                delay: 0.4
                            )
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateAppear)
                            
                            // Motivational message
                            if dataManager.completedGoalsCount > 0 {
                                MotivationalCard()
                                    .opacity(animateAppear ? 1 : 0)
                                    .offset(y: animateAppear ? 0 : 20)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: animateAppear)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .accentColor(AppTheme.accentGold)
        .onAppear {
            withAnimation {
                animateAppear = true
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let gradient: LinearGradient
    let delay: Double
    var compact: Bool = false
    @State private var animateValue = false
    
    var body: some View {
        VStack(spacing: compact ? 12 : 16) {
            Image(systemName: icon)
                .font(.system(size: compact ? 32 : 40))
                .foregroundColor(.white)
                .scaleEffect(animateValue ? 1 : 0.8)
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: compact ? 13 : 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.system(size: compact ? 24 : 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, compact ? 24 : 32)
        .background(gradient.opacity(0.3))
        .background(AppTheme.cardGradient)
        .cornerRadius(20)
        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay + 0.2)) {
                animateValue = true
            }
        }
    }
}

// MARK: - Motivational Card
struct MotivationalCard: View {
    @State private var animate = false
    
    let messages = [
        "You're building your future!",
        "Consistency is the key!",
        "Every step counts!",
        "Amazing discipline!",
        "Keep up the great work!"
    ]
    
    var randomMessage: String {
        messages.randomElement() ?? messages[0]
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGold.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .blur(radius: 10)
                    .scaleEffect(animate ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.accentGold)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Keep Going!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(randomMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppTheme.accentGold.opacity(0.2), AppTheme.accentRuby.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(AppTheme.cardGradient)
        .cornerRadius(20)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
        .onAppear {
            animate = true
        }
    }
}


