
import UIKit

class GameViewController: UIViewController {
    var gameMain: Game?

    override func viewDidLoad() {
        super.viewDidLoad()
        gameMain = Game(view: view)
        gameMain?.initGame()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }

    

}

