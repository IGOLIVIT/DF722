//
//  MainView.swift
//  VaultRise
//
//  Created by Cursor AI
//

import SwiftUI

struct MainView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingAddGoal = false
    @State private var animateAppear = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with total balance
                        TotalBalanceCard()
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                        
                        // Goals section
                        if dataManager.goals.isEmpty {
                            EmptyStateView()
                                .padding(.top, 60)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(Array(dataManager.goals.enumerated()), id: \.element.id) { index, goal in
                                    NavigationLink(destination: GoalDetailView(goal: goal)) {
                                        GoalCard(goal: goal)
                                            .opacity(animateAppear ? 1 : 0)
                                            .offset(y: animateAppear ? 0 : 20)
                                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateAppear)
                                    }
                                    .buttonStyle(CardButtonStyle())
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteGoal(goal)
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showingAddGoal = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(AppTheme.primaryBackground)
                                .frame(width: 64, height: 64)
                                .background(AppTheme.goldGradient)
                                .clipShape(Circle())
                                .shadow(color: AppTheme.accentGold.opacity(0.5), radius: 15, x: 0, y: 8)
                        }
                        .scaleEffect(animateAppear ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: animateAppear)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                        Text("VaultRise")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.accentGold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        NavigationLink(destination: MiniGameView()) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.accentGold)
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.accentGold)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(AppTheme.accentGold)
        .onAppear {
            withAnimation {
                animateAppear = true
            }
        }
    }
    
    func deleteGoal(_ goal: SavingsGoal) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            dataManager.deleteGoal(goal)
        }
    }
}

// MARK: - Total Balance Card
struct TotalBalanceCard: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var animateGlow = false
    
    var body: some View {
        ZStack {
            // Animated glow background
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.accentGold.opacity(0.15))
                .blur(radius: 20)
                .scaleEffect(animateGlow ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGlow)
            
            VStack(spacing: 16) {
                Text("Total Saved")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(formatCurrency(dataManager.totalSaved))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accentGold)
                
                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("\(dataManager.activeGoalsCount)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Active")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 1, height: 40)
                    
                    VStack(spacing: 4) {
                        Text("\(dataManager.completedGoalsCount)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Completed")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(AppTheme.cardGradient)
            .cornerRadius(24)
            .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
        }
        .onAppear {
            animateGlow = true
        }
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: SavingsGoal
    @State private var animateProgress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("\(formatCurrency(goal.currentAmount)) of \(formatCurrency(goal.targetAmount))")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 6)
                        .frame(width: 64, height: 64)
                    
                    Circle()
                        .trim(from: 0, to: animateProgress ? goal.progress : 0)
                        .stroke(AppTheme.rubyGradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: animateProgress)
                    
                    Text("\(goal.progressPercentage)%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.accentGold)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.rubyGradient)
                        .frame(width: geometry.size.width * (animateProgress ? goal.progress : 0), height: 8)
                        .animation(.easeInOut(duration: 1), value: animateProgress)
                }
            }
            .frame(height: 8)
            
            // Deadline if exists
            if let deadline = goal.deadline {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text("Target: \(formatDate(deadline))")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardGradient)
        .cornerRadius(20)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
        .onAppear {
            animateProgress = true
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGold.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .scaleEffect(animate ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                
                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.accentGold)
            }
            
            VStack(spacing: 12) {
                Text("Start Your Journey")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Create your first savings goal and\nwatch your dreams come to life")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Card Button Style
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Helper Functions
func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: amount)) ?? "$0"
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}

