import Foundation

extension String {
    struct Match {
        let value: String
        let range: NSRange
    }
    
    func match(_ regex: String) -> [Match] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
            .flatMap { match in
            (0..<match.numberOfRanges).map {
                
                Match(value: match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)), range: match.range(at: $0))
                
            }
        } ?? []
    }
    
    var sanitized: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "[^A-Za-z0-9]+", with: "", options: [.regularExpression])
    }
    
    var newlinesSanitized: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
