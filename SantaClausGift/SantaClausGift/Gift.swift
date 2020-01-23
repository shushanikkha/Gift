import AVFoundation
import UIKit

class Gift: NSObject {
    var view: UIView
    var frame: CGRect
    var delegate: GiftDelegate?
    
    private var container: UIView!
    private var giftImageView: UIImageView!
    private var circleImageView: UIImageView!
    
    private var isCathed = false
    private var timer: Timer?
    private var timerAlive: Timer?
    
    private var showTime: TimeInterval = 1.0
    private var waitTime: TimeInterval = 1.0
    private var hideTime: TimeInterval = 0.3
    
    private var isKilled = false
    
    private var giftShowSound: AVAudioPlayer?
    private var giftEatedSound: AVAudioPlayer?
    private var giftBournedSound: AVAudioPlayer?
    
    private var giftBurnedTime = 0

    init(view: UIView, frame: CGRect) {
        self.view = view
        self.frame = frame
        super.init()
        giftAndSanta()

        giftShowSound = SoundEngine.shared.initSound("gift-show.wav")
        giftEatedSound = SoundEngine.shared.initSound("gift-burned.wav")
        giftBournedSound = SoundEngine.shared.initSound("santa-kill.wav")
    }
    
    func giftAndSanta() {
        container = UIView(frame: frame)
        container.backgroundColor = .clear
        
        circleImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
        circleImageView.contentMode = .scaleAspectFit
        circleImageView.image = UIImage(named: "hole")
        circleImageView.clipsToBounds = true
        circleImageView.layer.cornerRadius = frame.width / 2
        
        container.addSubview(circleImageView)
        view.addSubview(container)
        
        giftImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
        giftImageView.contentMode = .scaleAspectFit
        giftImageView.image = UIImage(named: "gift")
        giftImageView.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: frame.height)
        
        giftImageView.isUserInteractionEnabled = true
        circleImageView.isUserInteractionEnabled = true
        container.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(giftTapped))
        giftImageView.addGestureRecognizer(tap)
        
        circleImageView.addSubview(giftImageView)
    }
    
    @objc
    func giftTapped() {
        delegate?.onGiftCatch()
        isCathed = true
        giftBurnedTime += 1
        giftBournedSound?.play()
        timer?.invalidate()
        UIView.animate(withDuration: 0.15, animations: {
            self.giftImageView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        }, completion: ({_ in
            self.giftImageView.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: self.frame.height)
            self.startGift()
        }))
    }
    
    func removeFromParent() {
        isKilled = true
        timerAlive?.invalidate()
        timer?.invalidate()
        giftImageView.removeFromSuperview()
        circleImageView.removeFromSuperview()
        container.removeFromSuperview()
    }
    
    func show(showTime: TimeInterval, waitTime: TimeInterval) {
        self.showTime = showTime
        self.waitTime = waitTime
        
        isCathed = false
        
        giftShowSound?.play()
        UIView.animate(withDuration: showTime, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.giftImageView.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: 0.0)
        }, completion: ({_ in
            self.hideAnimated()
        }))
    }
    
    func hideAnimated() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false, block: ({_ in
            if self.isCathed == false {
                UIView.animate(withDuration: self.hideTime, animations: {
                    self.giftImageView.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: self.frame.height)
                }, completion: ({_ in
                    if self.isCathed == false && self.isKilled == false && self.giftImageView.superview != nil {
                        self.giftEatedSound?.play()
                        self.delegate?.onSantaBurned()
                    }
                    if self.isKilled == false {
                        self.startGift()
                    }
                }))
            }
            self.timer?.invalidate()
        }))
    }
    
    func startGift() {
        isKilled = false
        let time: TimeInterval = TimeInterval(CGFloat.random(in: 1...8))
        
        timerAlive = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: ({_ in
            if self.isKilled {
                return
            }
            let showTime = TimeInterval(CGFloat.random(in: 0.3...0.8))
            let waitTime = TimeInterval(CGFloat.random(in: 0.2...1.4))
            self.show(showTime: showTime, waitTime: waitTime)
        }))
    }
    
    func burn() {
        isKilled = true
        giftImageView.isHidden = true
        timerAlive?.invalidate()
        timer?.invalidate()
        
        timerAlive = nil
        timer = nil
        
        giftBournedSound = nil
        giftEatedSound = nil
        giftShowSound = nil
    }
    
}

protocol GiftDelegate {
    func onGiftCatch()
    func onSantaBurned()
}
