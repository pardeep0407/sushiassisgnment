
import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    // 1: Session property
    private var session = WCSession.default
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    @IBOutlet weak var TimerWarning: WKInterfaceLabel!
    @IBOutlet var getMessage: WKInterfaceLabel!
    @IBOutlet var sendMessage: WKInterfaceButton!
    
//    MoveInput
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        TimerWarning.setText(message["Time"] as? String)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    @IBAction func MoveLeft() {
        
        let MoveInput = ["MoveInput":"Left"]
        if (WCSession.default.isReachable) {
            session.sendMessage(MoveInput,replyHandler: nil, errorHandler: {error in
                print("error received is \(error)")
            })
        }
        
        
    }
    @IBAction func MoveRight() {
        let mainMessage = ["MoveInput":"Right"]
        print("Moving Right")
        if (WCSession.default.isReachable) {
            session.sendMessage(mainMessage,
                                replyHandler: nil , errorHandler: {error in
                                    // catch any errors here
                                    print("error received is \(error)")
            })
        }
    }
    
}

