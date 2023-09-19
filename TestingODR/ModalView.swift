//
//  ModalView.swift
//  TestingODR
//
//  Created by M. Syulhan Al Ghofany on 14/08/23.
//

import UIKit

class ModalViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize your modal view controller here
        view.backgroundColor = .white
        
        // MARK: BUAT FM WITH CDN
        // Mendapatkan path ke file gambar di dalam folder dokumen
        //        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        //            let folderName = "MyImageFolder/Wallpaper"
        //            let imageName = "aula.jpg"
        //            let imageUrl = documentsDirectory.appendingPathComponent(folderName).appendingPathComponent(imageName)
        //
        //            // Membuat objek UIImage dari file gambar
        //            if let image = UIImage(contentsOfFile: imageUrl.path) {
        //                // Membuat UIImageView dan menambahkan gambar ke dalamnya
        //                let imageView = UIImageView(image: image)
        //                imageView.contentMode = .scaleAspectFit
        //                imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200) // Atur ukuran ImageView sesuai kebutuhan
        //
        //                // Menambahkan ImageView ke tampilan utama
        //                view.addSubview(imageView)
        //            } else {
        //                print("Gagal membuat objek UIImage dari file gambar di path: \(imageUrl.path)")
        //            }
        //        } else {
        //            print("Gagal mendapatkan path dokumen.")
        //        }
        
        // MARK: BUAT ODR DOANG
        //        let imageName = "aula"
        //        let image = UIImage(named: imageName)
        //        let imageView = UIImageView(image: image)
        //
        //        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        //        self.view.addSubview(imageView)
        
        // MARK: BUAT FM WITH ODR
        displaySavedImage()
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        view.addSubview(dismissButton)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
    
    func displaySavedImage() {
        // Dapatkan direktori dokumen aplikasi
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Nama file gambar yang ingin Anda tampilkan (ganti dengan nama file yang sesuai)
            let fileName = "aula.jpg" // Ganti dengan nama file gambar yang sesuai
            
            // Gabungkan direktori dokumen dengan nama file
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            // Buat UIImageView programatik
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200)) // Sesuaikan ukuran dan posisi sesuai kebutuhan
            // Periksa apakah file ada di direktori dokumen
            if let image = UIImage.loadImageFromDocumentDirectory(withName: "aula.jpg") {
                // Gunakan objek image sesuai kebutuhan, misalnya tampilkan di UIImageView
                imageView.image = image
            } else {
                print("Gagal memuat gambar dari direktori dokumen.")
            }
            
            imageView.contentMode = .scaleAspectFit // Sesuaikan mode tampilan gambar sesuai kebutuhan
            imageView.center = view.center // Menempatkan UIImageView di tengah tampilan
            view.addSubview(imageView) // Menambahkan UIImageView ke tampilan
        }
    }
}

extension UIImage {
    static func loadImageFromDocumentDirectory(withName name: String) -> UIImage? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(name)
            if let image = UIImage(contentsOfFile: fileURL.path) {
                return image
            }
        }
        return nil
    }
}
