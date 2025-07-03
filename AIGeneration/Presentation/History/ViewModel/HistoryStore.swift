//
//  HistoryStore.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 03.07.2025.
//

import SwiftUI

final class HistoryStore: ObservableObject {
    @Published var images: [UIImage] = []

    private let imagesDirectoryName = "GeneratedImages"
    private let indexKey = "historyImagesIndex"
    
    private var filenames: [String] = []

    init() {
        loadHistory()
    }

    func addImage(_ image: UIImage) {
        images.append(image)
        saveImageToDisk(image)
    }
    
    // MARK: - Удаляем картинку с диска и обновляем индекс
    func deleteImage(at index: Int) {
        guard index >= 0 && index < images.count else { return }
        
        // Удаляем файл с диска
        let filenameToDelete = filenames[index]
        let fileURL = imagesDirectoryURL.appendingPathComponent(filenameToDelete)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Ошибка удаления файла: \(error)")
        }
        
        // Удаляем из массивов
        images.remove(at: index)
        filenames.remove(at: index)
        
        // Обновляем индекс в UserDefaults
        UserDefaults.standard.set(filenames, forKey: indexKey)
    }

    // MARK: - Сохраняем картинку на диск и обновляем индекс
    private func saveImageToDisk(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        
        let filename = UUID().uuidString + ".jpg"
        let url = imagesDirectoryURL.appendingPathComponent(filename)
        
        do {
            try FileManager.default.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: true)
            try data.write(to: url)
            filenames.append(filename)
            UserDefaults.standard.set(filenames, forKey: indexKey)
        } catch {
            print("Ошибка сохранения изображения: \(error)")
        }
    }

    // MARK: - Сохраняем список имён файлов в UserDefaults
    private func saveIndex(filename: String) {
        var currentIndex = UserDefaults.standard.stringArray(forKey: indexKey) ?? []
        currentIndex.append(filename)
        UserDefaults.standard.set(currentIndex, forKey: indexKey)
    }

    // MARK: - Загружаем историю из UserDefaults и диска
    private func loadHistory() {
        filenames = UserDefaults.standard.stringArray(forKey: indexKey) ?? []
        
        var loadedImages: [UIImage] = []
        for filename in filenames {
            let fileURL = imagesDirectoryURL.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: fileURL),
               let image = UIImage(data: data) {
                loadedImages.append(image)
            }
        }
        
        images = loadedImages
    }

    // MARK: - Путь к папке с изображениями
    private var imagesDirectoryURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(imagesDirectoryName)
    }
}
