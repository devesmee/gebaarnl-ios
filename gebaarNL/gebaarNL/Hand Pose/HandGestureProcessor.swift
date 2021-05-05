//
//  HandGestureProcessor.swift
//  gebaarNL
//
//  Created by Esmee Kluijtmans on 26/11/2020.
//

import CoreGraphics
import AVFoundation

class HandGestureProcessor {
    enum State {
        case possiblePinch
        case pinched
        case possibleApart
        case apart
        case unknown
    }
    
    typealias PointsPair = (thumbTip: CGPoint, indexTip: CGPoint)
    typealias AllPointsOneHand = (thumbTip: CGPoint, indexTip: CGPoint, middleTip: CGPoint, ringTip: CGPoint, littleTip: CGPoint, wrist: CGPoint)
    typealias AllPointsTwoHands = (leftThumbTip: CGPoint, leftIndexTip: CGPoint, leftMiddleTip: CGPoint, leftRingTip: CGPoint, leftLittleTip: CGPoint, leftWrist: CGPoint, rightThumbTip: CGPoint, rightIndexTip: CGPoint, rightMiddleTip: CGPoint, rightRingTip: CGPoint, rightLittleTip: CGPoint, rightWrist: CGPoint)
    
    private var state = State.unknown {
        didSet {
            didChangeStateClosure?(state)
        }
    }
    private var pinchEvidenceCounter = 0
    private var apartEvidenceCounter = 0
    private let pinchMaxDistance: CGFloat
    private let evidenceCounterStateTrigger: Int
    var currentLevel : Level = .none
    var countdownCorrect = 3
    var countdownString = ""
    var waitForFullHand = false
    var correctGesture = false
    var isMiniGame = false
    var isFinalTest = false
    var isInitialTime = true
    let audioUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "increase_score", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    
    // 0 is left, 1 is right.
    var whichHand = 0
    
    // MARK: MOVEMENTS VARIABLES
    var counter = 1
    var indexStartX: CGFloat = 0
    var indexStartY: CGFloat = 0
    var middleStartX: CGFloat = 0
    var middleStartY: CGFloat = 0
        
    var didChangeStateClosure: ((State) -> Void)?
    private (set) var lastProcessedPointsPair = PointsPair(.zero, .zero)
    private (set) var lastProcessedPointsOneHand = AllPointsOneHand(.zero, .zero, .zero, .zero, .zero, .zero)
    private (set) var lastProcessedPointsTwoHands = AllPointsTwoHands(.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    
    init(pinchMaxDistance: CGFloat = 40, evidenceCounterStateTrigger: Int = 3) {
        self.pinchMaxDistance = pinchMaxDistance
        self.evidenceCounterStateTrigger = evidenceCounterStateTrigger
        
        self.currentLevel = ProgressTracker.shared.GetCurrentLevel()
    }
    
    func reset() {
        state = .unknown
        pinchEvidenceCounter = 0
        apartEvidenceCounter = 0
    }
    
    func processPoints(_ points: AllPointsOneHand) {
        countdownString = "Nog \(countdownCorrect) keer"
        state = .possiblePinch
        lastProcessedPointsOneHand = points
        // Print distance between four points to wrist.
        let thumb = points.thumbTip.distance(from: points.wrist)
        let index = points.indexTip.distance(from: points.wrist)
        let middle = points.middleTip.distance(from: points.wrist)
        let ring = points.ringTip.distance(from: points.wrist)
        let little = points.littleTip.distance(from: points.wrist)
        
        let thumbX = points.thumbTip.x
        let thumbY = points.thumbTip.y
        let indexX = points.indexTip.x
        let indexY = points.indexTip.y
        let middleX = points.middleTip.x
        let middleY = points.middleTip.y
        
        let thumbToIndex = points.thumbTip.distance(from: points.indexTip)
        let thumbToMiddle = points.thumbTip.distance(from: points.middleTip)
        let thumbToRing = points.thumbTip.distance(from: points.ringTip)
        
        let indexToMiddle = points.indexTip.distance(from: points.middleTip)
        let indexToRing = points.indexTip.distance(from: points.ringTip)
        
        // MARK: FINGER POINTS.
//        print("thumb distance to wrist: ", thumb)
//        print("index distance to wrist: ", index)
//        print("middle distance to wrist: ", middle)
//        print("ring distance to wrist: ", ring)
//        print("little distance to wrist: ", little)
//        print("thumb to index: ", thumbToIndex)
//        print("thumb to middle: ", thumbToMiddle)
//        print("thumb to ring: ", thumbToRing)
//        print("index to middle: ", indexToMiddle)
//        print("index to ring: ", indexToRing)
//        print("thumb x: ", thumbX)
//        print("thumb y: ", thumbY)
//        print("index x: ", indexX)
//        print("index y: ", indexY)
//        print("middle x: ", middleX)
//        print("middle y: ", middleY)
        
        // thumb > 270, index < 130, middle < 115, ring < 105, little < 110
//        if (310...330 ~= thumb && 155...175 ~= index && 135...155 ~= middle && 115...135 ~= ring && 125...145 ~= little){
        switch currentLevel {
        // MARK: LETTER A.
        case .letterA:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 300 && little > 300){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            } else if (thumb > 300 && index < 220 && middle < 220 && ring < 220 && little < 220) {
                print("A")
                if (isMiniGame){
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER B.
        case .letterB:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            } 
//            } else if 135...155 ~= thumb && 375...395 ~= middle{
            else if (thumb < 200 && index > 300 && middle > 350 && ring > 250 && little > 250){
                print("B")
                if (isMiniGame){
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER C.
        case .letterC:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 230 && 200...400 ~= index && 200...400 ~= middle && 200...400 ~= ring && 200...400 ~= little){
                print("C")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER D.
        case .letterD:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 350 && index > 300 && middle < 300 && ring < 300 && little < 250){
                print("D")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER E.
        case .letterE:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 350 && index < 170 && middle < 140 && ring < 130 && little < 140){
                print("E")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER F.
        case .letterF:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false
                }
                return
            } else if (thumb < 300 && index < 215 && middle > 350 && ring > 250 && little > 250){
                print("F")
                if (isMiniGame){
                correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER G.
        case .letterG:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 250 && index < 200 && middle < 220 && ring < 220 && little < 220 && thumbToIndex < 120){
                print("G")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER H.
        case .letterH:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false
                    counter = 1
                }
                return
            }
            else if (thumb < 350 && index > 300 && middle > 130 && ring < 150 && little < 250){
                print("H")
                if(counter == 1)
                {
                    indexStartX = indexX
                    indexStartY = indexY
                    counter -= 1
                }
                if(counter != 1)
                {
                    if (indexY > (indexStartY + 5)) {
                        if (isMiniGame){
                            correctGesture = true
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                                audioPlayer.play()
                            } catch {
                                print("No file found")
                            }
                        } else if (isFinalTest && !waitForFullHand) {
                            waitForFullHand = true
                            correctGesture = true
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                                audioPlayer.play()
                            } catch {
                                print("No file found")
                            }
                        } else{
                            print("correct position")
                            if(!waitForFullHand) {
                                self.waitForFullHand = true
                                self.countdownCorrect -= 1
                                self.correctGesture = true
                                do {
                                    self.audioPlayer = try AVAudioPlayer(contentsOf: self.audioUrl as URL)
                                    self.audioPlayer.play()
                                } catch {
                                    print("No file found")
                                }
                            }
                        }
                    } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                        waitForFullHand = true
                    }
                }
            }
            break

            
        // MARK: LETTER I.
        case .letterI:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 350 && index < 450 && middle < 140 && ring < 130 && little > 180){
                print("I")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            }
            break

        // MARK: LETTER J.
        case .letterJ:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            } else if (counter == 1) {
                if (thumb < 350 && index < 450 && middle < 140 && ring < 130 && little > 180){
                print("J start")
                if(counter == 1)
                {
                    indexStartX = indexX
                    indexStartY = indexY
                    counter -= 1
                }
            
                } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
                }
            } else if (counter != 1) {
                print("J end")
                // For both left hand & right hand support
                if (indexX > (indexStartX + 30) && thumbX < indexX || indexX < (indexStartX - 30) && thumbX > indexX) {
                    if (isMiniGame){
                        correctGesture = true
                        counter = 1
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    } else if (isFinalTest && !waitForFullHand) {
                        waitForFullHand = true
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    } else{
                        if(!waitForFullHand) {
                            waitForFullHand = true
                            countdownCorrect -= 1
                            correctGesture = true
                            counter = 1
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                                audioPlayer.play()
                            } catch {
                                print("No file found")
                            }
                        }
                    }
                }
            }
            break
            
        // MARK: LETTER K.
        case .letterK:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 350 && index > 300 && middle > 130 && ring < 130 && little < 140 && indexToMiddle > 100){
                print("K")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
        
        // MARK: LETTER L.
        case .letterL:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb > 300 && index > 300 && middle < 140 && ring < 130 && little < 140){
                print("L")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER M.
        case .letterM:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 300 && index < 300 && middle < 200 && ring < 200 && little < 220 && thumbToIndex < 50 && indexToMiddle < 50){
                print("M")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER N.
        case .letterN:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 300 && index < 300 && middle < 200 && ring < 150 && little < 200 && thumbToIndex < 100 && indexToMiddle < 100){
                print("N")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
                
        // MARK: LETTER O.
        case .letterO:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 270 && 220...320 ~= index && 190...290 ~= middle && 200...300 ~= ring && 200...350 ~= little && thumbToIndex < 70){
                print("O")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER P.
        case .letterP:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 250 && index > 300 && middle < 150 && ring < 150 && little < 150){
                print("P")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER Q.
        case .letterQ:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (20...50 ~= thumbToIndex && middle < 200 && ring < 200 && little < 200){
                print("Q")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER R.
        case .letterR:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumbToMiddle < 70 && thumbToIndex > 50 && ring < 200 && little < 200){
                print("R")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER S.
        case .letterS:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 350 && index < 230 && middle < 200 && ring < 200 && little < 200){
                print("S")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
            
        // MARK: LETTER T.
        case .letterT:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumbToIndex < 50  && middle > 300  && ring > 300  && little > 300){
                print("T")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
        
        // MARK: LETTER U.
        case .letterU:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
               if (!isMiniGame) {
                isInitialTime = false
                waitForFullHand = false
                counter = 1
               }
                   return
            } else if (counter == 1) {
               if (index > 300  && middle > 250 && indexToMiddle < 70 && ring < 200  && little < 300){
               print("U start")
               if(counter == 1)
               {
                    indexStartX = indexX
                    middleStartX = middleX
                    counter -= 1
               }
           } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
               waitForFullHand = true
               }
           } else if (counter != 1) {
               print("U end")
               // For both left hand & right hand support
               if (indexX < indexStartX - 5 && middleX < middleStartX - 5 && thumbX < indexX || indexX < indexStartX + 5 && middleX < middleStartX + 5 && thumbX > indexX) {
                   if (isMiniGame){
                       correctGesture = true
                       counter = 1
                       do {
                           audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                           audioPlayer.play()
                       } catch {
                           print("No file found")
                       }
                   } else if (isFinalTest && !waitForFullHand) {
                        waitForFullHand = true
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                   } else{
                       if(!waitForFullHand) {
                           waitForFullHand = true
                           countdownCorrect -= 1
                           correctGesture = true
                           counter = 1
                           do {
                               audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                               audioPlayer.play()
                           } catch {
                               print("No file found")
                           }
                       }
                   }
               }
           }
               break
        
        // MARK: LETTER V.
        case .letterV:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 300  && index > 300  && middle > 300  && ring < 200  && little < 300){
                print("V")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
        
        // MARK: LETTER W.
        case .letterW:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb > 300  && index > 300  && middle > 300  && ring < 200  && little < 300){
                print("W")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
        
        // MARK: LETTER X.
        case .letterX:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb < 300  && index < 300  && middle < 200  && ring < 200  && little < 200){
                print("X")
                if (counter == 1){
                    indexStartX = indexX
                    indexStartY = indexY
                    counter -= 1
                }
                if (counter != 1){
                    // x-30 y+230
                    print ("start x ", indexStartX)
                    print ("start y ", indexStartY)
                    print("counter ", counter)
                    if (indexX < indexStartX && indexY > indexStartY){
                        if (isMiniGame){
                            correctGesture = true

                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                                audioPlayer.play()
                            } catch {
                                print("No file found")
                            }
                        } else if (isFinalTest && !waitForFullHand) {
                            waitForFullHand = true
                            correctGesture = true
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                                audioPlayer.play()
                            } catch {
                                print("No file found")
                            }
                        } else{
                            if(!waitForFullHand) {
                                waitForFullHand = true
                                countdownCorrect -= 1
                                correctGesture = true
                                do {
                                    audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                                    audioPlayer.play()
                                } catch {
                                    print("No file found")
                                }
                            }
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
        
        // MARK: LETTER Y.
        case .letterY:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false }
                return
            }
            else if (thumb > 300  && index < 200  && middle < 200  && ring < 200  && little > 300){
                print("Y")
                if (isMiniGame){
                    correctGesture = true

                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else if (isFinalTest && !waitForFullHand) {
                    waitForFullHand = true
                    correctGesture = true
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                        audioPlayer.play()
                    } catch {
                        print("No file found")
                    }
                } else{
                    if(!waitForFullHand) {
                        waitForFullHand = true
                        countdownCorrect -= 1
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    }
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
            }
            break
        
        // MARK: LETTER Z.
        case .letterZ:
            if (thumb > 250 && index > 300 && middle > 300 && ring > 250 && little > 250){
                if (!isMiniGame) {
                    isInitialTime = false
                    waitForFullHand = false
                    counter = 1
                }
                return
            } else if (counter == 1) {
                if (thumb < 350 && index > 300 && middle < 300 && ring < 300 && little < 250){
                print("Z start")
                if(counter == 1)
                {
                    indexStartX = indexX
                    indexStartY = indexY
                    counter -= 1
                }
            } else if (countdownCorrect == 3 && isMiniGame == false && isInitialTime == true){
                waitForFullHand = true
                }
            } else if (counter != 1) {
                print("Z end")
                // For both left hand & right hand support
                if (indexY > (indexStartY + 200) && indexX > (indexStartX + 80) && thumbX < indexX || indexY > (indexStartY + 200) && indexX < (indexStartX - 80) && thumbX > indexX) {
                    if (isMiniGame){
                        correctGesture = true
                        counter = 1
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    } else if (isFinalTest && !waitForFullHand) {
                        waitForFullHand = true
                        correctGesture = true
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                            audioPlayer.play()
                        } catch {
                            print("No file found")
                        }
                    } else{
                        if(!waitForFullHand) {
                            waitForFullHand = true
                            countdownCorrect -= 1
                            correctGesture = true
                            counter = 1
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl as URL)
                                audioPlayer.play()
                            } catch {
                                print("No file found")
                            }
                        }
                    }
                }
            }
            break
            
        default:
            print("nothing")
            break
        }
    }
    
    // FOR TWO HANDS
    /*
    func processPoints(_ points: AllPointsTwoHands) -> String{
        state = .possiblePinch
        lastProcessedPointsTwoHands = points
        // Print distance between four points to wrist.
        let thumb = points.leftThumbTip.distance(from: points.leftWrist)
        let index = points.leftIndexTip.distance(from: points.leftWrist)
        let middle = points.leftMiddleTip.distance(from: points.leftWrist)
        let ring = points.leftRingTip.distance(from: points.leftWrist)
        let little = points.leftLittleTip.distance(from: points.leftWrist)
        print("thumb distance to wrist: ", thumb)
        print("index distance to wrist: ", index)
        print("middle distance to wrist: ", middle)
        print("ring distance to wrist: ", ring)
        print("little distance to wrist: ", little)
        
        // thumb > 270, index < 130, middle < 115, ring < 105, little < 110
//        if (310...330 ~= thumb && 155...175 ~= index && 135...155 ~= middle && 115...135 ~= ring && 125...145 ~= little){
        if (thumb > 250 && index < 130 && middle < 115 && ring < 105 && little < 110){
            print("A")
            return "A"
//        } else if 135...155 ~= thumb && 375...395 ~= middle{
        } else if (middle > 350 && thumb < 150){
            print("B")
            return "B"
        } else {
            return ""
        }
    }
 */
}

// MARK: - CGPoint helpers

extension CGPoint {

    static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}
