//
//  GameViewModel.swift
//  TicTacToe
//
//  Created by Vorapon Sirimahatham on 13/5/21.
//

import Foundation
import SwiftUI
import Combine

enum Level : String{
    case noob = "noob"
    case odinary = "odinay"
    case insane = "insane"
}

enum Theme {
    case color1,color2,color3
}

final class GameViewModel : ObservableObject {
    
    @Published var moves : [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameboardDisabled = false
    @Published var alertItem : AlertItem?
    @Published var isHumanTurn = true
    
    // Add on
    @Published var levelOfAI : Level = .odinary
    @Published var selectedTheme : String = ""
    
    
    @Published var gameConfig : GameConfiguration
    private var autosaveCancellable : AnyCancellable?

    let keyForUD = "game-config"
    
    init() {
        gameConfig = GameConfiguration(json: UserDefaults.standard.data(forKey: keyForUD )) ?? GameConfiguration()
        
        autosaveCancellable = $gameConfig.sink {  config in
            print("Ajson = \(config.json?.utf8 ?? "nill")")
            UserDefaults.standard.set( config.json, forKey: self.keyForUD)
        }
    }
    
    func isSquareOccupied( in moves: [Move?],forIndex index: Int) -> Bool{
        return moves.contains(where: {$0?.boardIndex == index })
    }
    
    // If AI can win , then win
    // If AI can't win, then block
    // If AI can't block, then take middle square
    // If AI can't take middle square, take random available square
    
    func determineComputerMovePosition( in moves : [Move?] ) -> Int {
        let winPatterns : Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
     
        // If AI can win , then win
        let computerMoves = moves.compactMap{$0}.filter{ $0.player == .computer}
        let computerPosition = Set(computerMoves.map { $0.boardIndex } )
        
        for pattren in winPatterns {
            let winPosition = pattren.subtracting(computerPosition)
            if winPosition.count == 1 {
                let isAvaiable = !isSquareOccupied(in: moves, forIndex: winPosition.first!)
                if isAvaiable { return winPosition.first! }
            }
        }
        // If AI can't win, then block
        let humanMoves = moves.compactMap{$0}.filter{ $0.player == .human}
        let humanPosition = Set(humanMoves.map { $0.boardIndex } )
        
        for pattren in winPatterns {
            let winPosition = pattren.subtracting(humanPosition)
            if winPosition.count == 1 {
                let isAvaiable = !isSquareOccupied(in: moves, forIndex: winPosition.first!)
                if isAvaiable { return winPosition.first! }
            }
        }
        
        //- - - If AI can't block, then take middle square - - -
        let centerSquare = 4
        if isSquareOccupied(in: moves, forIndex: centerSquare){
            return centerSquare
        }
    
        // If AI can't take middle square, take random available square
        var movePosition = Int.random(in : 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random( in : 0..<9 )
        }
        print("AI random position is \(movePosition)")
        return movePosition // only return 0 - 8 testing
    }
    
    func vDetermineComputerMovePosition( in moves : [Move?] ) -> Int {
        let winPatterns : Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        let playerMoves = moves.compactMap{ $0 }.filter { $0.player == .human }
        let playerPosition = Set(playerMoves.map { $0.boardIndex } )
    
        let aiMoves = moves.compactMap{ $0 }.filter { $0.player == .computer }
        let aiPosition = Set(aiMoves.map { $0.boardIndex } )
        
        var movePosition : Int = 0
        // - - - If AI can win , then win - - -
            // select win pattern
            // เลือกอันที่ human ยังไม่ได้กด  Set<Int> -> Set<Set<Int>>
            // เลือกอันที่ computer กดไปแล้ว -> Set<Set<Int>>
            // random ค่าที่เหลือใน [ ] -> Int
        var possiblePatterns = winPatterns.filter{ $0.isDisjoint(with: playerPosition) }
            // เลือกอันที่ computer กดไปแล้ว -> Set<Set<Int>>
        possiblePatterns = possiblePatterns.filter{ !$0.isDisjoint(with: aiPosition)}
//        print("AI Choices")
//        print(possiblePatterns)
        // random ค่าที่เหลือใน [ ] -> Int
            // เลือกตัวเลขที่ยังไม่กด Set<Set<Int>> -> Int
            // เอา Set แรก Set<Set<Int>> -> Set<Int>
            // เอาตัวแรก Set<Int> -> Int
        if( !possiblePatterns.isEmpty )
        {
            let selectedPattern = possiblePatterns.first
            let selectedPosition = selectedPattern!.subtracting(aiPosition)
            print( "AI selects = \(getFirst(of : selectedPosition))")
            return getFirst(of : selectedPosition)
        }
    
        // - - - If AI can't win, then block - - -
            // what is block?
            // check player posible win pattern
        // check player posible win pattern
        var possiblePatterns2 = winPatterns.filter{ !$0.isDisjoint(with: playerPosition) }
        print(possiblePatterns2)
        // check and remove pattern already blocked
        possiblePatterns2 = possiblePatterns2.filter( {$0.isDisjoint(with: aiPosition)} )
        print(possiblePatterns2)
        // filter high priority pattern (human taked two position)
        let highPriorityPattern = possiblePatterns2.filter{
            var count = 0
            for i in $0 {
                if playerPosition.contains(i)
                { count += 1  }
            }
            if count > 1 { return true }
            else { return false }
        }
        print(highPriorityPattern)
        //print(possiblePatterns2.first!.first!)
        if( highPriorityPattern.count > 0)
        {
            let pattern = highPriorityPattern.first ?? [0,0,0]
            for position in pattern {
                if !playerPosition.contains( position ) {
                    print("AI blocked2 = \(position)")
                    return position
                }
            }
        }
        else{
            let pattern = possiblePatterns2.first ?? [0,0,0]
            for position in pattern {
                if !playerPosition.contains(position){
                    print("AI blocked = \(position)")
                    return position
                }
            }
        }
        // if position = 1 select first
        
        
        //- - - If AI can't block, then take middle square - - -
            // select square
    
        // If AI can't take middle square, take random available square
        movePosition = Int.random(in : 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random( in : 0..<9 )
        }
        print("AI random position is \(movePosition)")
        return movePosition // only return 0 - 8 testing?
    }
    
    func getFirst(of : Set<Int> ) -> Int
    {
        for a in of
        { return a }
        return 0
    }
    
    func checkWinCondition( for player : Player, in moves : [Move?]) -> Bool {
        let winPatterns : Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        // Moves : Move -> playerMove : Move -> position : [Int]
        
        let playerMoves = moves.compactMap{ $0 }.filter { $0.player == player } // remove nil
//        print(playerMoves)
        let playerPosition = Set(playerMoves.map { $0.boardIndex } )
//        print("playerPosition")
        for pattern in winPatterns where pattern.isSubset(of: playerPosition) {
            return true
        }
       
        return false
    }
    
    func checkForDraw(in moves : [Move?]) -> Bool {
        // check if 9 moved that is draw
        return moves.compactMap{ $0 }.count == 9
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
    }
    
    func processPlayerMove( position : Int ) {
        if isSquareOccupied(in: moves, forIndex: position )
        { return }
        moves[position] = Move(player: isHumanTurn ? .human : .computer, boardIndex: position)
        isGameboardDisabled = true
        
        if checkWinCondition(for: .human, in: moves) {
            print( "Human Wins" )
            gameConfig.winScore += 1
            alertItem = AleartContext.humanWin
            return
        }
        
        if checkForDraw(in: moves ) {
            print(" DRAW ")
            gameConfig.drawScore += 1
            alertItem = AleartContext.draw
            return
        }
        
        // check for win condition or draw
        // delay 0.5 sec
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) { [self] in
//            let computerPosition = determineComputerMovePosition(in: moves)
            
            // Select computer position refer to Level of AI here
            var computerPosition : Int
            if( levelOfAI == .insane)
            {   computerPosition = determineComputerMovePosition(in: moves) }
            else { computerPosition = vDetermineComputerMovePosition(in: moves)}
            
            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
            isGameboardDisabled = false
            
            if checkWinCondition(for: .computer, in: moves) {
                print("Computer Win!!!")
                gameConfig.lossScore += 1
                alertItem = AleartContext.computerWin
                return
            }
        }
    }
}
