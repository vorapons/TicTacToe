//
//  GameModel.swift
//  TicTacToe
//
//  Created by Vorapon Sirimahatham on 24/5/21.
//

import Foundation

enum Player {
    case human, computer
}

struct Move{
    let player: Player
    let boardIndex : Int
    
    var indicator : String {
        return player == .human ? "xmark" : "circle"
    }
}

struct GameConfiguration :  Codable  {
    
//    var id : UUID
    var winScore : Int = 0
    var lossScore : Int = 0
    var drawScore : Int = 0
    var levelOfAI : String = "noob"
    var selectedTheme : String = "blue"
    
    var json : Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?( json : Data? ) {
        if json != nil , let newGameConfig = try? JSONDecoder().decode(GameConfiguration.self, from: json!) {
            self = newGameConfig
        } else {
            self = GameConfiguration()
        }
    }
    init() {

    }
    
}

extension Data {
    // just a simple converter from a Data to a String
    var utf8 : String? { String(data: self, encoding: .utf8 ) }
}
