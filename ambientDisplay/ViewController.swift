//
//  ViewController.swift
//  test1
//
//  Created by Taeheon Kim on 1/22/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let errorChannel = Notification.Name("errorChannel")
}

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    var timeController: TimeController = TimeController()
    var timeLabelTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Listener for errors
        // Usage: NotificationCenter.default.post(name: .errorChannel, object: "Error message.")
        NotificationCenter.default.addObserver(self, selector: #selector(setErrorMessage(notification:)), name: .errorChannel, object: nil)
        
        // Timer loop for clock
        timeLabelTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        
    @objc func setErrorMessage(notification: NSNotification) {
        errorLabel.text = (notification.object as! String)
    }
    
    @objc func updateTimeLabel() {
        timeLabel.text = timeController.getCurrentTime()
    }

}

