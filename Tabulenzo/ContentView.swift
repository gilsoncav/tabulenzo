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
    var status: Status = .unrevealed {
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
    @State private var questionGuess: String = ""
    @State private var currentQuestionArrayIndex: Int = 0
    @State private var nextQuestionArrayIndex: Int = 1
    @State private var roundsCounter: Int = 1
    
    var isLastQuestion: Bool {
        currentQuestionArrayIndex == roundQuestions.count - 1
    }
    
    var isSecondToLastQuestion: Bool {
        currentQuestionArrayIndex == roundQuestions.count - 2
    }
    
    @State private var textBlinkOpacity: Double = 1.0

    
    func startNewRound() {
        roundsCounter += 1
        roundQuestions = Array(1...roundQuestionsQty).map {
            RoundQuestionModel(index: $0, factorA: roundTableNumber)
        }
        currentQuestionArrayIndex = 0
        nextQuestionArrayIndex = 1
    }
    
    func processUserGuess(in question: inout RoundQuestionModel) {
        question.productGuess = Int(questionGuess) ?? 0
        questionGuess = ""
        if !isLastQuestion {
            // Starting next question automatically
            roundQuestions[nextQuestionArrayIndex].status = .active
            currentQuestionArrayIndex += 1
            nextQuestionArrayIndex += 1
        } else {
            // TODO implement end of the Round
        }
    }
    
    func questionColor(question: RoundQuestionModel) -> Color {
        switch question.status {
        case .right:
            return Color.green
        case .error:
            return Color.red
        default:
            return Color.secondary
        }
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
                        Group {
                            Image(systemName: "\(question.index ).circle")
                                .foregroundColor(questionColor(question: question))
                                .scaleEffect(0.6)
                            Text("\(question.factorA)")
                            Text("x")
                            question.status == .unrevealed ? Text("?") : Text("\(question.factorB)")
                            Text("=")
                            switch question.status {
                            case .unrevealed:
                                if question.index == currentQuestionArrayIndex + 1 {
                                    Spacer()
                                    Button("Go!") {
                                        question.status = .active
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .font(.none)
                                    .lineLimit(1)
                                }
                            case .active:
                                ZStack (alignment: .trailing) {
                                    TextField("??", text: $questionGuess )
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.decimalPad)
                                }
                                Button("?") {
                                    processUserGuess(in: &question)
                                }
                                .buttonStyle(.borderedProminent)
                                .font(.none)
                            case .error:
                                Text("\(question.productGuess)").foregroundColor(.red)
                            case .right:
                                Text("\(question.productGuess)").foregroundColor(.green)
                            default:
                                Text("__")
                            }
                        }
                        .font(.custom("SF Compact", size: 40, relativeTo: .largeTitle))
                        .padding(.vertical)
                    }
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
