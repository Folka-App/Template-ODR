//
//  ShowOneController.swift
//  TestingODR
//
//  Created by M. Syulhan Al Ghofany on 18/09/23.
//

import UIKit

import UIKit

class ShowOneController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Membuat UIImageView programatik
        let imageView = UIImageView()
        
        // Mengatur ukuran gambar
        imageView.frame = CGRect(x: 50, y: 100, width: 200, height: 200) // Ganti nilai sesuai keinginan Anda
        
        // Mengatur content mode agar gambar sesuai dengan ukuran UIImageView
        imageView.contentMode = .scaleAspectFit
        
        // Menambahkan UIImageView ke tampilan utama
        self.view.addSubview(imageView)
        
        // Gantilah URL ini dengan URL gambar yang ingin Anda tampilkan
        if let url = URL(string: "https://d3efsyslpe9irw.cloudfront.net/Wallpaper/aula.jpg") {
            // Gunakan URLSession untuk mengunduh data gambar
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    // Setel gambar di thread utama
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}

