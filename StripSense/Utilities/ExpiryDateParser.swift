//
//  ExpiryDateParser.swift
//  StripSense
//

import Foundation

public struct ExpiryDateParser {
    public struct ParseResult {
        public let date: Date?
        public let rawDateString: String?
        public let batchNumber: String?
        
        public init(date: Date?, rawDateString: String?, batchNumber: String?) {
            self.date = date
            self.rawDateString = rawDateString
            self.batchNumber = batchNumber
        }
    }
    
    private static let monthNames: [String: Int] = [
        "jan": 1, "january": 1,
        "feb": 2, "february": 2,
        "mar": 3, "march": 3,
        "apr": 4, "april": 4,
        "may": 5,
        "jun": 6, "june": 6,
        "jul": 7, "july": 7,
        "aug": 8, "august": 8,
        "sep": 9, "sept": 9, "september": 9,
        "oct": 10, "october": 10,
        "nov": 11, "november": 11,
        "dec": 12, "december": 12
    ]
    
    /// Parses expiry date and batch number from OCR text lines
    public static func parse(from text: String) -> ParseResult {
        var foundDate: Date? = nil
        var foundDateStr: String? = nil
        var foundBatch: String? = nil
        
        let lines = text.components(separatedBy: .newlines)
        
        // Batch number regex pattern: B.No., BATCH, LOT, B NO
        let batchRegex = try? NSRegularExpression(
            pattern: #"(?:B\.?\s*NO\.?|BATCH(?:\s*NO\.?)?|LOT(?:\s*NO\.?)?)\s*[:.-]?\s*([A-Za-z0-9\-_]+)"#,
            options: .caseInsensitive
        )
        
        // Expiry pattern with prefix: EXP, EXPIRY, EXP. DATE, USE BEFORE
        let expPrefixRegex = try? NSRegularExpression(
            pattern: #"(?:EXP(?:IRY)?(?:\s*DATE|\.)?|USE\s*BEFORE|BEST\s*BEFORE)\s*[:.-]?\s*([A-Za-z]{3,9}|\d{1,2})[\s\/\.\-]+(\d{2,4})"#,
            options: .caseInsensitive
        )
        
        // Generic MM/YY or MM/YYYY pattern
        let genericDateRegex = try? NSRegularExpression(
            pattern: #"\b(0[1-9]|1[0-2])[\/\.\-](20\d{2}|\d{2})\b"#,
            options: []
        )
        
        for line in lines {
            let nsLine = line as NSString
            let fullRange = NSRange(location: 0, length: nsLine.length)
            
            // 1. Check for batch number
            if foundBatch == nil, let batchRegex = batchRegex {
                if let match = batchRegex.firstMatch(in: line, options: [], range: fullRange), match.numberOfRanges > 1 {
                    let batchRange = match.range(at: 1)
                    if batchRange.location != NSNotFound {
                        foundBatch = nsLine.substring(with: batchRange).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            }
            
            // 2. Check for expiry with explicit prefix
            if foundDate == nil, let expRegex = expPrefixRegex {
                if let match = expRegex.firstMatch(in: line, options: [], range: fullRange), match.numberOfRanges >= 3 {
                    let monthPart = nsLine.substring(with: match.range(at: 1))
                    let yearPart = nsLine.substring(with: match.range(at: 2))
                    if let parsedDate = makeDate(monthString: monthPart, yearString: yearPart) {
                        foundDate = parsedDate
                        foundDateStr = "\(monthPart)/\(yearPart)"
                    }
                }
            }
        }
        
        // 3. Fallback: if no explicit EXP prefix was found, search all lines for generic MM/YYYY
        if foundDate == nil, let genericRegex = genericDateRegex {
            var candidateDates: [(Date, String)] = []
            for line in lines {
                let nsLine = line as NSString
                let fullRange = NSRange(location: 0, length: nsLine.length)
                let matches = genericRegex.matches(in: line, options: [], range: fullRange)
                for match in matches where match.numberOfRanges >= 3 {
                    let monthPart = nsLine.substring(with: match.range(at: 1))
                    let yearPart = nsLine.substring(with: match.range(at: 2))
                    if let d = makeDate(monthString: monthPart, yearString: yearPart) {
                        candidateDates.append((d, "\(monthPart)/\(yearPart)"))
                    }
                }
            }
            
            // If multiple dates found (e.g. MFG and EXP), the later date is the expiry date!
            if let maxCandidate = candidateDates.max(by: { $0.0 < $1.0 }) {
                foundDate = maxCandidate.0
                foundDateStr = maxCandidate.1
            }
        }
        
        return ParseResult(date: foundDate, rawDateString: foundDateStr, batchNumber: foundBatch)
    }
    
    private static func makeDate(monthString: String, yearString: String) -> Date? {
        var month: Int? = Int(monthString)
        if month == nil {
            month = monthNames[monthString.lowercased()]
        }
        guard let m = month, m >= 1 && m <= 12 else { return nil }
        
        var year: Int? = Int(yearString)
        guard var y = year else { return nil }
        if y < 100 {
            y += 2000 // Convert '26' to 2026
        }
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        
        var components = DateComponents()
        components.year = y
        components.month = m
        components.day = 1
        
        // Return the last day of that month for expiry
        if let firstOfMonth = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: firstOfMonth) {
            components.day = range.count
            return calendar.date(from: components)
        }
        
        return nil
    }
}
