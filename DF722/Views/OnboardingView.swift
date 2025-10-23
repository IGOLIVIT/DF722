//
//  OnboardingView.swift
//  VaultRise
//
//  Created by Cursor AI
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        ZStack {
            AppTheme.primaryBackground.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage1()
                    .tag(0)
                
                OnboardingPage2()
                    .tag(1)
                
                OnboardingPage3(isOnboardingComplete: $isOnboardingComplete)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

// MARK: - Page 1
struct OnboardingPage1: View {
    @State private var animateCoins = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                // Animated background glow
                Circle()
                    .fill(AppTheme.accentGold.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .scaleEffect(animateCoins ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateCoins)
                
                // Floating coins animation
                VStack(spacing: -20) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(AppTheme.goldGradient)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.accentGold.opacity(0.5), lineWidth: 2)
                            )
                            .shadow(color: AppTheme.accentGold.opacity(0.5), radius: 10)
                            .offset(y: animateCoins ? -CGFloat(index * 20) : CGFloat(index * 20))
                            .animation(.easeInOut(duration: 1.5).delay(Double(index) * 0.2).repeatForever(autoreverses: true), value: animateCoins)
                    }
                }
            }
            .frame(height: 280)
            
            VStack(spacing: 20) {
                Text("Welcome to Your Financial Journey")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
                
                Text("Transform your dreams into achievable savings goals with elegant tracking and motivating visualizations")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateText = true
            }
            animateCoins = true
        }
    }
}

// MARK: - Page 2
struct OnboardingPage2: View {
    @State private var animateChart = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                // Animated progress visualization
                Circle()
                    .fill(AppTheme.rubyGradient.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .scaleEffect(animateChart ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateChart)
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 20)
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .trim(from: 0, to: animateChart ? 0.75 : 0)
                        .stroke(AppTheme.rubyGradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5), value: animateChart)
                    
                    VStack(spacing: 5) {
                        Text(animateChart ? "75%" : "0%")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.accentGold)
                        Text("Progress")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .frame(height: 280)
            
            VStack(spacing: 20) {
                Text("Track Every Step")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
                
                Text("Watch your progress grow with beautiful visual indicators and celebrate each milestone along the way")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateText = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                animateChart = true
            }
        }
    }
}

// MARK: - Page 3
struct OnboardingPage3: View {
    @Binding var isOnboardingComplete: Bool
    @State private var animateBadge = false
    @State private var animateText = false
    @State private var animateButton = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                // Animated glow
                Circle()
                    .fill(AppTheme.accentGold.opacity(0.3))
                    .frame(width: 220, height: 220)
                    .blur(radius: 50)
                    .scaleEffect(animateBadge ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateBadge)
                
                // Victory badge
                ZStack {
                    Circle()
                        .fill(AppTheme.goldGradient)
                        .frame(width: 140, height: 140)
                        .shadow(color: AppTheme.accentGold.opacity(0.6), radius: 20)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primaryBackground)
                }
                .scaleEffect(animateBadge ? 1.0 : 0.5)
                .rotationEffect(.degrees(animateBadge ? 0 : -180))
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: animateBadge)
            }
            .frame(height: 280)
            
            VStack(spacing: 20) {
                Text("Achieve Your Dreams")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
                
                Text("Every goal completed brings you closer to financial freedom. Start your journey today")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
            }
            
            Spacer()
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                DataManager.shared.completeOnboarding()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isOnboardingComplete = true
                }
            }) {
                Text("Start Planning")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.primaryBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.goldGradient)
                    .cornerRadius(16)
                    .shadow(color: AppTheme.accentGold.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .padding(.horizontal, 40)
            .scaleEffect(animateButton ? 1.0 : 0.8)
            .opacity(animateButton ? 1 : 0)
            .padding(.bottom, 40)
        }
        .padding()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateText = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                animateButton = true
            }
            animateBadge = true
        }
    }
}


