//
//  ProgressHandler.swift
//  gebaarNL
//
//  Created by Angelica Dewi on 10/12/2020.
//

import Foundation
import UIKit

enum Level: String{
    case letterA, letterB, letterC, letterD, letterE, checkpoint1, letterF, letterG, letterH, letterI, checkpoint2, letterJ, letterK, letterL, letterM, letterN, checkpoint3, letterO, letterP, letterQ, checkpoint4, letterR, letterS, letterT, checkpoint5, letterU, letterV, letterW, checkpoint6, letterX, letterY, letterZ, checkpoint7, final1, none
}


class ProgressTracker{
    
    private var completedLevels: Array<Level>
    private var currentLevel: Level
    
    private var scrollViewContentOffset: CGPoint
    
    static let shared = ProgressTracker()
    
    init(){
        print("Progress Tracker init()")
        self.completedLevels = Array<Level>()
        self.currentLevel = .none
        self.scrollViewContentOffset = CGPoint(x: 0, y: 0)
    }
    
    func SetCurrentLevel(to level: Level){
        self.currentLevel = level
    }
    
    func GetCurrentLevel() -> Level{
        return self.currentLevel
    }
    
    func GetTestLetters(of level: Level) -> Array<Level>{
        var levels = [Level]()
        switch (level){
        case .checkpoint1:
            levels = [.letterA, .letterB, .letterC, .letterD, .letterE]
        case .checkpoint2:
            levels = [.letterF, .letterG, .letterH, .letterI]
        case .checkpoint3:
            levels = [.letterJ, .letterK, .letterL, .letterM, .letterN]
        case .checkpoint4:
            levels = [.letterO, .letterP, .letterQ]
        case .checkpoint5:
            levels = [.letterR, .letterS, .letterT]
        case .checkpoint6:
            levels = [.letterU, .letterV, .letterW]
        case .checkpoint7:
            levels = [.letterX, .letterY, .letterZ]
        case .final1:
            levels = [.letterA, .letterB, .letterC, .letterD, .letterE, .letterF, .letterG, .letterH, .letterI, .letterJ, .letterK, .letterL, .letterM, .letterN, .letterO, .letterP, .letterQ, .letterR, .letterS, .letterT, .letterU, .letterV, .letterW, .letterX, .letterY, .letterZ]
        default:
            levels = []
        }
        return levels
    }
        
    func AddToCompletedLevels(level: Level){
//        print("New Completed Level: " + level.rawValue)
        if (completedLevels.contains(level) != true){
            completedLevels.append(level)
        }
        self.SaveProgress()
    }
    
    func GetCompletedLevels() -> Array<Level>{
        return completedLevels
    }
        
    func RetrieveProgress() {
        // Get progress from Progress.plist.
        var stringArr = Array<String>()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent("Progress.plist")

        if let dictRoot = NSDictionary(contentsOfFile: path){
            stringArr = dictRoot.object(forKey: "CompletedLevels") as! [String]
        }
        if (stringArr.count != 0){
            for i in stringArr{
                if (completedLevels.contains(ProgressTracker.shared.ConvertToLevel(from: i)) == false){
                    completedLevels.append(ProgressTracker.shared.ConvertToLevel(from: i))
                }
            }
        } else{
            completedLevels.append(.none)
        }
    }

    func SaveProgress() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDir = paths.object(at: 0) as! NSString
        let path = documentDir.appendingPathComponent("Progress.plist")
        var stringArr = Array<String>()
        for c in completedLevels{
            stringArr.append(c.rawValue)
        }
        var dict = NSDictionary()
            dict = ["CompletedLevels": stringArr]
            dict.write(toFile: path, atomically: false)
    }
    
    func ConvertToLevel(from string: String) -> Level{
        switch (string){
        case "letterA":
            return Level.letterA
        case "letterB":
            return Level.letterB
        case "letterC":
            return Level.letterC
        case "letterD":
            return Level.letterD
        case "letterE":
            return Level.letterE
        case "letterF":
            return Level.letterF
        case "letterG":
            return Level.letterG
        case "letterH":
            return Level.letterH
        case "letterI":
            return Level.letterI
        case "letterJ":
            return Level.letterJ
        case "letterK":
            return Level.letterK
        case "letterL":
            return Level.letterL
        case "letterM":
            return Level.letterM
        case "letterN":
            return Level.letterN
        case "letterO":
            return Level.letterO
        case "letterP":
            return Level.letterP
        case "letterQ":
            return Level.letterQ
        case "letterR":
            return Level.letterR
        case "letterS":
            return Level.letterS
        case "letterT":
            return Level.letterT
        case "letterU":
            return Level.letterU
        case "letterV":
            return Level.letterV
        case "letterW":
            return Level.letterW
        case "letterX":
            return Level.letterX
        case "letterY":
            return Level.letterY
        case "letterZ":
            return Level.letterZ
        case "checkpoint1":
            return Level.checkpoint1
        case "checkpoint2":
            return Level.checkpoint2
        case "checkpoint3":
            return Level.checkpoint3
        case "checkpoint4":
            return Level.checkpoint4
        case "checkpoint5":
            return Level.checkpoint5
        case "checkpoint6":
            return Level.checkpoint6
        case "checkpoint7":
            return Level.checkpoint7
        case "final1":
            return Level.final1
        default:
            return .none
        }
    }
    
    func GetLetter(of level: Level) -> String {
        switch level {
        case .letterA:
            return "A"
        case .letterB:
            return "B"
        case .letterC:
            return "C"
        case .letterD:
            return "D"
        case .letterE:
            return "E"
        case .checkpoint1:
            return "A, B, C, D, E"
        case .letterF:
            return "F"
        case .letterG:
            return "G"
        case .letterH:
            return "H"
        case .letterI:
            return "I"
        case .checkpoint2:
            return "F, G, H, I"
        case .letterJ:
            return "J"
        case .letterK:
            return "K"
        case .letterL:
            return "L"
        case .letterM:
            return "M"
        case .letterN:
            return "N"
        case .checkpoint3:
            return "J, K, L, M, N"
        case .letterO:
            return "O"
        case .letterP:
            return "P"
        case .letterQ:
            return "Q"
        case .checkpoint4:
            return "O, P, Q"
        case .letterR:
            return "R"
        case .letterS:
            return "S"
        case .letterT:
            return "T"
        case .checkpoint5:
            return "R, S, T"
        case .letterU:
            return "U"
        case .letterV:
            return "V"
        case .letterW:
            return "W"
        case .checkpoint6:
            return "U, V, W"
        case .letterX:
            return "X"
        case .letterY:
            return "Y"
        case .letterZ:
            return "Z"
        case .checkpoint7:
            return "X, Y, Z"
        case .none:
            return ""
        case .final1:
            return "A-Z"
        }
        
    }
    
    func SetScrollViewContentOffset(to value: CGPoint){
        scrollViewContentOffset = value
    }
    
    func GetScrollViewContentOffset() -> CGPoint{
        return scrollViewContentOffset
    }
}

