//
//  ViewController.swift
//  TestingODR
//
//  Created by M. Syulhan Al Ghofany on 11/06/23.
//

import UIKit

class ViewController: UIViewController {
    static var progressSceneKVOContext = 0
    let array = ["harry"]
    var resourceRequest:NSBundleResourceRequest? = nil
    
    let button:UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
    let label = UILabel(frame: CGRect(x: 120, y: 120, width: 200, height: 21))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.backgroundColor = .green
        button.setTitle("Button", for: .normal)
        button.addTarget(self, action:#selector(self.pressed), for: .touchUpInside)
        self.view.addSubview(button)
        
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "I'm a test label"
        self.view.addSubview(label)
        
//        loadResourceWithTag(tagArray: array)
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
            loadResourceWithTag(tagArray: array)
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func preloadResourceWithTag(tagArray: Array<String>){
        let tags = NSSet(array: tagArray)
        resourceRequest = NSBundleResourceRequest(tags: tags as! Set<String>)
        //        let resourceRequest:NSBundleResourceRequest = NSBundleResourceRequest(tags: tags as! Set<String>)
        resourceRequest?.beginAccessingResources(completionHandler: { (error) in
            OperationQueue.main.addOperation{
                guard error == nil else {
                    print(error!);
                    return
                }
                
                print("Preloading On-Demand Resources")
            };
        })
    }
    
    func loadResourceWithTag(tagArray: Array<String>) {
        let tags = NSSet(array: tagArray)
        resourceRequest = NSBundleResourceRequest(tags: tags as! Set<String>)
        //        let resourceRequest:NSBundleResourceRequest = NSBundleResourceRequest(tags: tags as! Set<String>)
        resourceRequest?.conditionallyBeginAccessingResources { [self] (resourceAvailable: Bool) -> Void in
            if (resourceAvailable == true) {
                print("On-Demand Resources already Avail")
                self.displayResources()
            } else {
                resourceRequest?.progress.addObserver(self, forKeyPath: "fractionCompleted", options: [.new, .initial], context: &ViewController.progressSceneKVOContext)
                
                resourceRequest?.beginAccessingResources(completionHandler: {(err) -> Void in
                    if err == nil {
                        //                        resourceRequest.removeObserver(self, forKeyPath: "fractionCompleted", context: &ViewController.progressSceneKVOContext)
                        
                        print("On-Demand Resources downloaded, wait")
                        self.displayResources()
                    } else {
                        print("Error \(String(describing: err))")
                    }
                })
            }
        }
    }
    
    func displayResources() {
        DispatchQueue.main.async {
            let imageName = "aula"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image)
            
            imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
            self.view.addSubview(imageView)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &ViewController.progressSceneKVOContext && keyPath == "fractionCompleted" {
            OperationQueue.main.addOperation({ [self] in
                print((object as! Progress).localizedDescription!)
                label.text = (object as! Progress).localizedDescription!
            })
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
}

