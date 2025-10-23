//
//  AddGoalView.swift
//  VaultRise
//
//  Created by Cursor AI
//

import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    
    @State private var goalName = ""
    @State private var targetAmount = ""
    @State private var startAmount = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var showingCelebration = false
    @State private var animateAppear = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.accentGold)
                                .scaleEffect(animateAppear ? 1 : 0.5)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateAppear)
                            
                            Text("Create New Goal")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(animateAppear ? 1 : 0)
                            
                            Text("Define your savings target and watch it grow")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .opacity(animateAppear ? 1 : 0)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Goal Name
                            FormField(
                                title: "Goal Name",
                                icon: "flag.fill",
                                placeholder: "e.g., New Car, Vacation...",
                                text: $goalName
                            )
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateAppear)
                            
                            // Target Amount
                            FormField(
                                title: "Target Amount",
                                icon: "dollarsign.circle.fill",
                                placeholder: "0",
                                text: $targetAmount,
                                keyboardType: .decimalPad
                            )
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateAppear)
                            
                            // Start Amount (Optional)
                            FormField(
                                title: "Starting Amount (Optional)",
                                icon: "banknote.fill",
                                placeholder: "0",
                                text: $startAmount,
                                keyboardType: .decimalPad
                            )
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateAppear)
                            
                            // Deadline Toggle
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $hasDeadline) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "calendar.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppTheme.accentRuby)
                                        Text("Set Deadline")
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: AppTheme.accentGold))
                                
                                if hasDeadline {
                                    DatePicker("Target Date", selection: $deadline, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .accentColor(AppTheme.accentGold)
                                        .foregroundColor(.white)
                                        .padding(.leading, 36)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding(20)
                            .background(AppTheme.cardGradient)
                            .cornerRadius(16)
                            .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
                            .opacity(animateAppear ? 1 : 0)
                            .offset(y: animateAppear ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: animateAppear)
                        }
                        
                        // Create Button
                        Button(action: createGoal) {
                            Text("Create Goal")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.primaryBackground)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(isFormValid ? AppTheme.goldGradient : LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(16)
                                .shadow(color: isFormValid ? AppTheme.accentGold.opacity(0.4) : Color.clear, radius: 15, x: 0, y: 8)
                        }
                        .disabled(!isFormValid)
                        .opacity(animateAppear ? 1 : 0)
                        .offset(y: animateAppear ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: animateAppear)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                
                // Celebration Overlay
                if showingCelebration {
                    CelebrationView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
    
    var isFormValid: Bool {
        !goalName.isEmpty && Double(targetAmount) ?? 0 > 0
    }
    
    func createGoal() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let target = Double(targetAmount) ?? 0
        let start = Double(startAmount) ?? 0
        
        let newGoal = SavingsGoal(
            name: goalName,
            targetAmount: target,
            currentAmount: start,
            deadline: hasDeadline ? deadline : nil
        )
        
        dataManager.addGoal(newGoal)
        
        // Show celebration
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingCelebration = true
        }
        
        // Dismiss after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let successGenerator = UINotificationFeedbackGenerator()
            successGenerator.notificationOccurred(.success)
            
            dismiss()
        }
    }
}

// MARK: - Form Field
struct FormField: View {
    let title: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.accentRuby)
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(16)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .keyboardType(keyboardType)
        }
        .padding(20)
        .background(AppTheme.cardGradient)
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppTheme.primaryBackground.opacity(0.95).ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentGold.opacity(0.3))
                        .frame(width: 180, height: 180)
                        .blur(radius: 40)
                        .scaleEffect(animate ? 1.5 : 1.0)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(AppTheme.accentGold)
                        .scaleEffect(animate ? 1.0 : 0.5)
                        .rotationEffect(.degrees(animate ? 0 : -180))
                }
                
                VStack(spacing: 12) {
                    Text("Goal Created!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Another step toward freedom")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}


