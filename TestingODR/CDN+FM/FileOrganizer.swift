//
//  FileOrganizer.swift
//  TestingODR
//
//  Created by Ghani's Mac Mini on 20/09/2023.
//

import Foundation

final class FileOrganizer {
    static var documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    /// Reads a file from the document directory with the specified `fileName`.
    ///
    /// - Parameter fileName: The name of the file to be read.
    /// - Returns: A URL representing the file's location if it exists, or `nil` if not found.
    static func readFile(for fileURL: URL) -> Data? {
        return FileManager.default.contents(atPath: fileURL.absoluteString)
    }
    
    static func isExist(for fileURL: URL?) -> Bool {
        guard let fileURL else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    /// Saves a file from the given `url` to the document directory with the specified `fileName`.
    ///
    /// - Parameters:
    ///   - url: The source URL of the file to be saved.
    ///   - fileName: The name of the file to be saved as.
    static func saveFile(from url: URL, fileName: URL) throws {
        guard let fileData = try? Data(contentsOf: url) else {
            return
        }
        
        try fileData.write(to: fileName)
    }
    
    /// Deletes a file with the specified `fileName` from the document directory.
    ///
    /// - Parameter fileName: The name of the file to be deleted.
    static func deleteFile(for fileURL: URL?) {
        guard let fileURL else {
            return
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            print("File deleted successfully.")
        } catch {
            print("Error deleting file: \(error)")
        }
    }
}
