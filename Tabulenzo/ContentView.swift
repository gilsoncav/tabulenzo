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

struct RoundQuestionModel: Hashable, Identifiable {
    let id = UUID().uuidString
    
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
    enum FocusableQuestion: Hashable {
        case none
        case row(id: String)
    }
    
    enum GameState {
        case notStarted
        case roundReady
        case roundActive
    }
    
    @State private var state: GameState = .notStarted
    @State private var roundTableNumber = 5
    @State private var roundQuestionsQty = 5
    @State private var roundQuestions: [RoundQuestionModel] = []
    @State private var questionGuess: String = ""
    @State private var currentQuestionArrayIndex: Int = 0
    @State private var nextQuestionArrayIndex: Int = 1
    @State private var roundsCounter: Int = 1
    @FocusState private var focusedQuestion: FocusableQuestion?
    
    var isLastQuestion: Bool {
        currentQuestionArrayIndex == roundQuestions.count - 1
    }
    
    var isSecondToLastQuestion: Bool {
        currentQuestionArrayIndex == roundQuestions.count - 2
    }
    
    func startNewRound() {
        roundsCounter += 1
        roundQuestions = Array(1...roundQuestionsQty).map {
            RoundQuestionModel(index: $0, factorA: roundTableNumber)
        }
        currentQuestionArrayIndex = 0
        nextQuestionArrayIndex = 1
        state = .roundReady
    }
    
    func activateRound() {
        roundQuestions[0].status = .active
        state = .roundActive
    }
    
    func processUserGuess() {
        state = .roundActive
        roundQuestions[currentQuestionArrayIndex].productGuess = Int(questionGuess) ?? 0
        questionGuess = ""
        if !isLastQuestion {
            // Starting next question automatically
            roundQuestions[nextQuestionArrayIndex].status = .active
            currentQuestionArrayIndex += 1
            nextQuestionArrayIndex += 1
        } else {
            // TODO implement end of the Round
            focusedQuestion = FocusableQuestion.none
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
        ZStack (alignment: .bottomTrailing) {
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
                ScrollViewReader { scroll in
                    List($roundQuestions) { $question in
                        HStack {
                            Group {
                                Image(systemName: "\(question.index).circle")
                                    .foregroundColor(questionColor(question: question))
                                    .scaleEffect(0.6)
                                Text("\(question.factorA)")
                                Text("x")
                                question.status == .unrevealed ? Text("?") : Text("\(question.factorB)")
                                Text("=")
                                switch question.status {
                                case .unrevealed:
                                    Spacer()
                                case .active:
                                    ZStack(alignment: .trailing) {
                                        TextField("??", text: $questionGuess)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.numberPad)
                                            .focused($focusedQuestion, equals: .row(id: question.id))
                                            .onAppear {
                                                focusedQuestion = .row(id: question.id)
                                            }
                                            .task {
                                                try? await Task.sleep(nanoseconds: 400_000_000)
                                                if case .row(let id) = focusedQuestion {
                                                    withAnimation {
                                                        scroll.scrollTo(id, anchor: .bottom)
                                                    }
                                                }
                                            }
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
            Button {
                print("state")
                print(state)
                switch state {
                case .notStarted:
                    activateRound()
                case .roundReady:
                    activateRound()
                case .roundActive:
                    processUserGuess()
                }
            } label: {
                switch state {
                case .notStarted, .roundReady:
                    Image(systemName: "brain")
                        .font(.system(size: 30))
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                case .roundActive:
                    Image(systemName: "questionmark.diamond")
                        .font(.system(size: 30))
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding([.trailing, .bottom], 25)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // ATTENTION: workaround to fix a xCode preview bug as reported here: https://www.hackingwithswift.com/forums/swiftui/focusstate-breaking-preview/11396
        ZStack {
            ContentView()
        }
    }
}
