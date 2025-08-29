//
//  CaptureSequenceView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 6/8/25.
//

import SwiftUI
import AVFoundation

struct CaptureSequenceView: View {
    init(sequence: LapseSequence, onSaveSequence: ((LapseSequence) -> Void)? = nil) {
        _recorder = .init(wrappedValue: .init(sequence: sequence))
        self.onSaveSequence = onSaveSequence
    }
    
    var onSaveSequence: ((LapseSequence) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var recorder: Recorder
    
    @State var imageData: Data?
    
    var body: some View {
        NavigationStack {
            VStack {
                CameraPreview(session: $recorder.session)
                    .frame(height: 400)
                HStack {
                    Button(action: {
                        recorder.startRecording()
                    }, label: {
                        Text("Start Recording")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    })
                    
                    Button(action: {
                        recorder.stopRecording()
                    }, label: {
                        Text("Stop Recording")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    })
                }
                
                if recorder.isRecording {
                    Text("Recording...")
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .navigationTitle("Nueva grabación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        recorder.stopRecording()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        recorder.stopRecording()
                        onSaveSequence?(recorder.sequence)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @Binding var session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.session = session
            layer.frame = uiView.bounds
        }
    }
}

class Recorder: NSObject, ObservableObject {
    let sequence: LapseSequence
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    
    private let photoOutput = AVCapturePhotoOutput()
    private var timer: Timer?
    private var timeInterval: TimeInterval = 0.5
    
    init(sequence: LapseSequence) {
        self.sequence = sequence
        super.init()
        
        addVideoInput()
        addPhtotOutput()
 
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    private func addVideoInput() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        if session.canAddInput(input) {
            session.addInput(input)
        }
    }
    
    private func addPhtotOutput() {
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }
    
    func startRecording() {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(takePhoto), userInfo: nil, repeats: true)
    }
    
    @objc
    func takePhoto() {
        photoOutput.capturePhoto(with: .init() /*TODO: Revisar este settings*/ , delegate: self)
    }
    
    func stopRecording() {
        timer?.invalidate()
        timer = nil
    }
}

extension Recorder: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("Error al procesar la foto: \(error.localizedDescription)")
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            print("No se pudo obtener la representación de los datos de la imagen")
            return
        }
        
        do {
            let capture = try CustomFileManager.shared.savePhoto(data, to: sequence)
            sequence.addCapture(capture)
        } catch {
            print("❌ Error al guardar la imagen: \(error.localizedDescription)")
        }
    }
}
