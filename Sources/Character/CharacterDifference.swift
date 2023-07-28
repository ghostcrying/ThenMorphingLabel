import Foundation

extension ThenMorphingLabel {
    
    /// 字符变动记录
    enum CharacterDifference: CustomDebugStringConvertible, Equatable {
        
        case same
        case add
        case delete
        case move(offset: Int)
        case moveAndAdd(offset: Int)
        case replace
        
        var debugDescription: String {
            switch self {
            case .same:
                return "The character is unchanged."
            case .add:
                return "A new character is ADDED."
            case .delete:
                return "The character is DELETED."
            case .move(let offset):
                return "The character is MOVED to \(offset)."
            case .moveAndAdd(let offset):
                return "The character is MOVED to \(offset) and a new character is ADDED."
            case .replace:
                return "The character is REPLACED with a new character."
            }
        }
    }

}
