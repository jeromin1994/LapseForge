//
//  PHVideoPicker.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 21/8/25.
//

import SwiftUI
import PhotosUI

struct PHVideoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onPicked: (URL) -> Void
    var onProgress: ((Double) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, onPicked: onPicked, onProgress: onProgress)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                // no-op, solo fuerza el diálogo la primera vez
            }
        }
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .videos
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current   // no fuerza copia
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var isPresented: Bool
        let onPicked: (URL) -> Void
        let onProgress: ((Double) -> Void)?
        
        init(isPresented: Binding<Bool>, onPicked: @escaping (URL) -> Void, onProgress: ((Double) -> Void)?) {
            self._isPresented = isPresented
            self.onPicked = onPicked
            self.onProgress = onProgress
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let first = results.first, let id = first.assetIdentifier else {
                isPresented = false
                return
            }
            
            // Resolver PHAsset → AVAsset (sin copiar el fichero)
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
            guard let phAsset = assets.firstObject else {
                isPresented = false
                return
            }
            
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            options.progressHandler = { progress, _, _, _ in
                DispatchQueue.main.async {
                    self.onProgress?(progress)
                }
            }
            
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { avAsset, _, _ in
                DispatchQueue.main.async {
                    self.isPresented = false
                    if let urlAsset = avAsset as? AVURLAsset {
                        self.onPicked(urlAsset.url)   // URL del vídeo original (sin copia)
                    }
                }
            }
        }
    }
}
