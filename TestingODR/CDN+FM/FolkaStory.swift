//
//  FolkaStory.swift
//  TestingODR
//
//  Created by Ghani's Mac Mini on 20/09/2023.
//

import Foundation

enum FolkaStory: String, CaseIterable {
    case malinKundang = "MalinKundang"
    case lutungKasarung = "LutungKasarung"
    case danauToba = "TobaLake"
    
    private var key: String {
        rawValue
    }
    
    /// Base URL of the CDN
    private var CDNBaseURL: String {
        "https://malikghani.com/folka/"
    }
    
    /// The key of the bundle resource for the corresponding story
    var bundleResourceKey: String {
        key + "Resources.bundle"
    }
    
    /// The key of the downloaded zip file for the corresponding story
    var CDNResourceKey: String {
        bundleResourceKey + ".zip"
    }
    
    /// Constructs a URL to download the zip file containing the bundle of story resources.
    /// - Returns: A URL representing the download location for the story resource bundle.
    func constructCDNResourceDownloadURL() -> URL? {
        URL(string: CDNBaseURL)?.appendingPathComponent(CDNResourceKey)
    }
    
    /// The document directory where the downloaded zip and bundle will be placed.
    private var documentDirectory: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// The path of the zip will be unzipped
    var unzipResourceLocation: URL? {
        documentDirectory
    }
    
    /// The URL where the downloaded zip file of the resource is stored.
    ///
    /// - Returns: The URL of the downloaded zip file.
    var zipFileURL: URL? {
        documentDirectory?.appendingPathComponent(CDNResourceKey)
    }

    /// The URL where the extracted .bundle resource is located.
    ///
    /// - Returns: The URL of the .bundle resource.
    var bundleResourceURL: URL? {
        documentDirectory?.appendingPathComponent(bundleResourceKey)
    }
}
