//
//  FileManager.swift
//  TestingODR
//
//  Created by M. Syulhan Al Ghofany on 15/09/23.
//

import UIKit

class ODRController: UIViewController {
    private var progressView: UIProgressView!
    
    let button:UIButton = UIButton(frame: CGRect(x: 90, y: 500, width: 100, height: 50))
    let label = UILabel(frame: CGRect(x: 120, y: 120, width: 200, height: 21))
    let buttonNext = UIButton(frame: CGRect(x: 200, y: 500, width: 100, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Buat dan konfigurasi UIProgressView secara programatik
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        // Tambahkan constraint untuk menempatkan UIProgressView
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 200), // Sesuaikan lebar sesuai kebutuhan
            progressView.heightAnchor.constraint(equalToConstant: 10)  // Sesuaikan tinggi sesuai kebutuhan
        ])
        
        button.backgroundColor = .green
        button.setTitle("Button", for: .normal)
        button.addTarget(self, action:#selector(self.pressed), for: .touchUpInside)
        self.view.addSubview(button)
        
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "I'm a test label"
        self.view.addSubview(label)
        
        buttonNext.backgroundColor = .green
        buttonNext.setTitle("Present Modal", for: .normal)
        buttonNext.addTarget(self, action: #selector(presentModal), for: .touchUpInside)
        view.addSubview(buttonNext)
        
        downloadAndSaveImages()
    }
    
    @objc func presentModal() {
        // Function to handle button tap
        let modalViewController = ModalViewController() // Replace with your modal view controller
        present(modalViewController, animated: true, completion: nil)
    }
    
    @objc func pressed() {
        let alertController = UIAlertController(title: "Destructive", message: "Simple alertView demo with Destructive and Ok.", preferredStyle: UIAlertController.Style.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let DestructiveAction = UIAlertAction(title: "Destructive", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            print("Destructive")
        }
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [self]
            (result : UIAlertAction) -> Void in
            print("OK")
            
            self.downloadAndSaveImages()
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func downloadAndSaveImages() {
        print("masukkk")
        let tagToDownload = "harry"
        
        // Menciptakan NSProgress untuk melacak progress
        let progress = Progress(totalUnitCount: Int64(100)) // Jumlah total unit biasanya adalah 100 (100%)
        progressView.observedProgress = progress
        
        // Loop melalui gambar-gambar dengan tag ODR yang sesuai
        for imageName in Bundle.main.paths(forResourcesOfType: "jpg", inDirectory: nil) {
            // Dapatkan URL gambar dari ODR
            print("nama imagenya \(imageName)")
            if let odrURL = Bundle.main.url(forResource: (imageName as NSString).deletingPathExtension, withExtension: "jpg") {
                // Mulai mengunduh sumber daya dari ODR dengan NSProgress
                let request = NSBundleResourceRequest(tags: Set([tagToDownload]), bundle: Bundle.main)
                request.beginAccessingResources { error in
                    if let error = error {
                        print("Gagal mengunduh sumber daya ODR: \(error)")
                    } else {
                        print("Sumber daya ODR berhasil diunduh")
                        // Sumber daya ODR telah diunduh dan dapat digunakan
                        if let imageData = try? Data(contentsOf: odrURL),
                           let image = UIImage(data: imageData) {
                            // Simpan gambar ke direktori dokumen aplikasi
                            self.saveImageToDocumentDirectory(image, fileName: imageName)
                        }
                    }
                    // Selesaikan progress setelah setiap gambar selesai diunduh
                    progress.completedUnitCount += 1
                    
                    // Perbarui UIProgressView di utas antarmuka pengguna (UI)
                    DispatchQueue.main.async {
                        self.progressView.progress = Float(progress.fractionCompleted)
                    }
                }
            }
        }
    }
    
    func saveImageToDocumentDirectory(_ image: UIImage, fileName: String) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Gabungkan direktori dokumen dengan nama file
            let fileURL = documentDirectory.appendingPathComponent(fileName)

            // Simpan gambar ke direktori dokumen aplikasi
            if let data = image.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fileURL)
                    print("Gambar \(fileName) berhasil disimpan di direktori dokumen aplikasi.")
                } catch {
                    print("Gagal menyimpan gambar \(fileName): \(error)")
                }
            }
        }
    }
}
