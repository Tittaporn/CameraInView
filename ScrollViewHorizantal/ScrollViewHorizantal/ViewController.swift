//
//  ViewController.swift
//  ScrollViewHorizantal
//
//  Created by M3ts LLC on 10/7/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var imageViewPhotoTaken: UIImageView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnTakePhoto: UIButton!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var horizontalScroll: UIStackView!
    
    // MARK: - Properties
    let imagePicker = UIImagePickerController()
    let lableText = ["Photo 1","Photo 2","Photo 3","Photo 4","Photo 5"]
    var contenWidth: CGFloat = 0.0
    var index = 0
    var currentTakenPhoto = -1
    let image1: UIImage = {
        let image = UIImage(systemName: "1.circle")
        return image ?? UIImage()
    }()
    let image2: UIImage = {
        let image = UIImage(systemName: "2.circle")
        return image ?? UIImage()
    }()
    let image3: UIImage = {
        let image = UIImage(systemName: "3.circle")
        return image ?? UIImage()
    }()
    let image4: UIImage = {
        let image = UIImage(systemName: "4.circle")
        return image ?? UIImage()
    }()
    let image5: UIImage = {
        let image = UIImage(systemName: "5.circle")
        return image ?? UIImage()
    }()
    var imagesToDisplay: [UIImage] = []
    var photosToDisplay: [UIImage] = []
    var captureSession : AVCaptureSession!
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var videoOutput : AVCaptureVideoDataOutput!
    var takePicture = false
    var backCameraOn = true
    var newPhotoTaken: UIImage? {
        didSet {
            previewLayer.isHidden = true
            updateCurrentPhoto(currentPhoto: newPhotoTaken)
        }
    }
}

extension ViewController {
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setupViews()
        imagesToDisplay = [image1,image2,image3,image4,image5]
        for image in imagesToDisplay {
            if let photoView = Bundle.main.loadNibNamed("PhotosView", owner: nil, options: nil)!.first as? PhotoView {
                photoView.translatesAutoresizingMaskIntoConstraints = false
                photoView.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
                photoView.lbl.text = lableText[index]
                let anImageToDisplay = image
                photoView.img.image = anImageToDisplay
                if photosToDisplay.count == 1 {
                    photoView.img.image = photosToDisplay[0]
                }
                photoView.delegate = self
                horizontalScroll.backgroundColor = .red
                horizontalScroll.addArrangedSubview(photoView)
                contenWidth += photoView.frame.width + 100
                index += 1
            }
        }
        scrollView.contentSize = CGSize(width: contenWidth, height: view.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermissions()
        setupAndStartCaptureSession()
    }
    
    // MARK: - Actions
    @IBAction func photoButtonTapped(_ sender: Any) {
        print("I am about to taking photo.")
        // openCamera()
       // switchCameraInput()
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        print("I am about to taking photo.")
        takePicture = true
        // openCamera()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        currentTakenPhoto += 1
        updatePhotoViews(currentIndex: currentTakenPhoto)
        previewLayer.isHidden = false
    }
    
    // MARK: - Helper Functions
    func setupViews() {
        scrollView.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingTop: 50, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height / 5)
        horizontalScroll.anchor(top: scrollView.topAnchor, bottom: scrollView.bottomAnchor, leading: scrollView.leadingAnchor, trailing: scrollView.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0,height: scrollView.frame.height)
        index = 0
    }
    
    func updatePhotoViews(currentIndex: Int) {
        if currentIndex < 5 {
            let photoToHide = horizontalScroll.arrangedSubviews[currentIndex]
            horizontalScroll.removeArrangedSubview(photoToHide)
            if let newPhotoView = Bundle.main.loadNibNamed("PhotosView", owner: nil, options: nil)!.first as? PhotoView {
                newPhotoView.translatesAutoresizingMaskIntoConstraints = false
                newPhotoView.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
                newPhotoView.lbl.text = lableText[currentIndex]
                newPhotoView.img.image = imageViewPhotoTaken.image//photosToDisplay[currentIndex]
                newPhotoView.delegate = self
                
                horizontalScroll.insertArrangedSubview(newPhotoView, at: currentIndex)
            }
        } else {
            print("Index out of range, we took all photos that needed")
        }
    }
}

// MARK: -  UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        // we check if camera is source, then present imagePicker.
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else { //Camera Source is not available.
            let alert = UIAlertController(title: "No camera access", message: "Plese allow access to the Camera to use this feature", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageViewPhotoTaken.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Delegate
extension ViewController: PhotoViewDelegate {
    func updatePhotoData(image: UIImageView, text: String) {
        print("I am tapping the photo")
        previewLayer.isHidden = true
        imageViewPhotoTaken.image = image.image
        print(text)
    }
}

// MARK: - Camera in the view
extension ViewController {
    func updateCurrentPhoto(currentPhoto: UIImage?) {
        if let newPhoto = currentPhoto {
            imageViewPhotoTaken.image = newPhoto
        }
    }
    
    //MARK:- Permissions
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            return
        case .denied:
            abort()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (authorized) in
                if (!authorized) {
                    abort()
                }
            })
        case .restricted:
            abort()
        @unknown default:
            fatalError()
        }
    }
    
    //MARK:- Camera Setup
    func setupAndStartCaptureSession(){
        DispatchQueue.global(qos: .userInitiated).async{
            //init session
            self.captureSession = AVCaptureSession()
            //start configuration
            self.captureSession.beginConfiguration()
            //session specific configuration
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            //setup inputs
            self.setupInputs()
            DispatchQueue.main.async {
                //setup preview layer
                self.setupPreviewLayer()
            }
            //setup output
            self.setupOutput()
            //commit configuration
            self.captureSession.commitConfiguration()
            //start running it
            self.captureSession.startRunning()
        }
    }
    
    func setupInputs(){
        //get back camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            //handle this appropriately for production purposes
            fatalError("no back camera")
        }
        //get front camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            fatalError("no front camera")
        }
        //now we need to create an input objects from our devices
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("could not create input device from back camera")
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            fatalError("could not add back camera input to capture session")
        }
        
        guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("could not create input device from front camera")
        }
        frontInput = fInput
        if !captureSession.canAddInput(frontInput) {
            fatalError("could not add front camera input to capture session")
        }
        //connect back camera input to session
        captureSession.addInput(backInput)
    }
    
    func setupOutput(){
        videoOutput = AVCaptureVideoDataOutput()
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("could not add video output")
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
    }
    
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.insertSublayer(previewLayer, below: btnPhoto.layer)
        
        previewLayer.frame = imageViewPhotoTaken.layer.frame//self.view.layer.frame
    }
    
    func switchCameraInput(){
        //don't let user spam the button, fun for the user, not fun for performance
        //  switchCameraButton.isUserInteractionEnabled = false
        //reconfigure the input
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCameraOn = true
        }
        //deal with the connection again for portrait mode
        videoOutput.connections.first?.videoOrientation = .portrait
        //mirror the video stream for front camera
        videoOutput.connections.first?.isVideoMirrored = !backCameraOn
        //commit config
        captureSession.commitConfiguration()
        //acitvate the camera button again
        // switchCameraButton.isUserInteractionEnabled = true
    }
    
    //MARK:- Actions
    @objc func captureImage(_ sender: UIButton?){
        takePicture = true
    }
    
    @objc func switchCamera(_ sender: UIButton?){
        switchCameraInput()
    }
}
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !takePicture {
            return //we have nothing to do with the image buffer
        }
        
        //try and get a CVImageBuffer out of the sample buffer
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        //get a CIImage out of the CVImageBuffer
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        //get UIImage out of CIImage
        let uiImage = UIImage(ciImage: ciImage)
        
        DispatchQueue.main.async {
            // self.capturedImageView.image = uiImage
            self.newPhotoTaken = uiImage
            // self.imageViewPhotoTaken.image = uiImage
            self.takePicture = false
            // self.captureSession.stopRunning()
        }
    }
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingBottom: CGFloat, paddingLeft: CGFloat, paddingRight: CGFloat, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: paddingRight).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIStackView {
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
}
