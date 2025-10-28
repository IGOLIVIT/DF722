//
//  MiniGameView.swift
//  DF722
//
//  Created by IGOR on 28/10/2025.
//

import SwiftUI
import Combine

struct MiniGameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.05, green: 0.05, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    HStack(spacing: 12) {
                        // Level
                        GameStatCard(icon: "🏃", value: "\(gameManager.level)", label: "Level")
                        
                        // Score
                        GameStatCard(icon: "⭐", value: "\(gameManager.score)", label: "Score")
                        
                        // Bonus
                        GameStatCard(icon: "💰", value: "$\(gameManager.bonus)", label: "Bonus")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Game Area
                    ZStack {
                        // Game items (obstacles and collectibles)
                        ForEach(gameManager.gameItems) { item in
                            Text(item.emoji)
                                .font(.system(size: item.size))
                                .position(
                                    x: geometry.size.width * item.position.x,
                                    y: geometry.size.height * item.position.y
                                )
                                .opacity(item.isActive ? 1 : 0)
                        }
                        
                        // Player
                        Text("🏃")
                            .font(.system(size: 50))
                            .scaleEffect(x: gameManager.playerDirection == .right ? 1 : -1, y: 1)
                            .position(
                                x: geometry.size.width * gameManager.playerPosition,
                                y: geometry.size.height * 0.62
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 80) {
                        // Left button
                        Button(action: {
                            gameManager.movePlayer(direction: .left)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentGold)
                                    .frame(width: 56, height: 56)
                                    .shadow(color: AppTheme.accentGold.opacity(0.5), radius: 10)
                                
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                            }
                        }
                        .buttonStyle(GameButtonStyle())
                        
                        // Right button
                        Button(action: {
                            gameManager.movePlayer(direction: .right)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentGold)
                                    .frame(width: 56, height: 56)
                                    .shadow(color: AppTheme.accentGold.opacity(0.5), radius: 10)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                            }
                        }
                        .buttonStyle(GameButtonStyle())
                    }
                    .padding(.bottom, 30)
                }
                
                // Game Over overlay
                if gameManager.isGameOver {
                    GameOverView(
                        score: gameManager.score,
                        bonus: gameManager.bonus,
                        onRestart: {
                            gameManager.resetGame()
                        },
                        onExit: {
                            dismiss()
                        }
                    )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Goal Climber")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accentGold)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            gameManager.startGame()
        }
        .onDisappear {
            gameManager.stopGame()
        }
    }
}

// MARK: - Game Stat Card
struct GameStatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 20))
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Game Button Style
struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Game Over View
struct GameOverView: View {
    let score: Int
    let bonus: Int
    let onRestart: () -> Void
    let onExit: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("🏆")
                        .font(.system(size: 80))
                        .scaleEffect(animate ? 1 : 0.5)
                        .rotationEffect(.degrees(animate ? 0 : -180))
                    
                    Text("Game Over!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Score:")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(score)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.accentGold)
                        }
                        
                        HStack {
                            Text("Bonus:")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("$\(bonus)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.accentGold)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .opacity(animate ? 1 : 0)
                
                VStack(spacing: 16) {
                    Button(action: onRestart) {
                        Text("Play Again")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppTheme.goldGradient)
                            .cornerRadius(16)
                    }
                    
                    Button(action: onExit) {
                        Text("Exit")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
                .opacity(animate ? 1 : 0)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

// MARK: - Game Manager
class GameManager: ObservableObject {
    @Published var playerPosition: CGFloat = 0.5
    @Published var playerDirection: Direction = .right
    @Published var gameItems: [GameObject] = []
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var bonus: Int = 0
    @Published var isGameOver: Bool = false
    
    private var gameTimer: Timer?
    private var itemSpawnTimer: Timer?
    private var difficultyTimer: Timer?
    private var gameSpeed: TimeInterval = 0.03
    private var spawnRate: TimeInterval = 1.5
    
    enum Direction {
        case left, right
    }
    
    func startGame() {
        resetGame()
        
        // Main game loop
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameSpeed, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
        
        // Item spawning
        itemSpawnTimer = Timer.scheduledTimer(withTimeInterval: spawnRate, repeats: true) { [weak self] _ in
            self?.spawnItem()
        }
        
        // Difficulty increase
        difficultyTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.increaseDifficulty()
        }
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        itemSpawnTimer?.invalidate()
        difficultyTimer?.invalidate()
        gameTimer = nil
        itemSpawnTimer = nil
        difficultyTimer = nil
    }
    
    func resetGame() {
        playerPosition = 0.5
        playerDirection = .right
        gameItems = []
        score = 0
        level = 1
        bonus = 0
        isGameOver = false
        gameSpeed = 0.03
        spawnRate = 1.5
        
        stopGame()
    }
    
    func movePlayer(direction: Direction) {
        let step: CGFloat = 0.15
        playerDirection = direction
        
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()
        
        withAnimation(.easeOut(duration: 0.2)) {
            if direction == .left {
                playerPosition = max(0.15, playerPosition - step)
            } else {
                playerPosition = min(0.85, playerPosition + step)
            }
        }
    }
    
    private func updateGame() {
        // Move items down
        for index in gameItems.indices {
            gameItems[index].position.y += 0.015
        }
        
        // Check collisions
        checkCollisions()
        
        // Remove off-screen items
        gameItems.removeAll { $0.position.y > 1.1 }
    }
    
    private func spawnItem() {
        let randomX = CGFloat.random(in: 0.15...0.85)
        let itemType = GameItemType.random()
        
        let newItem = GameObject(
            emoji: itemType.emoji,
            position: CGPoint(x: randomX, y: -0.1),
            type: itemType,
            size: itemType.size
        )
        
        gameItems.append(newItem)
    }
    
    private func checkCollisions() {
        let playerRect = CGRect(x: playerPosition - 0.04, y: 0.58, width: 0.08, height: 0.08)
        
        for index in gameItems.indices where gameItems[index].isActive {
            let item = gameItems[index]
            let itemRect = CGRect(x: item.position.x - 0.05, y: item.position.y - 0.05, width: 0.1, height: 0.1)
            
            if playerRect.intersects(itemRect) {
                gameItems[index].isActive = false
                handleCollision(with: item.type)
            }
        }
    }
    
    private func handleCollision(with type: GameItemType) {
        let haptic = UINotificationFeedbackGenerator()
        
        switch type {
        case .diamond:
            score += 50
            haptic.notificationOccurred(.success)
        case .moneyBag:
            bonus += 10
            score += 30
            haptic.notificationOccurred(.success)
        case .rock:
            // Game over
            haptic.notificationOccurred(.error)
            endGame()
        }
    }
    
    private func increaseDifficulty() {
        level += 1
        gameSpeed = max(0.015, gameSpeed - 0.003)
        spawnRate = max(0.8, spawnRate - 0.1)
        
        // Restart timers with new rates
        stopGame()
        startGame()
    }
    
    private func endGame() {
        stopGame()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                self.isGameOver = true
            }
        }
    }
}

// MARK: - Game Objects
struct GameObject: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
    let type: GameItemType
    let size: CGFloat
    var isActive = true
}

enum GameItemType {
    case diamond
    case moneyBag
    case rock
    
    var emoji: String {
        switch self {
        case .diamond: return "💎"
        case .moneyBag: return "💰"
        case .rock: return "🪨"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .diamond: return 40
        case .moneyBag: return 45
        case .rock: return 50
        }
    }
    
    static func random() -> GameItemType {
        let random = Int.random(in: 0...100)
        if random < 35 {
            return .diamond
        } else if random < 60 {
            return .moneyBag
        } else {
            return .rock
        }
    }
}

#Preview {
    NavigationView {
        MiniGameView()
    }
}
