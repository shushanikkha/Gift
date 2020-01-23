import AVFoundation
import UIKit

class MainScreen {
    var width: CGFloat
    var height: CGFloat
    var marginTop: CGFloat
    init() {
        self.width = UIScreen.main.bounds.width
        self.height = UIScreen.main.bounds.height
        self.marginTop = UIApplication.shared.statusBarFrame.height
    }
}

class GameInfo {
    var giftCount: Int = 10
    var santaCount: Int = 10
    
}

class SoundEngine {
    static var shared = SoundEngine()
    var soundLose: AVAudioPlayer?
    var soundWin: AVAudioPlayer?
    var musicMenu: AVAudioPlayer?

    init() {
        soundLose = initSound("lose.wav")
        soundWin = initSound("win.wav")
        musicMenu = initSound("menu.wav")
    }
    
    func initSound(_ name: String) -> AVAudioPlayer? {
        let s: AVAudioPlayer?
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let url = URL(fileURLWithPath: path)
            do {
                s = try AVAudioPlayer(contentsOf: url)
                return s
            } catch {
            }
        }
        return nil
    }
    
    func playMusic(player: AVAudioPlayer?) {
        player?.numberOfLoops = 100
        player?.play()
    }
    
    func stopMusic(player: AVAudioPlayer?) {
        player?.stop()
    }
    
}

