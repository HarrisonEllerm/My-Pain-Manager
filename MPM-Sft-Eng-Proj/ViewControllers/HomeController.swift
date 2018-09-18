//
//  HomeController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 18/04/18.
//  Copyright © 2018 Sebastian Peden. All rights reserved.
//

import UIKit
import Firebase
import SceneKit
import SceneKit.ModelIO
import SwiftSpinner
import PopupDialog
import SwiftyBeaver
import SwiftDate
import NVActivityIndicatorView

class HomeController: UIViewController {

    public var manMesh: ObjectWrapper!
    public var scene: SCNScene!
    private var mesh: SCNNode!
    private var scnView: SCNView!
    private var camera: SCNCamera!
    private var cameraNode: SCNNode!
    private var wasClicked = false
    private var isLoading = true
    private var hasLoaded = false
    private let updateQueue = DispatchQueue(label: "updateQueue")
    private var loading: NVActivityIndicatorView?
    private var previousLocation = SCNVector3Make(0, 0, 0)
    private var rating: Double?
    private var tapCount = 0
    private let _scale = "100"
    private let log = SwiftyBeaver.self

    internal var intCounter = 0

    let slider: GradientSlider = {
        let s = GradientSlider()
        s.minColor = UIColor.black
        s.maxColor = UIColor(r: 254, g: 162, b: 25)
        s.thumbColor = UIColor(red: 48 / 255, green: 48 / 255, blue: 43 / 255, alpha: 1)
        s.tintColor = UIColor(red: 48 / 255, green: 48 / 255, blue: 43 / 255, alpha: 1)
        s.minimumValue = 0
        s.maximumValue = 100
        return s
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        UIView.animate(withDuration: 2.5, animations: {
            self.scnView.alpha = CGFloat(1.0)
            return
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        Service.setupNavBar(controller: self)
        view.backgroundColor = UIColor.black
        self.definesPresentationContext = true
        setupLoading()
        self.createSlider()
        
    }

    /**
        Loading Indicator Used to show users that the model is being loaded,
        which can take around a second since it is reading in large files to render
        the body.
     */
    private func setupLoading() {
        loading = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .ballClipRotatePulse, color: UIColor.white, padding: 0)
        loading?.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        loading?.isHidden = false
        view.addSubview(loading!)
        loading?.startAnimating()
    }

    func loadScene() {
        /*
         Several of the opperations are required to be executed
         on the main thread mandatorily, this also guarantees
         that everything is executed sequentially.
         */
        DispatchQueue.main.async {
            //add scene
            self.scnView = SCNView(frame: self.view.frame)
            self.scnView.alpha = CGFloat(0)
            self.view.addSubview(self.scnView)
            self.scene = SCNScene()
            self.scene.background.contents = UIImage(named: "spot")
            self.scnView.scene = self.scene;

            let mb = ModelBuilder()
            mb.addMaleSkin(hc: self)
            mb.addMaleSkeleton(hc: self)
            mb.addMuscles(hc: self)

            self.createCamera()
            self.createTapRecognizer()
            self.createLights()
            self.createSlider()
        }
    }


    func createTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: #selector(self.sceneTapped))//"sceneTapped:")
        let panRecogniser = UIPanGestureRecognizer()
        panRecogniser.addTarget(self, action: #selector(self.scenePannedOneFinger))
        let pinchRecogniser = UIPinchGestureRecognizer()
        pinchRecogniser.addTarget(self, action: #selector(self.sceneZoom))
        self.scnView.gestureRecognizers = [tapRecognizer, panRecogniser, pinchRecogniser]
    }


    func createCamera() {
        self.camera = SCNCamera()
        self.camera.zNear = 1
        self.cameraNode = SCNNode()
        self.cameraNode.camera = self.camera
        self.cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 25.0)
        self.scene.rootNode.addChildNode(self.cameraNode)
        self.scnView.allowsCameraControl = true
    }
    /**
     This creates the lights used within the GUI.
     */

    func createLights() {

        //Create light 1
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 50, y: 1.5, z: 1.5)
        light.intensity = CGFloat(300)
        self.scene.rootNode.addChildNode(lightNode)
        //Create light 2
        let light2 = SCNLight()
        let light2Node = SCNNode()
        light2.type = SCNLight.LightType.omni
        light2Node.position = SCNVector3(x: 1.5, y: 50, z: 1.5)
        light2.intensity = CGFloat(1700) //700
        light2Node.light = light2
        self.scene.rootNode.addChildNode(light2Node)
        //Create light 3
        let light3 = SCNLight()
        let light3Node = SCNNode()
        light3.type = SCNLight.LightType.omni
        light3Node.position = SCNVector3(x: 1.5, y: 1.5, z: 50)
        light3.intensity = CGFloat(400)
        light3Node.light = light3
        self.scene.rootNode.addChildNode(light3Node)
        //Create light 4
        let light4 = SCNLight()
        let light4Node = SCNNode()
        light4.type = SCNLight.LightType.omni
        light4Node.position = SCNVector3(x: 1.5, y: 1.5, z: -50)
        light4.intensity = CGFloat(400)
        light4Node.light = light4
        self.scene.rootNode.addChildNode(light4Node)
        //Create light 5
        let light5 = SCNLight()
        let light5Node = SCNNode()
        light5.type = SCNLight.LightType.ambient
        light5Node.position = SCNVector3(x: 1.5, y: -50, z: 1.5)
        light5.intensity = CGFloat(200)
        light5Node.light = light5
        self.scene.rootNode.addChildNode(light5Node)

    }

    /**
     This creates the pain slider used within the GUI.
    */
    func createSlider() {
        slider.frame = CGRect(x: self.view.center.x - 125, y: UIScreen.main.bounds.height * 0.85, width: 250, height: 20)
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        self.view.addSubview(slider)
    }

    @objc func sliderDidEndSliding(notification: NSNotification) {
        displayAlertDialog(image: nil, node: nil, url: nil, fatigue: true, fatigueLevel: slider.value)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkStatus()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    func checkStatus() {
        if hasLoaded == false {
            hasLoaded = true
            updateQueue.async { [weak self] in
                self?.loadScene()
            }
        }
    }

    @objc func swapAction() {
        if(manMesh.node.isHidden) {
            manMesh.node.isHidden = false
        } else {
            manMesh.node.isHidden = true
        }
    }


    //Adapted from stack overflow
    @objc func sceneZoom(gesture: UIPinchGestureRecognizer) {
        let node = cameraNode
        let scale = gesture.velocity
        let maximumFOV: CGFloat = 35 //This is what determines the farthest point you can zoom in to
        let minimumFOV: CGFloat = 60 //This is what determines the farthest point you can zoom out to

        switch gesture.state {
        case .began:
            break
        case .changed:
            node!.camera!.fieldOfView = node!.camera!.fieldOfView - CGFloat(scale)
            if node!.camera!.fieldOfView <= maximumFOV {
                node!.camera!.fieldOfView = maximumFOV
            }
            if node!.camera!.fieldOfView >= minimumFOV {
                node!.camera!.fieldOfView = minimumFOV
            }
            break
        default: break
        }
    }

    // Allows the user to rotate the camera around the object
    // Adapted from stack overflow.
    @objc private func scenePannedOneFinger(recognizer: UIPanGestureRecognizer) {
        recognizer.maximumNumberOfTouches = 1

        if(recognizer.numberOfTouches == 1) {
            let translation = recognizer.translation(in: recognizer.view!) // let panResults = scnView
            let cameraOrbit = cameraNode
            //camera = SCNCamera()

            let currentPivot = cameraOrbit!.pivot
            let changePivot = SCNMatrix4Invert(cameraOrbit!.transform)
            cameraOrbit!.pivot = SCNMatrix4Mult(changePivot, currentPivot)
            cameraOrbit!.transform = SCNMatrix4Identity
            //translation = sender.translation(in: sender.view!)//panning

            let pan_x = Float(translation.x)
            let pan_y = Float(-translation.y)

            let anglePan = sqrt(pow(pan_x, 2) + pow(pan_y, 2)) * (Float)(Double.pi) / 1200 //180.0

            var rotationVector = SCNVector4()
            //rotationVector.x = pan_y
            rotationVector.y = -pan_x
            rotationVector.z = 0
            rotationVector.w = anglePan
            // rotContainer.rotation = rotationVector
            cameraOrbit!.rotation = rotationVector

            if(recognizer.state == UIGestureRecognizerState.ended) {
                let currentPivot = cameraOrbit!.pivot
                let changePivot = SCNMatrix4Invert(cameraOrbit!.transform)
                cameraOrbit!.pivot = SCNMatrix4Mult(changePivot, currentPivot)
                cameraOrbit!.transform = SCNMatrix4Identity
            }
        }
    }

    @objc private func sceneTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)

        //If tapped on background
        if hitResults.count == 0 {
            tapCount += 1
            if tapCount == 2 {
                self.swapAction()
                tapCount = 0;
            }
        } else {
            tapCount = 0
        }

        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            let name = node.name
            //Model is glowing when clicked and should no longer cast shadows.
            if(node.castsShadow) { //wasClicked
                if(name != "man_skele" && name != "Man_Skin2") {
                    node.castsShadow = false
                    displayAlertDialog(image: nil, node: node, url: nil, fatigue: false, fatigueLevel: nil)
                }
            } else {
                if(name != "man_skele" && name != "Man_Skin2") {
                    node.castsShadow = true;
                }
            }
            if(name == "Man_Skin2") {

                let channel = node.geometry!.firstMaterial!.diffuse.mappingChannel
                let texcoord = result.textureCoordinates(withMappingChannel: channel)
                let fileManager = FileManager.default
                let bundleURL = Bundle.main.bundleURL
                let assetURL = bundleURL.appendingPathComponent("hitmaps3.bundle")
                let contents = try! fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)

                let y = 512 - (512 * texcoord.y)
                let x = (512 * texcoord.x)

                for url in contents {

                    let data = try? Data(contentsOf: url)
                    let image = UIImage(data: data!)
                    let point = CGPoint(x: x, y: y)
                    let color = getPixelColor(image!, point)

                    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                    color.getRed(&r, green: &g, blue: &b, alpha: &a)

                    if color.cgColor.alpha == 1 {
                        displayAlertDialog(image: image, node: node, url: url, fatigue: false, fatigueLevel: nil)
                    }
                }
            }
        }
    }


    func displayAlertDialog(image: UIImage?, node: SCNNode?, url: URL?, fatigue: Bool, fatigueLevel: CGFloat?) {
        var bodyPart: String = ""
        //If General Body Area Pain
        if url != nil {
            bodyPart = url!.lastPathComponent
            bodyPart.removeLast(4)

            //If Muscle Pain
        } else if node != nil {
            guard let area = node!.name else { return }
            bodyPart = area

            //If General Fatigue
        } else if fatigue {
            bodyPart = "General Fatigue"
        }

        let popup = setupPopup(fatigue, bodyPart, fatigueLevel, image, node)
        if self.presentedViewController == nil {
            self.present(popup, animated: true, completion: nil)
        }
    }

    /**
        A function that recieves the information entered into the pain or fatigue log,
        and writes it to the database. The structure of the 'document' written to the
        is:
     
        (unique_identifier) {
            date_string : "..."
            month_num : ...
            day_in_month: ...
            time_string : "..."
            type : "..."
            ranking : ...
            notes : "..."
            medsNotes : "..."
        }
     
        Notice the explicit way the month number is stored. This allows us to quickly
        through logs using the month number as an index.
     
        - parameter : rating, a Double representing the level of pain.
        - parameter : notesDescription, a String that may contain extra notes
                      related to the pain/fatigue log.
        - parameter : medsDescritpion, a String that may contain notes about
                      the types of medication taken to manage the pain/fatigue.
        - parameter : area, the actual area/fatigue type.
     */
    func logPainRating(_ rating: Double, _ notesDescription: String, _ medsDescription: String, _ area: String) {
        if rating > 0 {
            let dateF: DateFormatter = DateFormatter()
            dateF.dateFormat = "yyyy-MMM-dd"
            let hoursMins: DateFormatter = DateFormatter()
            hoursMins.dateFormat = "HH:mm:ss"
            let date = Date()
            let dateFull = dateF.string(from: date)
            let dateHoursMins = hoursMins.string(from: date)
         
            if Auth.auth().currentUser != nil, let uid = Auth.auth().currentUser?.uid {
                //NEW WAY
                let painDictionary = ["date_string": dateFull,
                    "month_num": date.month,
                    "day_in_month": date.day,
                    "time_string": dateHoursMins,
                    "type": area,
                    "ranking": rating,
                    "notesDescription": notesDescription.isEmpty ? "" : notesDescription,
                    "medsDescription": medsDescription.isEmpty ? "" : medsDescription] as [String: Any]

                Database.database().reference()
                    .child("pain_log_test")
                    .child(uid)
                    .child(String(date.year))
                    //Firebase will auto generate uniqueID
                    .childByAutoId()
                    .updateChildValues(painDictionary)
            }
        }
    }

    /**
        A convienience method that returns a popup, embedded with the correct type
        of view controller, depending upon if the user is logging general muscle/body
        group pain or fatigue.
     
        - parameter : fatigue, a boolean representing if it is a fatigue log or not.
        - parameter : area, the actual area/fatigue type.
        - parameter : fatigueLevel, the associated fatigue level.
        - parameter : image, the image associated with the area, if relevant .
        - parameter : node: the node associated with the log, if relevant.
        - returns: A PopupDialog with an embedded view controller.
    */
    func setupPopup(_ fatigue: Bool, _ area: String, _ fatigueLevel: CGFloat?, _ image: UIImage?, _ node: SCNNode?) -> PopupDialog {
        var popup: PopupDialog
        if fatigue {
            let fatigueAlert = FatigueAlertDialog()
            fatigueAlert.alertTitle.text = area
            if let level = fatigueLevel {
                fatigueAlert.rating.text = level.rounded().description + " / " + _scale
            }
            popup = PopupDialog.init(viewController: fatigueAlert, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 0, tapGestureDismissal: false, hideStatusBar: false, completion: nil)
        } else {
            let alertDialog = AlertDialog()
            alertDialog.bodyArea.text = area
            popup = PopupDialog.init(viewController: alertDialog, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 0, tapGestureDismissal: false, hideStatusBar: false, completion: nil)
        }

        let buttonOne = CancelButton(title: "DONE", dismissOnTap: true) {

            if popup.viewController is AlertDialog {
                self.handleAlertDialogOnCompletion(popup: popup, area: area, image: image, node: node)
            } else {
                self.handleFatigueAlertDialogOnCompletion(popup: popup, area: area)
            }
        }


        buttonOne.backgroundColor = UIColor(red: 48 / 255, green: 48 / 255, blue: 43 / 255, alpha: 1)
        buttonOne.titleColor = UIColor.white
        buttonOne.separatorColor = UIColor(white: 0.4, alpha: 1)

        let buttonTwo = DefaultButton(title: "CANCEL") {
            self.log.info("User cancelled log")
        }
        buttonTwo.backgroundColor = UIColor(red: 48 / 255, green: 48 / 255, blue: 43 / 255, alpha: 1)
        buttonTwo.titleColor = UIColor(white: 0.6, alpha: 1)
        buttonTwo.separatorColor = UIColor(white: 0.4, alpha: 1)
        popup.addButtons([buttonOne, buttonTwo])
        return popup
    }

    /**
        A method that handles the completion of a user logging a fatigue level.
        It decides after investigating what fields are set, how to log the information
        to the database to avoid storing unecessary data.
     
        - parameter : popup, the PopupDialog being passed in.
        - parameter : area, the fatigue type asociated with the log.
    */
    fileprivate func handleFatigueAlertDialogOnCompletion(popup: PopupDialog, area: String) {

        let fatigueAlertDialog: FatigueAlertDialog = popup.viewController as! FatigueAlertDialog
        let rating = fatigueAlertDialog.getRating()
        let notesDescription = fatigueAlertDialog.getNotesDescription()
        let medsDescription = fatigueAlertDialog.getMedsDescription()

        //if both a note and med description has been set
        if notesDescription.1 && medsDescription.1 {
            self.logPainRating(rating, notesDescription.0, medsDescription.0, area)

            //if only a note has been set
        } else if notesDescription.1 && !medsDescription.1 {
            self.logPainRating(rating, notesDescription.0, "", area)

            //if only a med desription has been set
        } else if !notesDescription.1 && medsDescription.1 {
            self.logPainRating(rating, "", medsDescription.0, area)

            //if nethier a note or med description has been set
        } else {
            self.logPainRating(rating, "", "", area)
        }
    }

    /**
        A method that handles the completion of a user logging a pain level.
        It decides after investigating what fields are set, how to log the
        information to the database to avoid storing unecessary data.
     
        - parameter : popup, the PopupDialog being passed in.
        - parameter : area, the area associated with the log.
        - parameter : image, the image associated with the log.
        - parameter : node, the node associated with the log.
     */
    fileprivate func handleAlertDialogOnCompletion(popup: PopupDialog, area: String, image: UIImage?, node: SCNNode?) {
        let alertDialog: AlertDialog = popup.viewController as! AlertDialog
        let rating = alertDialog.getRating()
        let notesDescription = alertDialog.getNotesDescription()
        let medsDescription = alertDialog.getMedsDescription()

        //if both a note and med description has been set
        if notesDescription.1 && medsDescription.1 {
            self.logPainRating(rating, notesDescription.0, medsDescription.0, area)

            //if only a note has been set
        } else if notesDescription.1 && !medsDescription.1 {
            self.logPainRating(rating, notesDescription.0, "", area)

            //if only a med desription has been set
        } else if !notesDescription.1 && medsDescription.1 {
            self.logPainRating(rating, "", medsDescription.0, area)

            //if nethier a note or med description has been set
        } else {
            self.logPainRating(rating, "", "", area)
        }

        //Flips UVS horizontally
        if image != nil {
            guard let nodeg = node else { return }
            nodeg.geometry?.firstMaterial?.emission.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0);
            nodeg.geometry?.firstMaterial?.emission.contents = image
            nodeg.geometry?.firstMaterial?.emission.intensity = CGFloat(alertDialog.getRating() * 0.2)
        } else {
            guard let nodeg = node else { return }
            nodeg.geometry?.firstMaterial?.emission.contents = UIColor(red: 150 / 255, green: 0.0 / 255, blue: 0 / 255, alpha: 0.5)
            nodeg.geometry?.firstMaterial?.emission.intensity = CGFloat(alertDialog.getRating() * 0.2)
        }
    }

    //Adapted from stack overflow
    func getPixelColor(_ image: UIImage, _ point: CGPoint) -> UIColor {
        let cgImage: CGImage = image.cgImage!
        guard let pixelData = CGDataProvider(data: (cgImage.dataProvider?.data)!)?.data else {
            return UIColor.clear
        }
        let data = CFDataGetBytePtr(pixelData)!
        let x = Int(point.x)
        let y = Int(point.y)
        let index = Int(image.size.width) * y + x
        let expectedLengthA = Int(image.size.width * image.size.height)
        let expectedLengthRGB = 3 * expectedLengthA
        let expectedLengthRGBA = 4 * expectedLengthA
        let numBytes = CFDataGetLength(pixelData)
        switch numBytes {
        case expectedLengthA:
            return UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(data[index]) / 255.0)
        case expectedLengthRGB:
            return UIColor(red: CGFloat(data[3 * index]) / 255.0, green: CGFloat(data[3 * index + 1]) / 255.0, blue: CGFloat(data[3 * index + 2]) / 255.0, alpha: 1.0)
        case expectedLengthRGBA:
            return UIColor(red: CGFloat(data[4 * index]) / 255.0, green: CGFloat(data[4 * index + 1]) / 255.0, blue: CGFloat(data[4 * index + 2]) / 255.0, alpha: CGFloat(data[4 * index + 3]) / 255.0)
        default:
            // unsupported format
            return UIColor.clear
        }
    }

}
