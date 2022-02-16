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
    
    func startNewRound() {
        roundQuestions = Array(1...roundQuestionsQty).map {
            RoundQuestionModel(index: $0, factorA: roundTableNumber)
        }
    }
    
    var body: some View {
        NavigationView {
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
                    List($roundQuestions, id: \.self) { question in
                        HStack {
                            Image(systemName: "\(question.wrappedValue.index ).circle")
                                .foregroundColor(.secondary)
                                .scaleEffect(0.8)
                            Text("\(question.wrappedValue.factorA)")
                            Text("x")
                            Text("\(question.wrappedValue.factorB)")
                            Text("=")
                        }
                        .font(.largeTitle)
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
