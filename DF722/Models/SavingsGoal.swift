//
//  SavingsGoal.swift
//  VaultRise
//
//  Created by Cursor AI
//

import Foundation

struct SavingsGoal: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var startDate: Date
    var deadline: Date?
    var transactions: [Transaction]
    var isCompleted: Bool
    
    init(id: UUID = UUID(), name: String, targetAmount: Double, currentAmount: Double = 0, startDate: Date = Date(), deadline: Date? = nil) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.startDate = startDate
        self.deadline = deadline
        self.transactions = []
        self.isCompleted = false
    }
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    mutating func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        currentAmount += transaction.amount
        if currentAmount >= targetAmount && !isCompleted {
            isCompleted = true
        }
    }
}

struct Transaction: Identifiable, Codable, Equatable {
    var id: UUID
    var amount: Double
    var date: Date
    var type: TransactionType
    var note: String?
    
    init(id: UUID = UUID(), amount: Double, date: Date = Date(), type: TransactionType, note: String? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.type = type
        self.note = note
    }
}

enum TransactionType: String, Codable {
    case deposit = "deposit"
    case withdrawal = "withdrawal"
}


