//
//  WelcomeController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation

import UIKit
import FirebaseAuth
import LBTAComponents
import JGProgressHUD
import SwiftyJSON
import FirebaseStorage
import FirebaseDatabase
import SwiftValidator
import GoogleSignIn
import SwiftSpinner
import AVKit

class WelcomeController: UIViewController {
    
    var name: String?
    var email: String?
    var profilePicture: UIImage?
    var videoPlayer: AVPlayer?
    
    let loginImg: UIImageView = {
        let img = UIImageView(image: UIImage(named: "MPM_logo_revised"))
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    
    lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributeTitle = NSMutableAttributedString(string: "Don't have an account? ",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0),
                         NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        button.setAttributedTitle(attributeTitle, for: .normal)
        attributeTitle.append(NSAttributedString(string: "Sign Up" , attributes:
            [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]))
        button.addTarget(self, action: #selector(signUpAction), for: .touchUpInside)
        return button
    }()
    
    lazy var loginButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.layer.cornerRadius = Service.buttonCornerRadius
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        loginButton.backgroundColor = UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0)
        dontHaveAccountButton.backgroundColor = UIColor.clear
        
        let videoURL: NSURL = Bundle.main.url(forResource: "skele8", withExtension: "mp4")! as NSURL
        videoPlayer = AVPlayer(url: videoURL as URL)
        videoPlayer?.actionAtItemEnd = .none
        videoPlayer?.isMuted = true
        
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        setAVPlayerDontCancelBackgroundAudio()
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.zPosition = -1
        playerLayer.frame = view.frame
        view.layer.addSublayer(playerLayer)
        videoPlayer?.play()
        var isPlayingInNegative = false
        // add observer to watch for video end in order to loop video
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                object: self.videoPlayer?.currentItem, queue: nil) {
                    (_) in
                    if !isPlayingInNegative {
                        self.videoPlayer?.seek(to: self.videoPlayer!.currentItem!.asset.duration)
                        self.videoPlayer?.play()
                        self.videoPlayer!.rate = -1.0
                        isPlayingInNegative = true
                    } else {
                        self.videoPlayer?.pause()
                        self.videoPlayer?.seek(to: kCMTimeZero)
                        self.videoPlayer?.play()
                        isPlayingInNegative = false
                }
        }
        
        view.addSubview(loginImg)
        anchorLoginImg(loginImg)

        view.addSubview(dontHaveAccountButton)
        anchorDontHaveAccountButton(dontHaveAccountButton)

        view.addSubview(loginButton)
        anchorLoginButton(loginButton)
        
    }
    
    //Solution adapted from https://stackoverflow.com/questions/31671029/prevent-avplayer-from-canceling-background-audio
    fileprivate func setAVPlayerDontCancelBackgroundAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch let err as NSError {
            print(err)
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err as NSError {
            print(err)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    
    @objc func loginAction() {
        let loginVC = LoginViewConroller()
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    
    @objc func signUpAction() {
        let signUserUpController = SignUserUpController()
        self.navigationController?.pushViewController(signUserUpController, animated: true)
    }
    
    
   
    fileprivate func anchorDontHaveAccountButton(_ button: UIButton) {
        button.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    
    
    fileprivate func anchorLoginImg(_ image: UIImageView) {
        image.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 80, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 300)
    }
    
  

    fileprivate func anchorLoginButton(_ button: UIButton) {
        button.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: dontHaveAccountButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
}
