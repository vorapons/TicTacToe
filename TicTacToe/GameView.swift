//
//  ContentView.swift
//  TicTacToe
//
//  Created by Vorapon Sirimahatham on 10/5/21.
//

import SwiftUI

struct ColorPair : Hashable{
    var main : Color
    var opt : Double
}

struct ColorSet : Hashable, Equatable{
    
    static func == (lhs: ColorSet, rhs: ColorSet) -> Bool {
        lhs.name == rhs.name
    }
    
    var name : String
    var iconBorder : ColorPair
    var iconCenter : ColorPair
    var backgrondC : ColorPair
    var circleC : ColorPair
    var markC : ColorPair
    var scoreTitleC : ColorPair
    var scoreC : ColorPair
    var buttonC : ColorPair
}

let themeBlue : ColorSet = ColorSet(  name : "blue",
                                      iconBorder : ColorPair(main: .blue, opt: 0.4),
                                      iconCenter: ColorPair(main: .white, opt: 1.0),
                                      backgrondC: ColorPair(main: .white, opt: 1.0),
                                      circleC : ColorPair(main: .blue, opt: 0.4),
                                      markC: ColorPair(main: .blue, opt: 0.4),
                                      scoreTitleC : ColorPair(main: .blue, opt: 0.4),
                                      scoreC: ColorPair(main: .blue, opt: 0.4),
                                      buttonC : ColorPair(main: .blue, opt: 0.4))

let themeRed : ColorSet = ColorSet(  name : "blackred",
                                     iconBorder : ColorPair(main: .black, opt: 1.0),
                                     iconCenter : ColorPair(main: .red, opt: 1.0),
                                     backgrondC: ColorPair(main: .black, opt: 1.0),
                                     circleC : ColorPair(main: .red, opt: 1.0),
                                     markC: ColorPair(main: .white, opt: 1.0),
                                     scoreTitleC : ColorPair(main: .red, opt: 0.9),
                                     scoreC: ColorPair(main: .red, opt: 0.9),
                                     buttonC : ColorPair(main: .red, opt: 0.9))

let themeBW : ColorSet = ColorSet(  name : "blackwhite",
                                    iconBorder : ColorPair(main: .black, opt: 1.0),
                                    iconCenter: ColorPair(main: .white, opt: 1.0),
                                    backgrondC: ColorPair(main: .white, opt: 1.0),
                                    circleC : ColorPair(main: .black, opt: 1.0),
                                    markC: ColorPair(main: .white, opt: 1.0),
                                    scoreTitleC : ColorPair(main: .black, opt: 0.9),
                                    scoreC: ColorPair(main: .black, opt: 0.9),
                                    buttonC : ColorPair(main: .black, opt: 0.9))

let columns : [GridItem] = [    GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()) ]

struct GameView: View {
        
    @StateObject private var viewModel = GameViewModel()
    @State private var isColorSetupSheetShow = false
    @State private var isAISetupSheetShow = false
    
    let themeSet : [ColorSet]
    
    init() { themeSet = [themeBlue,themeBW,themeRed] }
    
    @State var theme = themeBW
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                theme.backgrondC.main
                        .ignoresSafeArea(.all)
                VStack {
                    ScoreBoard(w: viewModel.gameConfig.winScore,
                               d: viewModel.gameConfig.drawScore,
                               l: viewModel.gameConfig.lossScore,
                               scoreColor: theme.scoreC)
                    Spacer()
                    LazyVGrid(columns : columns, spacing : 5) {
                        ForEach(0..<9, content: { i in
                            ZStack {
                                GameSquareView(proxy: geometry, color: theme.circleC.main, opt: theme.circleC.opt )
                                if let indicator = viewModel.moves[i]?.indicator
                                {    PlayerIndicator(imageName : indicator, color: theme.markC.main) }
                            }
                            .onTapGesture { viewModel.processPlayerMove(position: i) }
                        })
                    }.padding(.horizontal)
                    Spacer()
                    HStack{
                        AIMenus(viewModel: viewModel, theme: theme)
                        Spacer()
                        Button(action: { isColorSetupSheetShow = true }, label: {
                            Text("Colors")
                            Image(systemName: "pencil.circle")
                                .font(.largeTitle)
                        })
                        .foregroundColor(theme.buttonC.main).opacity(theme.buttonC.opt)
                        .padding()
                    }
                }
                if( isColorSetupSheetShow )
                {
                    BlankView(bgColor: .black)
                        .opacity(0.3)
                        .onTapGesture {
                            isColorSetupSheetShow = false
                        }
                
                    ColorChooserView(isSheetShow: $isColorSetupSheetShow , currentTheme: $theme, themeSet: themeSet, currentThemeName : $viewModel.gameConfig.selectedTheme)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .disabled(viewModel.isGameboardDisabled)
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle,action: {
                viewModel.resetGame()
                viewModel.isGameboardDisabled = false
            }))
        }
        .onAppear(perform: {
            for themeInSet in themeSet {
                if( themeInSet.name == self.viewModel.gameConfig.selectedTheme )
                {   theme = themeInSet }
            }
            viewModel.levelOfAI = Level( rawValue: viewModel.gameConfig.levelOfAI ) ?? .noob
        })
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

struct GameSquareView: View {
    var proxy : GeometryProxy
    var color : Color
    var opt : Double
    var body: some View {
        Circle()
            .foregroundColor(color)
            .opacity(opt)
            .frame(width: proxy.size.width/3-10, height: proxy.size.width/3, alignment: .center)
    }
}

struct PlayerIndicator: View {
    var imageName : String
    var color : Color
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .frame(width: 40, height: 40, alignment: .center)
            .foregroundColor(color)
    }
}

struct ColorChooserView : View {
    
    var bgColor: Color = .white
    @Binding var isSheetShow : Bool
    
    @Binding var currentTheme : ColorSet
    var themeSet : [ColorSet]
    @Binding var currentThemeName : String
    
    var body: some View {
        
        BottomSheet(isShow: $isSheetShow) {
            VStack {
                Text( "Select Color" )
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
                    .opacity(0.6)

                ScrollView{
                    LazyVGrid(columns : columns, spacing : 5) {
                        ForEach( themeSet , id : \.self ) { theme in
                            ZStack {
                                Ellipse()
                                    .fill(theme.iconCenter.main)
                                    .overlay(Ellipse()
                                    .stroke(theme.iconBorder.main, lineWidth: 12))
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .onTapGesture {
                                        currentTheme = theme
                                        currentThemeName = currentTheme.name
                                }
                                if( currentTheme == theme)
                                {
                                    Circle()
                                        .strokeBorder(Color.green,lineWidth: 4)
                                        .background(Circle().foregroundColor(.clear))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct BlankView : View {
    
    var bgColor: Color
    
    var body: some View {
        VStack {
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(bgColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ScoreBoard: View {
    
    var w : Int
    var d : Int
    var l : Int
    var scoreColor : ColorPair
    
    var body: some View {
        HStack {
            Text("W : \(w)")
                .fontWeight(.black)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(scoreColor.main)
                .opacity(scoreColor.opt)
                .padding()
            Text("D : \(d)")
                .fontWeight(.black)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(scoreColor.main)
                .opacity(scoreColor.opt)
                .padding()
            Text("L : \(l)")
                .fontWeight(.black)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(scoreColor.main)
                .opacity(scoreColor.opt)
                .padding()
        }
    }
}

struct AIMenus: View {
    
    @ObservedObject var viewModel : GameViewModel
    var theme : ColorSet
    
    var body: some View {
        Menu {
            Button(action: {
                print("Noob Selected")
                viewModel.levelOfAI = .noob
                viewModel.gameConfig.levelOfAI = viewModel.levelOfAI.rawValue
            }) {
                Label("Noob", systemImage: viewModel.levelOfAI == .noob ? "checkmark.seal.fill" : "")
            }
            Button( action: {
                print("Ordinary Selected")
                viewModel.levelOfAI = .odinary
                viewModel.gameConfig.levelOfAI = viewModel.levelOfAI.rawValue
            }) {
                Label("Ordinary", systemImage: viewModel.levelOfAI == .odinary ? "checkmark.seal.fill" : "")
            }
            Button(action: {
                print("Insane Selected")
                viewModel.levelOfAI = .insane
                viewModel.gameConfig.levelOfAI = viewModel.levelOfAI.rawValue
            }) {
                Label("Insane", systemImage: viewModel.levelOfAI == .insane ? "checkmark.seal.fill" : "")
            }
        } label: {
            HStack {
                Image(systemName: "ellipsis.circle")
                    .font(.largeTitle)
                Text("AI Levels")
            }
            .padding()
            .foregroundColor(theme.buttonC.main).opacity(theme.buttonC.opt)
        }
    }
}
