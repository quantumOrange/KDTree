//
//  StarsViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import KDTree

class StarMapViewController: UIViewController {
    
    var stars: KDTree<Star>? = nil
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "StarMap"

        let startLoading = Date()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadCSVData { stars in
                DispatchQueue.main.async {
                    xcLog.debug("Completed loading stars: \(Date().timeIntervalSince(startLoading))s")
                    self?.stars = stars
                    
                    xcLog.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                    self?.loadingIndicator.stopAnimating()
                    
                    if let stars = stars {
                        var firstTen = [String]()
                        for star in stars {
                            guard firstTen.count < 10 else { break }
                            firstTen.append("\(star)\n")
                        }
                        xcLog.debug("10 stars: \(firstTen.reduce("", { $0 + $1 }))")
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadCSVData(completion: (KDTree<Star>?) -> Void) {
        do {
            var startLoading = Date()
            guard let fileUrl = Bundle.main.url(forResource: "hygdata_v3", withExtension: "csv") else {
                completion(nil)
                return }
            
            let file = try String(contentsOf: fileUrl)
            xcLog.debug("Finished loading \(fileUrl)")
            let rows = file.components(separatedBy: .newlines)
            let stars = rows.dropFirst().flatMap { return Star(row:$0) }
            xcLog.debug("Time to load stars: \(Date().timeIntervalSince(startLoading))s")
            startLoading = Date()
            let starTree = KDTree(values: stars)
            xcLog.debug("Time to create Tree: \(Date().timeIntervalSince(startLoading))s")
            completion(starTree)
        }
        catch {
            xcLog.error(error)
            completion(nil)
        }
    }
    
    deinit {
        stars?.forEach({ (star: Star) in
            star.starData.ref.release()
        })
    }

}
