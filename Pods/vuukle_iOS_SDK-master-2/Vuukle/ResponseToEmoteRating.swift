

import Foundation

class ResponseToEmoteRating {
    
    
    var result : Bool?
    
    static func setResponseToEmoteRating(pDict : NSDictionary) -> ResponseToEmoteRating {
        
        let lResponseToEmoteRating = ResponseToEmoteRating()
        lResponseToEmoteRating.result = pDict["result"] as? Bool

        return lResponseToEmoteRating
    }
    
    
}