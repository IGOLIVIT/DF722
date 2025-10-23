//
//  DataManager.swift
//  VaultRise
//
//  Created by Cursor AI
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var goals: [SavingsGoal] = []
    @Published var hasCompletedOnboarding: Bool = false
    
    private let goalsKey = "vaultrise_goals"
    private let onboardingKey = "vaultrise_onboarding_completed"
    
    init() {
        loadData()
    }
    
    // MARK: - Persistence
    
    func loadData() {
        // Load onboarding status
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        
        // Load goals
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([SavingsGoal].self, from: data) {
            goals = decoded
        }
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    // MARK: - Goal Management
    
    func addGoal(_ goal: SavingsGoal) {
        goals.append(goal)
        saveData()
    }
    
    func updateGoal(_ goal: SavingsGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveData()
        }
    }
    
    func deleteGoal(_ goal: SavingsGoal) {
        goals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    func addTransaction(to goalId: UUID, transaction: Transaction) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].addTransaction(transaction)
            saveData()
        }
    }
    
    func resetAllData() {
        goals = []
        saveData()
    }
    
    // MARK: - Statistics
    
    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }
    
    var completedGoalsCount: Int {
        goals.filter { $0.isCompleted }.count
    }
    
    var activeGoalsCount: Int {
        goals.filter { !$0.isCompleted }.count
    }
    
    var averageSavingSpeed: Double {
        guard !goals.isEmpty else { return 0 }
        let totalDays = goals.reduce(0.0) { result, goal in
            let days = Date().timeIntervalSince(goal.startDate) / 86400
            return result + max(days, 1)
        }
        return totalSaved / totalDays
    }
}


