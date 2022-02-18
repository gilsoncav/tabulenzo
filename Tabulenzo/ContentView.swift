//
//  ContentView.swift
//  Tabulenzo
//
//  Created by Gilson Cavalcanti on 15/02/22.
//

import SwiftUI

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
    }
}

struct RoundQuestionModel: Hashable {
    enum Status {
        case unrevealed
        case active
        case timedOut
        case error
        case right
    }
    
    let index: Int
    var status: Status = .active {
        didSet {
            // TODO implement timing
//            switch status {
//            case .timedOut:
//                // TODO register the final time
//            case .active:
//                // TODO register the start time
//            default:
//            }
        }
    }
    let factorA: Int
    let factorB: Int
    var product: Int {
        factorA * factorB
    }
    var productGuess: Int = -1 {
        didSet {
            if productGuess == product {
                status = .right
            } else {
                status = .error
            }
        }
    }
    
    init(index: Int, factorA: Int) {
        self.index = index
        self.factorA = factorA
        self.factorB = Int.random(in: 1...9)
    }
    
}

struct ContentView: View {
    @State private var roundTableNumber = 5
    @State private var roundQuestionsQty = 5
    @State private var roundQuestions: [RoundQuestionModel] = []
    @State private var questionGuess: Int = -1
    
    @State private var textBlinkOpacity: Double = 1.0
    @FocusState private var questionGuessTextInputIsFocused: Bool
    
    func startNewRound() {
        roundQuestions = Array(1...roundQuestionsQty).map {
            RoundQuestionModel(index: $0, factorA: roundTableNumber)
        }
    }
    
    func processUserGuess(in question: inout RoundQuestionModel) {
        question.productGuess = questionGuess
    }
    
    var body: some View {
        VStack {
            Section {
                SectionTitle(title: "Quer treinar qual tabuada?")
                Picker("number", selection: $roundTableNumber) {
                    ForEach(1..<10) {
                        Text("\($0)").tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section {
                SectionTitle(title: "Quantas perguntas responder?")
                Picker("questions", selection: $roundQuestionsQty) {
                    Text("5").tag(5)
                    Text("10").tag(10)
                    Text("20").tag(20)
                }
                .pickerStyle(.segmented)
            }
            Section {
                List($roundQuestions, id: \.self) { $question in
                    HStack {
                        Image(systemName: "\(question.index ).circle")
                            .foregroundColor(.secondary)
                            .scaleEffect(0.6)
                        Group {
                            Text("\(question.factorA)")
                            Text("x")
                            Text("\(question.factorB)")
                            Text("=")
                        }
                        switch question.status {
                        case .unrevealed:
                            Text("__")
                                .kerning(5)
                                .foregroundColor(.secondary)
                                .opacity(textBlinkOpacity)
                                .onTapGesture {
                                    question.status = .active
                                }
                                .animation(.default.speed(1.5).repeatForever(), value: textBlinkOpacity)
                                .onAppear {
                                    textBlinkOpacity = 0
                                }
                                .onDisappear {
                                    textBlinkOpacity = 1
                                }
                        case .active:
                            ZStack (alignment: .trailing) {
                                TextField("__", value: $questionGuess, format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .focused($questionGuessTextInputIsFocused)
                            }
                            Spacer()
                            Button() {
                                processUserGuess(in: &question)
                            } label: {
                                Image(systemName: "questionmark.square.dashed")
                            }
                            
                        case .error:
                            Text("\(question.productGuess)").foregroundColor(.red)
                        case .right:
                            Text("\(question.productGuess)").foregroundColor(.green)
                        default:
                            Text("__")
                        }
                        
                    }
                    .font(.custom("SF Compact", size: 40, relativeTo: .largeTitle))

                }
            }
        }
        .onAppear {
            startNewRound()
        }
        .onChange(of: roundTableNumber) { _ in
            startNewRound()
        }
        .onChange(of: roundQuestionsQty) { _ in
            startNewRound()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
