import SwiftUI
import CoreML

struct GameContentView: View {
    let floor: Floor // selected floor
    @State private var currentArtWork: ArtWork? = nil // art work to guess
    @State private var showHint: Bool = false // true if the player wants a hint
    @State private var hintTimer: Timer? = nil // timer for showing the hint
    let hintTimeInterval: TimeInterval = 15 // specifies after how much time the hint will be shown
    @State private var showCamera: Bool = false // true if the user opens the camera
    @State private var capturedImage: UIImage? = nil // image captured by the camera
    @State private var showArtWork: Bool = false // true if the user has guessed the art work
    @State private var notGuessedMessage: Bool = false // true if the solution isn't correct
    let model = try! PaintingClassifier(configuration: MLModelConfiguration()) // gets the machine learning model to analyze user's images
    @State var label: String = "" // model's prediction
        
    var body: some View {
        VStack {
            if currentArtWork != nil { // checks if there are not already seen art works
                Text("Indovinello") // displays the riddle of the art work to find
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                Text((currentArtWork!.riddle))
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                Spacer()
                if (showHint) { // if the timer has expired
                    Text("Indizio") // displays the hint
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
                        .transition(.slide)
                    Text(currentArtWork!.hint)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .transition(.slide)
                }
                Spacer()
                Button(action: { // button to press if the user wants to try to guess the art worl
                    self.showCamera.toggle() // opens the camera
                }) {
                    Text("Indovina")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal, 50)
                        .padding(.bottom, 10)
                }
                .padding(.bottom, 50)
                .sheet(isPresented: $showCamera, onDismiss: {
                    classify() // classifies the image using the machine learning model
                }) {
                    ImagePicker(image: self.$capturedImage)
                }
                .fullScreenCover(isPresented: $showArtWork, onDismiss: { // shows art work's details
                    currentArtWork = getRandomArtWork() // get an another art work
                    showHint = false // hides the hint
                    hintTimer?.invalidate() // restarts the timer
                    hintTimer = Timer.scheduledTimer(withTimeInterval: hintTimeInterval, repeats: false) { _ in
                        withAnimation {
                            self.showHint = true
                        }
                    }
                }) {
                    if let currentArtWork = currentArtWork { // shows currentArtWork's details if it isn't nil
                        VStack {
                            ArtWorkContentView(artWork: currentArtWork)
                            Button(action: {
                                showArtWork = false // Chiude la pagina di informazioni del quadro
                            }) {
                                Text("Prossimo Indovinello")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .padding(.horizontal, 50)
                            }
                        }
                    }
                }
            } else { // if all of the paintings of the floor have been guessed
                VStack(spacing: 20) {
                    Spacer()
                    Text("🎉 Congratulazioni! Hai scoperto tutti i quadri del piano! 🎉")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                        .multilineTextAlignment(.center)
                    Text("Clicca sul pulsante per rimetterti alla prova su questo piano o torna alla Home per selezionarne un altro.")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button(action: { // button to reset all artworks of the floor
                        resetArtworks() // resets all the artworks on the floor
                    }) {
                        Text("Rimettiti alla prova")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.horizontal, 50)
                            .padding(.bottom, 50)
                    }
                }
                .padding()
            }

        }
        .onAppear { // sets the timer to show the hint
            hintTimer = Timer.scheduledTimer(withTimeInterval: hintTimeInterval, repeats: false) { _ in
                withAnimation {
                    self.showHint = true
                }
            }
            self.currentArtWork = getRandomArtWork() // gets a random art work from not already seen ones
        }
        .onDisappear { // disables the timer
            hintTimer?.invalidate()
            hintTimer = nil
        }
        .alert(isPresented: Binding( // shows an alert if the user's solution is wrong
            get: {
                notGuessedMessage && capturedImage != nil
            },
            set: { _ in })) {
            Alert(
                title: Text("Ops!"),
                message: Text("La tua risposta non è corretta. Non ti preoccupare, puoi sempre riprovare!"),
                primaryButton: .default(Text("Riprova")) { // button to retry
                    notGuessedMessage = false // hides the alert
                    capturedImage = nil // clears the captured image
                    showCamera.toggle() // opens the camera
                },
                secondaryButton: .cancel(Text("Annulla")) { // button to undo
                    capturedImage = nil // clears the captured image
                }
            )
        }
    }
    
    func getRandomArtWork() -> ArtWork? {
        let unguessedArtWorks = floor.artWorks.filter {!$0.guessed} // get each not already guessed floor's artwork
        if !unguessedArtWorks.isEmpty { // if there are not already seen artworks
            let randomArtWorkIndex = Int.random(in: 0..<unguessedArtWorks.count)
            let randomArtWork = unguessedArtWorks[randomArtWorkIndex]
            return randomArtWork
        }
        return nil // returns nil if the user has seen every artwork
    }
    
    func resetArtworks() { // sets all artworks on the floor as not guessed
        for index in 0..<floor.artWorks.count {
            floor.artWorks[index].guessed = false
        }
        currentArtWork = getRandomArtWork() // starts again with a new artwork
    }
    
    func classify() { // predicts which art works is contained in user's photo
        if capturedImage != nil { // if there is an image to analyze
            let pixelBuffer = convert(uiimage: capturedImage!) // converts the image in a correct format
            guard let prediction = try? model.prediction(image: pixelBuffer!) // gets model's prediction
            else {
                return
            }
            label = "\(prediction.target)" // gets the prediction
            if label == currentArtWork!.title { // if the user has guessed
                capturedImage = nil // clear the image
                currentArtWork?.guessed = true // sets the artwork as guessed
                self.showArtWork = true
            } else { // if the user hasn't guessed
                notGuessedMessage = true // shows the alert
            }
        }
    }

    func convert(uiimage:UIImage) -> CVPixelBuffer? { // converts the taken photo
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 360, height: 360), true, 2.0)
        uiimage.draw(in: CGRect(x: 0, y: 0, width: 360, height: 360))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //Converting the image to a CVPixelBuffer, an image buffer which holds the pixels in the main memory
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        //We then take all the pixels present in the image and convert them into a device-dependent RGB color space
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        //we make the graphics context into the current context, and render the image
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
}
