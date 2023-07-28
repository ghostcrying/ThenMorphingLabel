import Foundation

extension String {
    
    /// 比较字符串差异
    /// CharacterDifference: 差异结果数组
    /// skipDrawingResults: 表示在绘制差异结果时是否需要跳过对应字符
    func difference(_ text: String?) -> ([ThenMorphingLabel.CharacterDifference], skipDrawingResults: [Bool]) {
        
        guard let text = text else {
            let diffResults = Array(
                repeating: ThenMorphingLabel.CharacterDifference.delete,
                count: self.count
            )
            let skipDrawingResults = Array(
                repeating: false,
                count: self.count
            )
            return (diffResults, skipDrawingResults)
        }
        
        let newChars    = text.enumerated()
        let lhsLength   = self.count
        let rhsLength   = text.count
        var skipIndexes = [Int]()
        let leftChars   = Array(self)
        
        let maxLength = max(lhsLength, rhsLength)
        var differResults = Array(
            repeating: ThenMorphingLabel.CharacterDifference.add,
            count: maxLength
        )
        var skipDrawingResults = Array(
            repeating: false,                           
            count: maxLength
        )
        
        for i in 0..<maxLength {
            // If new string is longer than the original one
            if i > lhsLength - 1 {
                continue
            }
            
            let leftChar = leftChars[i]
            
            // Search left character in the new string
            var foundCharacterInRhs = false
            for (j, newChar) in newChars {
                if skipIndexes.contains(j) || leftChar != newChar {
                    continue
                }
                
                skipIndexes.append(j)
                foundCharacterInRhs = true
                if i == j {
                    // Character not changed
                    differResults[i] = .same
                } else {
                    // foundCharacterInRhs and move
                    let offset = j - i
                    // What is design? -> Design pattern.
                    // e: l5 r14
                    if i <= rhsLength - 1 {
                        // Move to a new index and add a new character to new original place
                        differResults[i] = .moveAndAdd(offset: offset)
                    } else {
                        differResults[i] = .move(offset: offset)
                    }
                    
                    skipDrawingResults[j] = true
                }
                break
            }
            
            if !foundCharacterInRhs {
                if i < rhsLength - 1 {
                    differResults[i] = .replace
                } else {
                    differResults[i] = .delete
                }
            }
        }
        
        return (differResults, skipDrawingResults)
        
    }
    
}
