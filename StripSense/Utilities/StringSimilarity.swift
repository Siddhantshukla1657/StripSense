//
//  StringSimilarity.swift
//  StripSense
//

import Foundation

public struct StringSimilarity {
    /// Computes Levenshtein edit distance between two strings
    public static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let a = Array(s1.lowercased())
        let b = Array(s2.lowercased())
        let m = a.count
        let n = b.count
        
        if m == 0 { return n }
        if n == 0 { return m }
        
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,       // deletion
                    matrix[i][j - 1] + 1,       // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                )
            }
        }
        
        return matrix[m][n]
    }
    
    /// Returns normalized similarity ratio between 0.0 (unrelated) and 1.0 (identical)
    public static func similarityRatio(_ s1: String, _ s2: String) -> Double {
        let clean1 = normalize(s1)
        let clean2 = normalize(s2)
        if clean1 == clean2 { return 1.0 }
        let maxLen = max(clean1.count, clean2.count)
        if maxLen == 0 { return 1.0 }
        
        // Exact substring bonus
        if clean1.contains(clean2) || clean2.contains(clean1) {
            let minLen = min(clean1.count, clean2.count)
            let baseScore = Double(minLen) / Double(maxLen)
            return max(0.85, baseScore)
        }
        
        let dist = levenshteinDistance(clean1, clean2)
        return max(0.0, 1.0 - (Double(dist) / Double(maxLen)))
    }
    
    /// Cleans and normalizes tokens (removes dosage markers, dots, punctuation)
    public static func normalize(_ text: String) -> String {
        let lower = text.lowercased()
        let charactersToKeep = CharacterSet.alphanumerics.union(.whitespaces)
        let filtered = lower.unicodeScalars.filter { charactersToKeep.contains($0) }
        return String(String.UnicodeScalarView(filtered))
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    /// Token set overlap (Jaccard similarity)
    public static func tokenOverlapScore(query: String, target: String) -> Double {
        let qTokens = Set(normalize(query).components(separatedBy: " "))
        let tTokens = Set(normalize(target).components(separatedBy: " "))
        
        guard !qTokens.isEmpty && !tTokens.isEmpty else { return 0.0 }
        let intersection = qTokens.intersection(tTokens)
        let union = qTokens.union(tTokens)
        return Double(intersection.count) / Double(union.count)
    }
}
