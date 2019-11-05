import SpriteKit
import GameplayKit
import WatchConnectivity

class GameScene: SKScene, WCSessionDelegate {
    
    var session: WCSession!
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    
    override func sceneDidLoad() {
          picSize = Int(decreaseLife.size.width)
        super.sceneDidLoad()
        if(WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    let decreaseLife = SKSpriteNode(imageNamed: "life")
    
   
    var picSize:Int = 0;
    let cat = SKSpriteNode(imageNamed: "character1")
    let sushiBase = SKSpriteNode(imageNamed:"roll")
    var catPosition = "left"
    
    // Make a tower
    var sushiTower:[SushiPiece] = []
    let SUSHI_PIECE_GAP:CGFloat = 80
    
    let scoreLabel = SKLabelNode(text:"Score: ")
     let TimerLabel = SKLabelNode(text:"Timer: ")
    var score = 0
    
    var WatchInput:String = "";
    var GameTotalTime = 25
    var TimerFunction = Timer()
  
    
    func SendTimeToWatch(TimeLeft:String){
        let msg = ["Time": TimeLeft]
        WCSession.default.sendMessage(msg, replyHandler: nil)
    }
    @objc func TimeTracker(){
        decreaseLife.size.width -= CGFloat( picSize / 25)
        GameTotalTime -= 1
       
        if(GameTotalTime == 0)
        {
             self.TimerLabel.text = "Timer: \(self.GameTotalTime)"
            TimerFunction.invalidate()
            GameTotalTime = 0
            decreaseLife.size.width = 0
            SendTimeToWatch(TimeLeft: "Game Over")
        }
        
        if(GameTotalTime == 15 || GameTotalTime == 10 || GameTotalTime == 5)
        {
            SendTimeToWatch(TimeLeft: "\(GameTotalTime) Seconds Left")
        }
          self.TimerLabel.text = "Timer: \(self.GameTotalTime)"
    }
    
    func spawnSushi() {
        
        // -----------------------
        // MARK: PART 1: ADD SUSHI TO GAME
        // -----------------------
        
        // 1. Make a sushi
        let sushi = SushiPiece(imageNamed:"roll")
        
        // 2. Position sushi 10px above the previous one
        if (self.sushiTower.count == 0) {
            // Sushi tower is empty, so position the piece above the base piece
            sushi.position.y = sushiBase.position.y
                + SUSHI_PIECE_GAP
            sushi.position.x = self.size.width*0.5
        }
        else {
            // OPTION 1 syntax: let previousSushi = sushiTower.last
            // OPTION 2 syntax:
            let previousSushi = sushiTower[self.sushiTower.count - 1]
            sushi.position.y = previousSushi.position.y + SUSHI_PIECE_GAP
            sushi.position.x = self.size.width*0.5
        }
        
        // 3. Add sushi to screen
        addChild(sushi)
        
        // 4. Add sushi to array
        self.sushiTower.append(sushi)
    }
    
    override func didMove(to view: SKView) {
        // add background
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        // add cat
        cat.position = CGPoint(x:self.size.width*0.25, y:100)
        addChild(cat)
        
        // add base sushi pieces
        sushiBase.position = CGPoint(x:self.size.width*0.5, y: 100)
        addChild(sushiBase)
        // build the tower
        self.buildTower()
        
        decreaseLife.position = CGPoint(x: 5, y:self.size.height - 110)
        decreaseLife.anchorPoint = CGPoint(x:0,y:0)
        addChild(decreaseLife)
        
        self.scoreLabel.position.x = 70
        self.scoreLabel.position.y = size.height - 200
        self.scoreLabel.fontName = "Avenir"
        self.scoreLabel.fontSize = 30
        self.scoreLabel.zPosition = 3
        addChild(scoreLabel)
        
        self.TimerLabel.position.x = 70
        self.TimerLabel.position.y = size.height - 150
        self.TimerLabel.fontName = "Avenir"
        self.TimerLabel.fontSize = 30
        self.TimerLabel.zPosition = 3
        addChild(TimerLabel)
        
         TimerFunction = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.TimeTracker), userInfo: nil, repeats: true)
    }
    
    func buildTower() {
        for _ in 0...10 {
            self.spawnSushi()
        }
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        WatchInput = message["MoveInput"] as! String
        
        
        // ------------------------------------
        // MARK: UPDATE THE SUSHI TOWER GRAPHICS
        //  When person taps mouse,
        //  remove a piece from the tower & redraw the tower
        // -------------------------------------
        if(GameTotalTime > 0)
        {
            let pieceToRemove = self.sushiTower.first
            if (pieceToRemove != nil) {
                // SUSHI: hide it from the screen & remove from game logic
                pieceToRemove!.removeFromParent()
                self.sushiTower.remove(at: 0)
                
                // SUSHI: loop through the remaining pieces and redraw the Tower
                for piece in sushiTower {
                    piece.position.y = piece.position.y - SUSHI_PIECE_GAP
                }
                
                // To make the tower inifnite, then ADD a new piece
                self.spawnSushi()
            }
            
            // ------------------------------------
            // MARK: ANIMATION OF PUNCHING CAT
            // -------------------------------------
            
            // show animation of cat punching tower
            let image1 = SKTexture(imageNamed: "character1")
            let image2 = SKTexture(imageNamed: "character2")
            let image3 = SKTexture(imageNamed: "character3")
            
            let punchTextures = [image1, image2, image3, image1]
            
            let punchAnimation = SKAction.animate(
                with: punchTextures,
                timePerFrame: 0.1)
            
            self.cat.run(punchAnimation)
        }
        // ------------------------------------
        // MARK: SWAP THE LEFT & RIGHT POSITION OF THE CAT
        //  If person taps left side, then move cat left
        //  If person taps right side, move cat right
        // -------------------------------------
        
        if (WatchInput == "Left" && GameTotalTime > 0) {
            print("TAP LEFT")
            // 2. person clicked left, so move cat left
            cat.position = CGPoint(x:self.size.width*0.25, y:100)
            
            // change the cat's direction
            let facingRight = SKAction.scaleX(to: 1, duration: 0)
            self.cat.run(facingRight)
            
            // save cat's position
            self.catPosition = "left"
        }
        else if (WatchInput == "Right" && GameTotalTime > 0) {
            print("TAP RIGHT")
            // 2. person clicked right, so move cat right
            cat.position = CGPoint(x:self.size.width*0.85, y:100)
            
            // change the cat's direction
            let facingLeft = SKAction.scaleX(to: -1, duration: 0)
            self.cat.run(facingLeft)
            // save cat's position
            self.catPosition = "right"
        }
        
       
        // ------------------------------------
        // MARK: WIN AND LOSE CONDITIONS
        // -------------------------------------
        if (self.sushiTower.count > 0) {
            let firstSushi:SushiPiece = self.sushiTower[0]
            let chopstickPosition = firstSushi.stickPosition
            
            if (catPosition == chopstickPosition && GameTotalTime > 0) {
                SendTimeToWatch(TimeLeft: "Game Over")
                TimerFunction.invalidate()
                GameTotalTime = 0
            }
            else if (catPosition != chopstickPosition &&  GameTotalTime > 0) {
                self.score = self.score + 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
        else {
            print("Sushi tower is empty!")
        }
        
        
        
    }
    
}

