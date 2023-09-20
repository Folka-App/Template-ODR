//
//  FolkaStoryResourceManager.swift
//  TestingODR
//
//  Created by Ghani's Mac Mini on 26/09/2023.
//

import Foundation
import Zip

struct FolkaStoryResourceManager {
    
    private static let downloader: FileDownloader = .init()
    
    /// Checks if a resource is available for a given FolkaStory.
    ///
    /// - Parameter story: The FolkaStory for which to check resource availability.
    /// - Returns: `true` if the resource is available; `false` otherwise.
    static func isResourceAvailable(for story: FolkaStory) -> Bool {
        FileOrganizer.isExist(for: story.bundleResourceURL)
    }
    
    /// Deletes the resources folder and ZIP file for the given story.
    ///
    /// When app perform this method, the app need to re-download the resource from the CDN again.
    ///
    /// - Parameter story: The story for which the resources will be deleted.
    static func deleteResource(for story: FolkaStory, zipFileOnly: Bool) {
        if zipFileOnly {
            // Delete the story.bundle.zip file, if any.
            FileOrganizer.deleteFile(for: story.zipFileURL)
            return
        }
        // Delete the story.bundle.zip file, if any.
        FileOrganizer.deleteFile(for: story.zipFileURL)

        // If not zipFileOnly, delete the story.bundle directory as well.
        FileOrganizer.deleteFile(for: story.bundleResourceURL)
    }
    
    /// Downloads and processes a resource for a given FolkaStory.
    ///
    /// - Parameters:
    ///   - story: The FolkaStory for which to download the resource.
    ///   - progressHandler: An optional closure to track the download progress. It provides a progress value between 0.0 (0%) and 1.0 (100%).
    ///   - unzipHandler: An optional closure to track the unzip progress, if applicable. It provides a progress value between 0.0 (0%) and 1.0 (100%).
    ///   - completionHandler: A closure to be called upon completion of the download and processing.
    static func downloadResource(for story: FolkaStory,
                                 progressHandler: ((Float) -> Void)? = nil,
                                 unzipHandler: ((Float) -> Void)? = nil,
                                 completionHandler: @escaping (() -> Void)) {
        // Ambil url untuk bundle dari story.
        guard let url = story.constructCDNResourceDownloadURL() else {
            print("Invalid bundle URL")
            return
        }
        
        // Ambil location untuk zip file akan di download
        guard let localFileLocation = story.zipFileURL else {
            print("Invalid local file location")
            return
        }
        
        downloader.downloadFile(from: url, to: localFileLocation) { progress in
            progressHandler?(progress)
        } completion: { error in
            if let error {
                print("Error when downloading \(story) resources: \(error.localizedDescription)")
                return
            }
            
            // Unzip resource yang sudah di download
            unzipStoryResource(fileLocation: localFileLocation, unzipFileDestination: story.unzipResourceLocation!) { progress in
                unzipHandler?(Float(progress))
            }
            
            // Delete zip file yang sudah di download, kenapa, karena sudah di unzip (sudah ada folder aslinya untuk resource)
            deleteResource(for: story, zipFileOnly: true)
            
            completionHandler()
        }
    }
    
    /// Cancels the download for a specific story's resource.
    ///
    /// - Parameter story: The `FolkaStory` for which the download should be canceled.
    static func cancelDownload(for story: FolkaStory) {
        // Construct the CDN resource download URL for the story
        if let url = story.constructCDNResourceDownloadURL() {
            // Cancel the download using the downloader
            downloader.cancelDownload(for: url)
        }
    }
    
    /// Unzips a story resource from a zip file to the specified destination folder.
    ///
    /// - Parameters:
    ///   - fileLocation: The URL of the zip file to unzip.
    ///   - unzipFileDestination: The destination URL where the unzipped files will be placed.
    ///   - progressHandler: An optional closure that can be used to track the progress of the unzip operation.
    ///                      It provides a progress value between 0.0 (0%) and 1.0 (100%).
    private static func unzipStoryResource(fileLocation: URL, unzipFileDestination: URL, progressHandler: ((Double) -> Void)? = nil) {
        let startTime = CACurrentMediaTime()
        
        // Unzip the downloaded file
        try? Zip.unzipFile(fileLocation, destination: unzipFileDestination, overwrite: true, password: nil, progress: { progress in
            progressHandler?(progress)
        })
        
        let endTime = CACurrentMediaTime()
        print("Total unzip elapsed time: \(endTime - startTime) s")
    }
}
