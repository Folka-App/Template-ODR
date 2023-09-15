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
        
        let imageName = "aula"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        self.view.addSubview(imageView)
        
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
}
