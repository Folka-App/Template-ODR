//
//  FileManager.swift
//  TestingODR
//
//  Created by M. Syulhan Al Ghofany on 15/09/23.
//

import AVFoundation
import AVKit
import UIKit

final class CDNController: UIViewController {
    
    private var progressView: UIProgressView!
    
    // Selected Story
    private var story: FolkaStory = .lutungKasarung {
        didSet {
            DispatchQueue.main.async {
                let isResourceDownloaded = FolkaStoryResourceManager.isResourceAvailable(for: self.story)
                let description = isResourceDownloaded ? "Downloaded" : "not found"
                self.label.text = "Selected Story: \n \(self.story) \n resource \(description)"
                self.actionButton.setTitle(isResourceDownloaded ? "Play" : "Download Resource", for: .normal)
                self.actionButton.isHidden = false
                self.deleteResourceButton.isHidden = !isResourceDownloaded
                self.cancelDownloadButton.isHidden = true
            }
        }
    }
    
    private let actionButton      = UIButton()
    private let label             = UILabel(frame: CGRect(x: 16, y: 120, width: UIScreen.main.bounds.width - 16, height: 100))
    private let changeStoryButton = UIButton()
    private let cancelDownloadButton = UIButton()
    private let deleteResourceButton = UIButton()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [changeStoryButton, actionButton, cancelDownloadButton, deleteResourceButton])
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            progressView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        actionButton.backgroundColor = .systemCyan
        actionButton.setTitle("Play", for: .normal)
        actionButton.addTarget(self, action: #selector(resourceAction), for: .touchUpInside)
        actionButton.layer.cornerRadius = 12
        
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        view.addSubview(label)
        
        changeStoryButton.setTitle("Change Story", for: .normal)
        changeStoryButton.backgroundColor = .systemGreen
        changeStoryButton.layer.cornerRadius = 12
        
        cancelDownloadButton.setTitle("Cancel Download", for: .normal)
        cancelDownloadButton.backgroundColor = .systemRed
        cancelDownloadButton.layer.cornerRadius = 12
        cancelDownloadButton.isHidden = true
        cancelDownloadButton.addTarget(self, action: #selector(cancelDownload), for: .touchUpInside)
        
        deleteResourceButton.setTitle("Delete Resource", for: .normal)
        deleteResourceButton.backgroundColor = .systemRed
        deleteResourceButton.layer.cornerRadius = 12
        deleteResourceButton.isHidden = true
        deleteResourceButton.addTarget(self, action: #selector(deleteResource), for: .touchUpInside)
        
        view.addSubview(stackView)
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140).isActive = true
        story = .lutungKasarung
        
        let actions = FolkaStory.allCases.map { story in
            UIAction(title: story.rawValue, image: UIImage(systemName: "arrow.clockwise")) { _ in
                self.story = story
            }
        }
        
        let menu = UIMenu(title: "Select story", children: actions)
        changeStoryButton.menu = menu
        changeStoryButton.showsMenuAsPrimaryAction = true
    }
    
    /// Download resource untuk story
    func downloadBundleResources(for story: FolkaStory) {
        // Delete resource dahulu baik yang zip file atau .bundle, jika ada
        FolkaStoryResourceManager.deleteResource(for: story, zipFileOnly: false)
        
        // Unhide the cancel button, karena akan mulai download
        cancelDownloadButton.isHidden = false
        
        // Hide the download resource button, karena akan mulai download
        actionButton.isHidden = true
        
        // Mulai download resource
        FolkaStoryResourceManager.downloadResource(for: story) { [weak self] progress in
            self?.setProgress(title: "Downloading \(story) resource:", progress: progress)
        } unzipHandler: { [weak self] progress in
            self?.setProgress(title: "Unzipping \(story) resource:", progress: progress)
        } completionHandler: { [weak self] in
            // Delete zip file yang sudah di download, kenapa, karena sudah di unzip (sudah ada folder aslinya untuk resource)
            FolkaStoryResourceManager.deleteResource(for: story, zipFileOnly: true)
            
            // Update label
            self?.story = story
            
            // Lakuin action
            self?.performPlay()
        }
    }
    
    /// Set Progress untuk download ataupun unzip
    private func setProgress(title: String, progress: Float) {
        DispatchQueue.main.async { [weak self] in
            self?.label.text = "\(title)\n\(progress * 100.0)%"
            self?.progressView.setProgress(progress, animated: true)
        }
    }
    
    private func performPlay() {
        DispatchQueue.main.async {
            // Ambil image untuk asset danauToba dengan nama `1`
            let image = UIImage.asset(self.story, name: "1")
            
            // Contoh jika ambil asset video dari danauToba
            guard let localFileLocation = self.story.bundleResourceURL else {
                return
            }
            
            let path = localFileLocation.appendingPathComponent("video.mp4")
            let player = AVPlayer(url: path)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
}

// MARK: - Alert Actions
extension CDNController {
    /// Play Video
    @objc private func resourceAction() {
        if FolkaStoryResourceManager.isResourceAvailable(for: story)  {
            let alertController = UIAlertController(title: "Resource for \(story) is available", message: "Tap play to start playing a video.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Play", style: .default) { _ in
                self.performPlay()
            }
            
            alertController.addAction(okAction)
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(title: "Downloading \(story)", message: "Tap OK to start downloading the resource.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.downloadBundleResources(for: self.story)
            }
            
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
    
    /// Cancel ongoing download resource
    @objc private func cancelDownload() {
        let alertController = UIAlertController(title: "Cancel Resource Download", message: "Are you sure want to cancel \(story) resource?.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            FolkaStoryResourceManager.cancelDownload(for: self.story)
            self.story = self.story
            self.progressView.setProgress(0, animated: true)
            self.cancelDownloadButton.isHidden = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    /// Delete Resource
    @objc private func deleteResource() {
        let alertController = UIAlertController(title: "Delete \(story) Resource", message: "Are you sure want to delete \(story) resource?.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            FolkaStoryResourceManager.deleteResource(for: self.story, zipFileOnly: false)
            self.story = self.story
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
