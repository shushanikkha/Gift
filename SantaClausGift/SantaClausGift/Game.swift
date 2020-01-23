import UIKit

class Game {
    private var view: UIView
    private var level = 1
    private var screen: MainScreen
    private var game: GameInfo
    private var topFieldMargin: CGFloat = 16.0
    private var gift = [Gift]()
    
    private var livesViews = [UIView]()
    private var santaViews = [UIView]()
    private var levelLabel: UILabel?
    
    private var viewResult: UIView?
    private var backButton: UIButton?
    
    private var gamePaused = false
    
    init(view: UIView) {
        self.view = view
        self.screen = MainScreen()
        self.game = GameInfo()
        self.game.giftCount = 5
        self.game.santaCount = 10
    }

    func startGame(level: Int) {
        viewResult?.removeFromSuperview()
        for m in gift {
            m.burn()
        }
        gamePaused = false
        game.santaCount = 10
        game.giftCount = 5 + ((level-1) * 5)
        self.level = level
        buildLevel()
        pauseButton()
    }
    
    func buildLevel() {
        levelLabel?.removeFromSuperview()
        levelLabel = UILabel(frame: CGRect(x: 0.0, y: screen.marginTop + 4, width: screen.width, height: 24))
        levelLabel?.text = "Level" + " \(level)"
        levelLabel?.textAlignment = .center
        view.addSubview(levelLabel!)
        makeLives()
        makeGrid()
    }
    
    func pauseButton() {
    backButton = UIButton(frame: CGRect(x: 20.0, y: 40.0, width: 50, height: 30))
    backButton?.setTitle("Pause", for: .normal)
    backButton?.layer.cornerRadius = 15
    backButton?.addTarget(self, action: #selector(pauseButtonAction), for: .touchUpInside)
    view.addSubview(backButton!)
    }
    
    @objc func pauseButtonAction() {
        gamePaused =  true
        burnAll()
        showFinal(text: "Start new game?")
    }
    
    func makeLives() {
        for v in livesViews {
            v.removeFromSuperview()
        }
        livesViews.removeAll()

        for v in santaViews {
            v.removeFromSuperview()
        }
        santaViews.removeAll()

        let w = (screen.width - 32.0) / CGFloat(10)
        topFieldMargin = screen.marginTop + (w * 2)
        
        var lineCount = game.giftCount
        if game.giftCount > 10 {
            lineCount = 9
        }
        for i in 0..<lineCount {
            let line = Int(i / 10)
            let leftIndent = i % 10

            let lineMargin: CGFloat = (CGFloat(line) * w) + 16
            let live = UIImageView(frame: CGRect(x: 16.0 + (CGFloat(leftIndent) * w), y: lineMargin + screen.marginTop + 16, width: w, height: w))
            live.image = UIImage(named: "gift")
            live.contentMode = .scaleAspectFit
            view.addSubview(live)
            
            livesViews.append(live)
        }
      
        if game.giftCount > 10 {
            let label = UILabel(frame: CGRect(x: 16.0 + (w * 9.0), y: screen.marginTop + (w / 1), width: w + 15.0, height: 32.0))
            label.text = String(game.giftCount)
            label.textAlignment = .center
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 15.0, weight: .medium)
            view.addSubview(label)
            livesViews.append(label)
        }
        
        for i in 0..<self.game.santaCount {
            let leftIndent = i % 10
            let live = UIImageView(frame: CGRect(x: 16.0 + (CGFloat(leftIndent) * w), y: topFieldMargin, width: w, height: w))
            live.image = UIImage(named: "santa")
            live.contentMode = .scaleAspectFit
            live.contentMode = .center
            view.addSubview(live)
            santaViews.append(live)
        }
        
        topFieldMargin = topFieldMargin + w
    }
    
    func makeGrid() {
        for m in gift {
            m.removeFromParent()
        }
        gift.removeAll()
        
        let w: CGFloat = ((screen.width - (16.0 * 4)) / 3.0)
        let rowCount: Int = Int((screen.height-topFieldMargin) / (w + 16.0))
        
        for row in 0..<rowCount {
            for i in 0..<3 {
                let rand = Int.random(in: 0...level+1)
                if rand == 0 || rand == level {
                    continue
                }

                let left: CGFloat = (w * CGFloat(i)) + (16.0 * CGFloat(i + 1))
                let top = topFieldMargin + (CGFloat(row) * w) + (16.0 * CGFloat(row + 1))
                let mouse = Gift(view: view, frame: CGRect(x: left, y: top, width: w, height: w))
                mouse.delegate = self
                gift.append(mouse)
                if gift.count > (level + 2) {
                    break
                }
            }
            if gift.count > (level + 2) {
                break
            }
        }
        for m in gift {
            m.startGift()
        }
    }
}

extension Game: GiftDelegate {
    func burnAll() {
        for m in gift {
            m.burn()
        }
    }
    
    func onGiftCatch() {
        guard gamePaused == false else { return }
        game.giftCount -= 1
        if game.giftCount < 1 {
            burnAll()
            gamePaused = true
            // you win!
            level += 1
            showWin()
            game.giftCount = 10 + (level * 5)
            return
        }
        makeLives()
    }
    
    func onSantaBurned() {
        guard gamePaused == false else { return }
        game.santaCount -= 1
        if game.santaCount < 1 {
            burnAll()
            gamePaused = true
            // you lose!
            showLose()
            game.giftCount = 10 + (level * 5)
            return
        }
        makeLives()
    }
}


extension Game {
    func showWin() {
        SoundEngine.shared.soundWin?.play()
        let i = UserDefaults.standard.integer(forKey: "top-level")
        if level > i {
            UserDefaults.standard.set(level - 1, forKey: "top-level")
        }
        showFinal(text: "You are winner!")
    }
    func showLose() {
        SoundEngine.shared.soundLose?.play()
        showFinal(text: "You lose :( ")
    }
    
    func showFinal(text: String) {
        viewResult?.removeFromSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            if self.gamePaused {
                SoundEngine.shared.playMusic(player: SoundEngine.shared.musicMenu)
            }
        })
        
        let height: CGFloat = 300.0
        let width: CGFloat = screen.width - 64.0

        let y = (screen.height / 2) - (height / 2)
        viewResult = UIView(frame: CGRect(x: 32.0, y: y, width: width, height: height))
    
        viewResult?.backgroundColor = .white
        viewResult?.alpha = 1.0
        viewResult?.layer.cornerRadius = 16.0
        
        
        let labelResult = UILabel(frame: CGRect(x: 16.0, y: 10, width: width - 32.0, height: height - 40.0))
        labelResult.textAlignment = .center
        labelResult.text = text
        labelResult.numberOfLines = 2
        labelResult.font = UIFont.systemFont(ofSize: 32.0, weight: .medium)
        viewResult?.addSubview(labelResult)
        
        
        let giftImage = UIImageView(frame: CGRect(x: 4, y: 4, width: 32, height: 32))
        giftImage.image = UIImage(named: "gift")
        viewResult?.addSubview(giftImage)
        let giftLabel = UILabel(frame: CGRect(x: 40.0, y: 8.0, width: 64.0, height: 30.0))
        giftLabel.text = String(game.giftCount)
        viewResult?.addSubview(giftLabel)

        
        let santaImage = UIImageView(frame: CGRect(x: width - 40, y: 5, width: 32, height: 32))
        santaImage.image = UIImage(named: "santa")
        viewResult?.addSubview(santaImage)
        let santaLabel = UILabel(frame: CGRect(x: width - 60.0, y: 8.0, width: 64.0, height: 30.0))
        santaLabel.text = String(game.santaCount)
        viewResult?.addSubview(santaLabel)

        let labelTapToContinue = UILabel(frame: CGRect(x: 0.0, y: 272.0, width: width, height: 28.0))
        labelTapToContinue.textAlignment = .center
        labelTapToContinue.text = "START GAME 👆🏼"
        viewResult?.addSubview(labelTapToContinue)
        
        viewResult?.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.viewResult?.alpha = 1.0
        })
        
        view.addSubview(viewResult!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onContinueTap))
        viewResult?.isUserInteractionEnabled = true
        viewResult?.addGestureRecognizer(tap)
        
        let topLevel = UserDefaults.standard.integer(forKey: "top-level")
        if topLevel > 0 {
            let labelTopLevel = UILabel(frame: CGRect(x: 16.0, y: 170.0, width: width - 32.0, height: 30.0))
            labelTopLevel.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
            labelTopLevel.textColor = .lightGray
            labelTopLevel.textAlignment = .center
            labelTopLevel.text = "Top level" + " \(topLevel)"
            viewResult?.addSubview(labelTopLevel)
        }
    }
    
    @objc func onContinueTap() {
        SoundEngine.shared.stopMusic(player: SoundEngine.shared.musicMenu)
        viewResult?.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.viewResult?.alpha = 0.0
        }, completion: ({_ in
            self.viewResult?.removeFromSuperview()
            self.startGame(level: self.level)
        }))
    }
    
    func initGame() {
        SoundEngine.shared.playMusic(player: SoundEngine.shared.musicMenu)
        makeLives()
        showFinal(text: "Catch your gift!")
    }
}
