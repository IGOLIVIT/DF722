//
//  GoalDetailView.swift
//  VaultRise
//
//  Created by Cursor AI
//

import SwiftUI

struct GoalDetailView: View {
    let goal: SavingsGoal
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingAddFunds = false
    @State private var showingWithdraw = false
    @State private var animateAppear = false
    @State private var showingCompletion = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) var dismiss
    
    var currentGoal: SavingsGoal {
        dataManager.goals.first(where: { $0.id == goal.id }) ?? goal
    }
    
    var body: some View {
        ZStack {
            AppTheme.primaryBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Progress Circle
                    ProgressCircle(goal: currentGoal)
                        .opacity(animateAppear ? 1 : 0)
                        .scaleEffect(animateAppear ? 1 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateAppear)
                    
                    // Goal Info Card
                    GoalInfoCard(goal: currentGoal)
                        .opacity(animateAppear ? 1 : 0)
                        .offset(y: animateAppear ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateAppear)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        ActionButton(
                            title: "Add Savings",
                            icon: "plus.circle.fill",
                            gradient: AppTheme.goldGradient,
                            action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                showingAddFunds = true
                            }
                        )
                        
                        ActionButton(
                            title: "Withdraw",
                            icon: "minus.circle.fill",
                            gradient: AppTheme.rubyGradient,
                            action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                showingWithdraw = true
                            }
                        )
                    }
                    .opacity(animateAppear ? 1 : 0)
                    .offset(y: animateAppear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateAppear)
                    
                    // Timeline/Transactions
                    if !currentGoal.transactions.isEmpty {
                        TransactionsList(transactions: currentGoal.transactions)
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateAppear)
                    } else {
                        EmptyTransactionsView()
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateAppear)
                    }
                    
                    // Delete Goal Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                            Text("Delete Goal")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.red.opacity(0.3), Color.red.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .background(AppTheme.cardGradient)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(animateAppear ? 1 : 0)
                    .padding(.top, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            
            // Completion Celebration
            if showingCompletion {
                CompletionCelebration()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(currentGoal.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingAddFunds) {
            TransactionSheet(
                goal: currentGoal,
                type: .deposit,
                onComplete: handleTransaction
            )
        }
        .sheet(isPresented: $showingWithdraw) {
            TransactionSheet(
                goal: currentGoal,
                type: .withdrawal,
                onComplete: handleTransaction
            )
        }
        .alert("Delete Goal", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            Button("Delete", role: .destructive) {
                deleteGoal()
            }
        } message: {
            Text("Are you sure you want to delete '\(currentGoal.name)'? All progress and transactions will be lost.")
        }
        .onAppear {
            withAnimation {
                animateAppear = true
            }
        }
    }
    
    func deleteGoal() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        dataManager.deleteGoal(currentGoal)
        dismiss()
    }
    
    func handleTransaction() {
        // Check if goal just completed
        if currentGoal.isCompleted && !goal.isCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showingCompletion = true
                }
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showingCompletion = false
                    }
                }
            }
        }
    }
}

// MARK: - Progress Circle
struct ProgressCircle: View {
    let goal: SavingsGoal
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(AppTheme.accentGold.opacity(0.2))
                .frame(width: 240, height: 240)
                .blur(radius: 30)
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: animateProgress ? goal.progress : 0)
                    .stroke(AppTheme.rubyGradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.2), value: animateProgress)
                
                // Center content
                VStack(spacing: 8) {
                    Text("\(goal.progressPercentage)%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.accentGold)
                    
                    Text("Complete")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 20)
        .onAppear {
            animateProgress = true
        }
    }
}

// MARK: - Goal Info Card
struct GoalInfoCard: View {
    let goal: SavingsGoal
    
    var body: some View {
        VStack(spacing: 20) {
            // Amounts
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Text(formatCurrency(goal.currentAmount))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.accentGold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Target")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Text(formatCurrency(goal.targetAmount))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Additional info
            VStack(spacing: 12) {
                InfoRow(
                    icon: "calendar",
                    label: "Started",
                    value: formatDate(goal.startDate)
                )
                
                if let deadline = goal.deadline {
                    InfoRow(
                        icon: "flag.fill",
                        label: "Target Date",
                        value: formatDate(deadline)
                    )
                }
                
                InfoRow(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Remaining",
                    value: formatCurrency(max(goal.targetAmount - goal.currentAmount, 0))
                )
            }
        }
        .padding(24)
        .background(AppTheme.cardGradient)
        .cornerRadius(20)
        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.accentRuby)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.primaryBackground)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.primaryBackground)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(gradient)
            .cornerRadius(16)
            .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Transactions List
struct TransactionsList: View {
    let transactions: [Transaction]
    
    var sortedTransactions: [Transaction] {
        transactions.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(sortedTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: transaction.type == .deposit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(transaction.type == .deposit ? AppTheme.accentGold : AppTheme.accentRuby)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.type == .deposit ? "Deposit" : "Withdrawal")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(formatDate(transaction.date))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("\(transaction.type == .deposit ? "+" : "-")\(formatCurrency(abs(transaction.amount)))")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(transaction.type == .deposit ? AppTheme.accentGold : AppTheme.accentRuby)
        }
        .padding(16)
        .background(AppTheme.cardGradient)
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Empty Transactions View
struct EmptyTransactionsView: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.accentGold.opacity(0.5))
                .scaleEffect(animate ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            
            Text("No Activity Yet")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Start by adding your first deposit")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Transaction Sheet
struct TransactionSheet: View {
    let goal: SavingsGoal
    let type: TransactionType
    let onComplete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    @State private var amount = ""
    @State private var animateAppear = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBackground.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: type == .deposit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(type == .deposit ? AppTheme.accentGold : AppTheme.accentRuby)
                        .scaleEffect(animateAppear ? 1 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateAppear)
                    
                    // Title
                    Text(type == .deposit ? "Add Savings" : "Withdraw Funds")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateAppear ? 1 : 0)
                    
                    // Amount input
                    VStack(spacing: 16) {
                        HStack {
                            Text("$")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                            
                            TextField("0", text: $amount)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(type == .deposit ? AppTheme.accentGold : AppTheme.accentRuby)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(24)
                        .background(AppTheme.cardGradient)
                        .cornerRadius(20)
                        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
                    }
                    .opacity(animateAppear ? 1 : 0)
                    .offset(y: animateAppear ? 0 : 20)
                    
                    Spacer()
                    
                    // Confirm button
                    Button(action: confirmTransaction) {
                        Text("Confirm")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.primaryBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isValid ? (type == .deposit ? AppTheme.goldGradient : AppTheme.rubyGradient) : LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(16)
                            .shadow(color: isValid ? AppTheme.cardShadow : Color.clear, radius: 15, x: 0, y: 8)
                    }
                    .disabled(!isValid)
                    .opacity(animateAppear ? 1 : 0)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
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
    
    var isValid: Bool {
        guard let value = Double(amount), value > 0 else { return false }
        if type == .withdrawal {
            return value <= goal.currentAmount
        }
        return true
    }
    
    func confirmTransaction() {
        guard let value = Double(amount) else { return }
        
        let transaction = Transaction(
            amount: type == .deposit ? value : -value,
            type: type
        )
        
        dataManager.addTransaction(to: goal.id, transaction: transaction)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        onComplete()
        dismiss()
    }
}

// MARK: - Completion Celebration
struct CompletionCelebration: View {
    @State private var animate = false
    @State private var particles: [ParticleData] = []
    
    var body: some View {
        ZStack {
            AppTheme.primaryBackground.opacity(0.95).ignoresSafeArea()
            
            // Confetti particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: 8, height: 8)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentGold.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)
                        .scaleEffect(animate ? 1.5 : 1.0)
                    
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(AppTheme.accentGold)
                        .scaleEffect(animate ? 1.0 : 0.3)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                }
                
                VStack(spacing: 12) {
                    Text("Goal Completed!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Amazing Discipline!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.accentGold)
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animate = true
            }
            createParticles()
        }
    }
    
    func createParticles() {
        for _ in 0..<30 {
            let particle = ParticleData(
                x: CGFloat.random(in: -150...150),
                y: CGFloat.random(in: -300...300),
                opacity: Double.random(in: 0.3...1.0),
                color: [AppTheme.accentGold, AppTheme.accentRuby, .white].randomElement() ?? .white
            )
            particles.append(particle)
        }
    }
}

struct ParticleData: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
    let color: Color
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

