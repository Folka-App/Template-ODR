//
//  UIImage+FolkaAsset.swift
//  TestingODR
//
//  Created by Ghani's Mac Mini on 20/09/2023.
//

import UIKit

extension UIImage {
    /// Loads an image asset for a FolkaStory Resource.
    ///
    /// - Parameters:
    ///   - story: The FolkaStory to which the asset belongs.
    ///   - name: The name of the asset.
    ///   - fileType: The file type of the asset (default is "jpg").
    /// - Returns: An optional UIImage containing the loaded asset, or nil if the asset couldn't be loaded.
    static func asset(_ story: FolkaStory, name: String, fileType: String = "jpg") -> UIImage? {
        guard let localFileLocation = story.bundleResourceURL else {
            print("Invalid local file location")
            return nil
        }
        
        let path = localFileLocation.appendingPathComponent("\(name).\(fileType)")
        
        guard let data = try? Data(contentsOf: path) else {
            return nil
        }
        
        return UIImage(data: data)
    }
}
