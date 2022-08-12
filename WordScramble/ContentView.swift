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
    @State private var highScore = UserDefaults.standard.integer(forKey: "high") // fetching highScore at the app launch
    @State private var maxRound = 10
    @State private var currentRound = 0
    @State private var gameOver = false
    
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
                Section("High Score") {
                    Text("\(highScore)")
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
    // takes player's input from TextField and checks every scenario we set
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        // checks will come here
        guard isOriginal(word: answer) else {
            wordAlert(title: "Word used already", message: "Think harder!")
            newWord = ""
            return
        }
        guard isPossible(word: answer) else {
            wordAlert(title: "Word is not possible!", message: "You can't spell that from '\(rootWord)'!")
            newWord = ""
            return
        }
        guard isReal(word: answer) else {
            wordAlert(title: "Hmm", message: "Seems like you made it up...")
            newWord = ""
            return
        }
        // if everything checks then adds 1 point to score
        score += answer.count
        // inserts players answer to our list with using slight animation
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        // after every insert empties TextField
        newWord = ""
    }
    func startGame() {
        // gameOver should switch to true if currentRound equals to maxRound
        gameOver = currentRound == maxRound
        
        // checking round count
        if currentRound < maxRound {
            currentRound += 1
            
        } else {  // if reached 10 rounds shows alert then starts over
            wordAlert(title: "Game over", message: "reached \(maxRound) round.\n Restart again.")
            showingAlert = true
            currentRound = 0
            score = 0
            totalScore = 0
            newWord = ""
            usedWords.removeAll()
        }
        // setting the totalScore of current game
        totalScore = score + totalScore
        
        // if totalScore of current game is higher than highScore then we have a new highScore
        if totalScore > highScore {
            highScore = totalScore
            // using userdefaults for keeping highScore even if app closed
            UserDefaults.standard.set(self.highScore, forKey: "high")
        }
        
        // getting our list of words by using bundle url from our Appbundle
        if let url = Bundle.main.url(forResource: "start", withExtension: "txt"){
            
            // this 'let contents' returning as a single string which contains our entire list of words
            if let contents = try? String(contentsOf: url) {
                // here we seperate our words by whitespaces and letter will return as array of string
                let letter = contents.components(separatedBy: "\n")
                
                rootWord = letter.randomElement() ?? "Milkyway"
                score = 0
                newWord = ""
                usedWords.removeAll()
                return
            }
        }
        // just incase we messed up
        fatalError("could not load the start.txt from the bundle.")
    }
    // this method checks players input if it's used before or not
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    // this method checks players input if it really comes from our rootWord
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
    // this method checks players input if it's real word. (misspeld or not)
    func isReal(word: String) -> Bool  {
        guard word.count >= 3 else {  return false }
        
        // this is where magic happens
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelword = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelword.location == NSNotFound
    }
    // this method sets alert title and message
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
