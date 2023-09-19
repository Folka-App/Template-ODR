//
//  DownloadImageController.swift
//  TestingODR
//
//  Created by M. Syulhan Al Ghofany on 17/09/23.
//

import UIKit
import SwiftSoup

class DownloadImageController: UIViewController {
    
    // Lokasi folder di CDN
    let folderCDN = "https://d3efsyslpe9irw.cloudfront.net/"
    
    // Properti untuk melacak ukuran total file yang akan diunduh
    var totalBytesExpectedToWrite: Int64 = 0
    var totalBytesWritten: Int64 = 0
    var onProgress: ((Double) -> Void)?
    
    let buttonNext = UIButton(frame: CGRect(x: 200, y: 500, width: 100, height: 50))
    let buttonShow = UIButton(frame: CGRect(x: 200, y: 650, width: 100, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonNext.backgroundColor = .green
        buttonNext.setTitle("Start Download", for: .normal)
        buttonNext.addTarget(self, action: #selector(startDownload), for: .touchUpInside)
        view.addSubview(buttonNext)
    }
    
    @objc func startDownload() {
        // Membuat folder utama
        guard let mainFolderURL = createMainFolderIfNotExists() else {
            print("Failed to create main folder.")
            return
        }
        
        // Buat permintaan HTTP untuk folder CDN
        guard let folderURL = URL(string: folderCDN) else {
            print("Invalid CDN URL.")
            return
        }
        
        URLSession.shared.dataTask(with: folderURL) { [weak self] (data, response, error) in
            guard let self = self, let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                print("Failed to fetch data from CDN.")
                return
            }
            
            // Mendapatkan tautan folder dari HTML
            let folderLinks = self.getFolderLinks(from: htmlString, cdnURL: self.folderCDN)
            
            // Memulai proses download folder dan gambar-gambar
            for folderLink in folderLinks {
                self.downloadFolderAndImages(folderLink, into: mainFolderURL)
            }
        }.resume()
    }
    
    // Fungsi untuk mendapatkan tautan folder dari halaman HTML
    func getFolderLinks(from htmlString: String, cdnURL: String) -> [String] {
        do {
            // Parse halaman HTML dengan SwiftSoup
            print("doc html string 1 \(htmlString)")
            let doc = try SwiftSoup.parse(htmlString)
            print("doc 1 \(doc)")
            
            // Pilih elemen-elemen yang mengandung tautan folder
            let folderElements = try doc.select("a[href^='\(cdnURL)']")
            print("folder elemen \(folderElements)")
            
            // Buat array untuk menyimpan tautan folder
            var folderLinks = [String]()
            
            // Loop melalui elemen-elemen folder dan ekstrak tautan folder
            for folderElement in folderElements {
                if let href = try? folderElement.attr("href") {
                    folderLinks.append(href)
                    print("hrefnya \(href)")
                }
            }
            print("folder links \(folderLinks)")
            
            return folderLinks
        } catch {
            print("Error parsing HTML: \(error)")
            return []
        }
    }
    
    // Fungsi untuk mengunduh folder dan gambar-gambar dari folder
    func downloadFolderAndImages(_ folderLink: String, into mainFolderURL: URL) {
        // Mendapatkan nama folder dari tautan folder
        guard let folderName = extractFolderName(from: folderLink, cdnURL: folderCDN) else {
            print("Failed to extract folder name.")
            return
        }
        
        // Menggabungkan path folder dalam dokumen dengan nama folder
        let folderURL = mainFolderURL.appendingPathComponent(folderName, isDirectory: true)
        print("folder url buat save gambar \(folderURL)")
        
        // Membuat folder jika belum ada
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating folder: \(error)")
            return
        }
        
        // Buat permintaan HTTP untuk folder di CDN
        guard let folderCDNURL = URL(string: folderLink) else {
            print("Invalid folder CDN URL.")
            return
        }
        
        URLSession.shared.dataTask(with: folderCDNURL) { [weak self] (data, response, error) in
            guard let self = self, let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                print("Failed to fetch data from folder in CDN.")
                return
            }
            
            // Mendapatkan tautan gambar dari folder
            let imageLinks = self.getImageLinks(from: htmlString, cdnURL: folderCDNURL.absoluteString)
            print("link gambar \(imageLinks)")
            
            // Memulai proses download gambar-gambar
            for imageLink in imageLinks {
                self.downloadImage(imageLink, into: folderURL)
            }
        }.resume()
    }
    
    // Fungsi untuk mendapatkan tautan gambar dari halaman HTML
    func getImageLinks(from htmlString: String, cdnURL: String) -> [String] {
        do {
            // Parse halaman HTML dengan SwiftSoup
            let doc = try SwiftSoup.parse(htmlString)
            print("doc 2 \(doc)")
            
            // Pilih elemen-elemen yang mengandung tautan gambar (misalnya, elemen 'img')
            let imgElements = try doc.select("img")
            
            // Buat array untuk menyimpan tautan gambar
            var imageLinks = [String]()
            
            // Loop melalui elemen-elemen gambar dan ekstrak tautan gambar
            for imgElement in imgElements {
                if let src = try? imgElement.attr("src") {
                    // Jika tautan gambar adalah relatif, gabungkan dengan URL CDN
                    let imageUrl = URL(string: src, relativeTo: URL(string: cdnURL))
                    if let imageUrlString = imageUrl?.absoluteString {
                        imageLinks.append(imageUrlString)
                        print("link tiap gambar \(imageUrlString)")
                    }
                }
            }
            
            return imageLinks
        } catch {
            print("Error parsing HTML: \(error)")
            return []
        }
    }
    
    // Fungsi untuk mendapatkan nama folder dari tautan folder
    func extractFolderName(from folderLink: String, cdnURL: String) -> String? {
        // Menghilangkan bagian awal URL CDN untuk mendapatkan nama folder
        let folderName = folderLink.replacingOccurrences(of: cdnURL, with: "")
        print("nama foldernya \(folderName)")
        
        // Menghilangkan karakter "/" di awal jika ada
        return folderName.hasPrefix("/") ? String(folderName.dropFirst()) : folderName
    }
    
    // Fungsi untuk mengunduh gambar dan menyimpannya
    func downloadImage(_ imageLink: String, into folderURL: URL) {
        guard let imageUrl = URL(string: imageLink) else {
            print("Invalid image URL.")
            return
        }
        
        URLSession.shared.downloadTask(with: imageUrl) { [weak self] (fileURL, response, error) in
            guard let self = self, let fileURL = fileURL, let response = response as? HTTPURLResponse, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "")")
                return
            }
            
            if response.statusCode == 200 {
                let fileName = imageUrl.lastPathComponent
                let destinationURL = folderURL.appendingPathComponent(fileName)
                
                do {
                    try FileManager.default.moveItem(at: fileURL, to: destinationURL)
                    print("Downloaded: \(fileName)")
                } catch {
                    print("Error moving image: \(error)")
                }
            }
            
        }.resume()
    }
    
    // Fungsi untuk membuat folder utama
    func createMainFolderIfNotExists() -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let mainFolderName = "MyImageFolder" // Nama folder utama yang ingin Anda buat
        
        // Menggabungkan path dokumen dengan nama folder utama
        let mainFolderURL = documentsDirectory.appendingPathComponent(mainFolderName, isDirectory: true)
        
        // Membuat folder utama jika belum ada
        if !FileManager.default.fileExists(atPath: mainFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: mainFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating main folder: \(error)")
                return nil
            }
        }
        
        // Sekarang, Anda dapat mengembalikan URL folder utama
        return mainFolderURL
    }
}
