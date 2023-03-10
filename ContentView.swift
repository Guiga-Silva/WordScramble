//
//  ContentView.swift
//  WordScramble
//
//  Created by Guilherme Silva on 03/03/23.
//

import SwiftUI

struct ContentView: View {

        @State private var usedWords = [String]()
        @State private var rootWord = ""
        @State private var newWord = ""
        
        @State private var errorTitle = ""
        @State private var errorMessage = ""
        @State private var showingError = false
        
        @State private var score = 0
        
        var body: some View {
                NavigationView {
                        List {
                                Section {
                                        TextField("Enter your word", text: $newWord)
                                                .textInputAutocapitalization(.never)
                                }
                                
                                Section {
                                        ForEach(usedWords, id: \.self) { word in
                                                HStack {
                                                        Image(systemName: "\(word.count).circle")
                                                        Text(word)
                                                }
                                        }
                                }
                        }
                        .navigationTitle(rootWord)
                        .onSubmit(addNewWord)
                        .onAppear(perform: startGame)
                        .alert(errorTitle, isPresented: $showingError) {
                                Button("OK", role: .cancel) { }
                        } message: {
                                Text(errorMessage)
                        }
                        .toolbar {
                                
                                ToolbarItem(placement: .navigationBarLeading) {
                                        Text("Score: \(score)")
                                                .font(.headline)
                                }
                                
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        Button {
                                                startGame()
                                        } label: {
                                                Text("New Word")
                                        }
                                }
                        }
                        
                }
        }
        
        func addNewWord() {
                let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                guard answer.count > 0 else { return }
                
                guard isOriginal(word: answer) else {
                        wordError(title: "Word used already", message: "Be more original! \nYour score: \(score)")
                        return startGame()
                }
                
                guard isPossible(word: answer) else {
                        wordError(title: "Word not possible", message: "You cant spell that word from '\(rootWord)' \nYour score: \(score)")
                        return startGame()
                }
                
                guard isReal(word: answer) else {
                        wordError(title: "Word not recognized", message: "You cant just make them up! \nYour score: \(score)")
                        return startGame()
                }
                
                guard !tooShort(word: answer) else {
                        wordError(title: "Word is not allowed", message: "Word is too short \nYour score: \(score)")
                        return startGame()
                }
                
                guard !isRootWord(word: answer) else {
                        wordError(title: "Word is not allowed", message: "You cant use the Root Word \nYour score: \(score)")
                        return startGame()
                        
                }
                
                withAnimation {
                        usedWords.insert(answer, at: 0)
                        calculateScore(word: answer)
                }
                newWord = ""
        }
        
        func startGame() {
                if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
                        if let startWords = try? String(contentsOf: startWordsURL) {
                                let allWords = startWords.components(separatedBy: "\n")
                                rootWord = allWords.randomElement() ?? "silkworm"
                                
                                score = 0
                                newWord = ""
                                
                                guard usedWords.isEmpty else {
                                        usedWords.removeAll()
                                        return
                                }
                                
                                return
                        }
                }
                
                fatalError("Could not load 'start.txt' from bundle")
        }
        
        func isOriginal(word: String) -> Bool {
                !usedWords.contains(word)
        }
        
        func isPossible(word: String) -> Bool {
                var tempWord = rootWord
                
                for letter in word {
                        if let pos = tempWord.firstIndex(of: letter) {
                                tempWord.remove(at: pos)
                        }
                        else {
                                return false
                        }
                }
                
                return true
        }
        
        func isReal(word: String) -> Bool {
                let checker = UITextChecker()
                let range = NSRange(location: 0, length: word.utf16.count)
                let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
                
                return misspelledRange.location == NSNotFound
        }
        
        func tooShort(word: String) -> Bool {
                
                if (word.count < 3) {
                        return true
                }
                
                return false
        }
        
        func isRootWord(word:String) -> Bool {
                
                if (word == rootWord) {
                        return true
                }
                
                return false
        }
        
        func wordError(title: String, message: String) {
                errorTitle = title
                errorMessage = message
                showingError = true
        }
        
        func calculateScore(word: String) {
                score += (word.count * 5)
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
