//
//  ContentView.swift
//  WordScramble
//
//  Created by Eymen Varilci on 11.08.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var newWord = ""
    @State private var rootWord = ""
    @State private var score = 0
    @State private var totalScore = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    var body: some View {
        
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                    
                }
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
                Section("Points for this word") {
                    Text("\(score)")
                }
                Section("Total points") {
                    Text("\(totalScore)")
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("Shuffle", action: startGame)
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
        
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        // checks will come here
        guard isOriginal(word: answer) else {
            wordAlert(title: "Word used already", message: "Think harder!")
            return
        }
        guard isPossible(word: answer) else {
            wordAlert(title: "Word is not possible!", message: "You can't spell that from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else {
            wordAlert(title: "Hmm", message: "Seems like you made it up...")
            return
        }
        score += answer.count
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        totalScore = score + totalScore
        if let url = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let contents = try? String(contentsOf: url) {
                let letter = contents.components(separatedBy: "\n")
                rootWord = letter.randomElement() ?? "Milkyway"
                score = 0
                return
            }
        }
        fatalError("could not load the start.txt from the bundle.")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool  {
        
        guard word.count >= 3 else {  return false }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelword = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelword.location == NSNotFound
    }
    func wordAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
