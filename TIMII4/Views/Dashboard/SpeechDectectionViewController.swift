//
//  SpeechDectectionViewController.swift
//  TIMII4
//
//  Created by Dennis Huang on 1/24/19.
//  Copyright © 2019 Autonomii. All rights reserved.
//
// Note: 1.24.19 -  Step 9....https://medium.com/ios-os-x-development/speech-recognition-with-swift-in-ios-10-50d5f4e59c48
// TODO: 1.27.19 - Crashing on recognizing speech.


import UIKit
import Speech

class SpeechDectectionViewController: UIViewController, SFSpeechRecognizerDelegate
{
    // Class variables
    var detectedTextLabel = UILabel()
    let startStopButtonLabel = UILabel()
    var speechButton = UIButton()
    var isRecording = false

    /// Speech audio recognition variables
    let audioEngine = AVAudioEngine()                                   // works with ther MIC
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()    // does the speech recognition
    var recognitionRequest : SFSpeechAudioBufferRecognitionRequest?     // holds the recognized speech
    var recognitionTask: SFSpeechRecognitionTask?                       // used to manage, cancel recognition task
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
        self.view.backgroundColor = .white
        
        // MARK: Add Visual Elements to Screen
        self.view.addSubview(startStopButtonLabel.make( x: 50, y: 100, w: 300, h: 100,
                                                        txt: "Tap button to start voice recognition.",
                                                        align: .center,
                                                        fnt: UIFont(name: "HelveticaNeue", size: 20)!,
                                                        fntColor: UIColor.black,
                                                        backColor: UIColor.transparent,
                                                        lines: 1))

        self.view.addSubview(speechButton.make(x: 50, y: 250, w: 300, h: 100,
                                               title: "Start / Stop", backColor: .red,
                                               target: self,
                                               touchUp: #selector(didTapSpeechButton)))
        
        self.view.addSubview(detectedTextLabel.make( x: 50, y: 400, w: 300, h: 100,
                                                     txt: "Detect Text Label",
                                                     align: .center,
                                                     fnt: UIFont(name: "HelveticaNeue", size: 20)!,
                                                     fntColor: UIColor.black,
                                                     backColor: UIColor.gray,
                                                     lines: 5))
        detectedTextLabel.adjustsFontSizeToFitWidth = false
        
    }

    /// This button is the toggle for Starting and Stopping the Speech Recognition function
    @objc func didTapSpeechButton()
    {
        if isRecording == true {
            print("--> Stop Recording.")
            recognitionRequest?.endAudio()  // Mark end of recording
            audioEngine.stop()
            let node = audioEngine.inputNode
            node.removeTap(onBus: 0)
            recognitionTask?.cancel()
            self.recognitionTask = nil  // added
            isRecording = false
            speechButton.backgroundColor = UIColor.red
        } else {
            print("--> Start Recording.")
            
            // Cancel the previous task if it's running.
            if let recognitionTask = recognitionTask {
                recognitionTask.cancel()
                self.recognitionTask = nil
            }
            
            self.recordAndRecognizeSpeech()
            isRecording = true
            speechButton.backgroundColor = UIColor.gray
        }
    }
    
    
    /// The method that will perform the speech recognition. It will record and process the speech as it comes in.
    private func recordAndRecognizeSpeech()
    {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print (error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else
        {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        
        if !myRecognizer.isAvailable
        {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            return
        }
        
        // This resets the recognitionRequest each time so "...cannot be re-use..." error is avoided.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }

        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler:
        { result, error in
            if result != nil
            {
                if let result = result
                {
                    let bestString = result.bestTranscription.formattedString
                    self.detectedTextLabel.text = bestString
                }
                
                else if let error = error
                {
                    self.sendAlert(message: "There has been a speech recognition error.")
                    print(error)
                }
            }
        })
    }
    
    
    /// Another useful functionality is to be able to check for speech recognition authorization any time from anywhere in your app.
    /// If, for any reason, speech recognition is not available, you want to be able to check for it at will, and keep your user from
    /// accessing functionality that won’t make sense without it. It’s useful for enabling or disabling buttons or UI that relate to
    /// your purpose for using speech recognition.
    private func requestSpeechAuthorization()
    {
        SFSpeechRecognizer.requestAuthorization
        { authStatus in
            
            OperationQueue.main.addOperation
            {
                switch authStatus {
                
                case .authorized:   self.startStopButtonLabel.isEnabled = true
    
                case .denied:       self.startStopButtonLabel.isEnabled = false
                                    self.detectedTextLabel.text = "User denied access to speech recognition."
                
                case .restricted:   self.startStopButtonLabel.isEnabled = false
                                    self.detectedTextLabel.text = "Speech recognition restricted on this device."
                    
                case .notDetermined:self.startStopButtonLabel.isEnabled = false
                                    self.detectedTextLabel.text = "Speech recognition not yet authorized."
                    
                }
            }
        }
    }
    
    
    
}


extension UILabel
{
    /// A simple UILabel factory function.
    ///
    /// Returns instance of itself configured with the given parameters
    ///
    /// Example:
    /// self.view.addSubview(UILabel().make(x: 0, y: 0, w: 100, h: 30,
    ///                                   txt: "Hello World!",
    ///                                 align: .center,
    ///                                   fnt: aUIFont,
    ///                              fntColor: UIColor.red))
    ///
    func make(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat,
              txt: String,
              align: NSTextAlignment,
              fnt: UIFont,
              fntColor: UIColor,
              backColor: UIColor,
              lines: Int ) -> UILabel
    {
        frame = CGRect(x: x, y: y, width: w, height: h)
        adjustsFontSizeToFitWidth = true
        textAlignment = align
        text = txt
        font = fnt
        textColor = fntColor
        backgroundColor = backColor
        numberOfLines = lines

        return self
    }
}

extension UIButton
{
    /// UIButton factory returns instance of UIButton.
    ///
    /// Example:
    /// self.view.addSubview(UIButton().make(x: btnx, y:100, w: btnw, h: btnh,
    ///                                      title: "play", backColor: .red,
    ///                                      target: self,
    ///                                      touchDown: #selector(play), touchUp: #selector(stopPlay)))
    ///
    func make(x: CGFloat,y: CGFloat,
              w: CGFloat,h: CGFloat,
              title: String, backColor: UIColor,
              target: UIViewController,
              touchUp: Selector ) -> UIButton 
    {
        frame = CGRect(x: x, y: y, width: w, height: h)
        backgroundColor = backColor
        setTitle(title, for: .normal)
        addTarget(target, action: touchUp  , for: .touchUpInside)
        addTarget(target, action: touchUp  , for: .touchUpOutside)
        
        return self
    }
}

extension SpeechDectectionViewController
{
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
