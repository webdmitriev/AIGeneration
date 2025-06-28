//
//  EnvLoader.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 29.06.2025.
//

import Foundation

struct Env {
    private var values: [String: String] = [:]
    
    init() {
        loadEnv()
    }
    
    private mutating func loadEnv() {
        guard let url = Bundle.main.url(forResource: ".env", withExtension: nil) else {
            print("❌ .env not found in bundle")
            return
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty || trimmed.hasPrefix("#") {
                    continue
                }
                let parts = trimmed.components(separatedBy: "=")
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    values[key] = value
                }
            }
        } catch {
            print("❌ Failed to read .env: \(error)")
        }
    }
    
    func get(_ key: String) -> String? {
        return values[key]
    }
}

