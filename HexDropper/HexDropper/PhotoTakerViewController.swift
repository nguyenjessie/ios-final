//
//  ViewController.swift
//  HexDropper
//
//  Created by Kenny Yeung on 4/11/18.
//  Copyright © 2018 Kenny + Jessie. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoTakerViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var imageViewOverlay: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var color: UILabel!
    @IBOutlet weak var tapInstruct: UILabel!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    public struct RGBAPixel {
        public var raw: UInt32
        public var red: UInt8 {
            get {return UInt8(raw & 0xFF) }
        }
        public var green: UInt8 {
            get {return UInt8(raw & 0xFF00) >> 8 }
        }
        public var blue: UInt8 {
            get {return UInt8(raw & 0xFF0000) >> 16 }
        }
    }
    
    // The image to analyze
    var selectedImage = UIImage()

    var captureSession: AVCaptureSession?
    
    // the device we are capturing media from
    var captureDevice : AVCaptureDevice?
    
    // view that will let us preview what is being captured from our input
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // used to capture a single photo from our capture device
    var photoOutput: AVCapturePhotoOutput? = nil
    
    //data
    var data: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession = AVCaptureSession()
        
        createAndLayoutPreviewLayer(fromSession: captureSession)
        configureCaptureSession(forDevicePosition: .unspecified)
        
        captureSession?.startRunning()
        
        toggleUI(isInPreviewMode: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide the navigation bar while we are in this view
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureCaptureSession(forDevicePosition devicePostion: AVCaptureDevice.Position) {
        guard let captureSession = captureSession else {
            print("captureSession has not been initialized")
            return
        }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        guard let capDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            print("No available capture devices.")
            return
        }
        
        var input: AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: capDevice)
        } catch {
            print("blah")
        }
        
        do {
            photoOutput = AVCapturePhotoOutput()
            let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
            
        } catch {
            
        }
        
        do {
            captureSession.addInput(input!)
            captureSession.addOutput(photoOutput!)
        }
        catch {
            print(error.localizedDescription)
        }
    }

    func createAndLayoutPreviewLayer(fromSession session: AVCaptureSession?) {
        
        if let unwrapSession = session {
            previewLayer = AVCaptureVideoPreviewLayer(session: unwrapSession)
        }
        
        guard let previewLayer = previewLayer else {
            print("previewLayer hasn't been initialized yet!")
            return
        }
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.layer.frame
        previewLayer.zPosition = -1
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        data = photo.fileDataRepresentation()
        if let uiImage = UIImage(data: data!) {
            selectedImage = uiImage
            toggleUI(isInPreviewMode: true)
        }
    }
    
    @IBAction func takePhotoButtonWasPressed(_ sender: UIButton) {
        
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        
        photoOutput?.capturePhoto(with: photoSettings, delegate: self)
        
        toggleUI(isInPreviewMode: true)
        
    }
    
    /// Switch between front and back camera
//    @IBAction func flipCameraButtonWasPressed(_ sender: UIButton) {
        // TODO: allow user to switch between front and back camera.
        // you will need to remove all of your inputs from
        // your capture session before switching cameras
        
    //}
    
    @IBAction func cancelButtonWasPressed(_ sender: UIButton) {
        selectedImage = UIImage()
        toggleUI(isInPreviewMode: false)
    }
    
    func toggleUI(isInPreviewMode: Bool) {
        if isInPreviewMode {
            imageViewOverlay.image = selectedImage
            takePhotoButton.isHidden = true
            //sendButton.isHidden = false
            cancelButton.isHidden = false
            //flipCameraButton.isHidden = true
            tapInstruct.isHidden = false
            tapGesture.isEnabled = true
            color.isHidden = false
        }
        else {
            takePhotoButton.isHidden = false
            //sendButton.isHidden = true
            cancelButton.isHidden = true
            imageViewOverlay.image = nil
            //flipCameraButton.isHidden = false
            tapInstruct.isHidden = true
            tapGesture.isEnabled = false
            color.isHidden = true
            color.text = ""
        }
    }
    
    var point: CGPoint? = nil
    
//    func getLocation(view: UIImageView, touch: UITouch) {
//        point = touch.location(in: touch)
//    }
    
    func getColor(view: UIImageView, point: CGPoint) {
    
        let pixelData = self.selectedImage.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
        let pixelInfo: Int = ((Int(self.selectedImage.size.width) * Int(point.y)) + Int(point.x)) * 4
            
            let r = CGFloat(data[pixelInfo])
            let g = CGFloat(data[pixelInfo+1])
            let b = CGFloat(data[pixelInfo+2])
            let a = CGFloat(data[pixelInfo+3])
        
            print(UIColor(red: r, green: g, blue: b, alpha: a))
            color.text = String(describing: UIColor(red: r, green: g, blue: b, alpha: a))
            color.textColor = UIColor(red: r, green: g, blue: b, alpha: a)
        
    }
    
    @IBAction func pixelTap(_ sender: Any) {
        print("image tapped")
        //point = getLocation(view: imageViewOverlay, touch: imageViewOverlay.center)
        point = imageViewOverlay.center
        getColor(view: imageViewOverlay, point: point!)
    }
    
    @IBAction func unwindToImagePicker(segue: UIStoryboardSegue) {
        toggleUI(isInPreviewMode: false)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        navigationController?.navigationBar.isHidden = false
//        let destination = segue.destination as! ChooseThreadViewController
//        destination.chosenImage = selectedImage
//        toggleUI(isInPreviewMode: false)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ColorPickerViewController
        destination.image.image = selectedImage
    }
}

