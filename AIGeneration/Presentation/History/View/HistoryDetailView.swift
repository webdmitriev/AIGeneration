//
//  HistoryDetailView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 03.07.2025.
//

import SwiftUI

struct HistoryDetailView: View {
    let image: UIImage
    @State private var showSaveAlert = false
    @State private var saveErrorMessage: String?
    private let photoSaver = PhotoSaver()

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()

            Button(action: saveToPhotoLibrary) {
                Label("Save to Photos", systemImage: "square.and.arrow.down")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .alert(isPresented: $showSaveAlert) {
            if let error = saveErrorMessage {
                return Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
            } else {
                return Alert(title: Text("Success"), message: Text("Image saved to your Photos"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveToPhotoLibrary() {
        photoSaver.onComplete = { error in
            if let error = error {
                // В эмуляторе error.localizedDescription обычно "The operation couldn’t be completed. (OSStatus error -1.)"
                if error.localizedDescription.contains("OSStatus error -1") {
                    saveErrorMessage = "Saving not supported in Simulator."
                } else {
                    saveErrorMessage = error.localizedDescription
                }
            } else {
                saveErrorMessage = nil
            }
            showSaveAlert = true
        }
        photoSaver.save(image)
    }
}


class PhotoSaver: NSObject {
    var onComplete: ((Error?) -> Void)?

    func save(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            self.onComplete?(error)
        }
    }
}
