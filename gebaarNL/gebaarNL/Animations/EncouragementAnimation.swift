//
//  EncouragementAnimation.swift
//  gebaarNL
//
//  Created by Esmee Kluijtmans on 18/12/2020.
//

enum EncouragementAnimation: String {
    case geloofinjezelf = "geloof-in-jezelf"
    case jekanhet = "je-kan-het"
    case nietpogeven = "niet-opgeven"
    
    static func randomAnimation() -> EncouragementAnimation {
        let animationToGetRandomly = [geloofinjezelf, jekanhet, nietpogeven]
        let index = Int.random(in: 0...2)
        let animation = animationToGetRandomly[index].rawValue
        return EncouragementAnimation(rawValue: animation)!
    }
}
