//
//  Alert.swift
//  TicTacToe
//
//  Created by Vorapon Sirimahatham on 11/5/21.
//

import SwiftUI

struct AlertItem : Identifiable {
    let id = UUID()
    var title : Text
    var message : Text
    var buttonTitle : Text
}

struct AleartContext {
    static let humanWin = AlertItem(   title: Text("You win!"),
                                message: Text("You are so Smart"),
                                buttonTitle: Text("Hello World") )
    static let computerWin = AlertItem(title: Text("You loss!"),
                                message: Text("You are so stupid"),
                                buttonTitle: Text("Hello World") )
    static let draw = AlertItem(title: Text("Draw"),
                         message: Text("It just DRAW"),
                         buttonTitle: Text("Hello World") )
}
