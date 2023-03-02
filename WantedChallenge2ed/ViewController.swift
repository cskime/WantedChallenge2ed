//
//  ViewController.swift
//  WantedChallenge2ed
//
//  Created by chamsol kim on 2023/03/02.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var loadAllImagesButton: UIButton!
    private var dataTask = [Int: URLSessionDataTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zip(buttons, imageViews)
            .enumerated()
            .forEach {
                $0.element.0.tag = $0.offset
                $0.element.1.tag = $0.offset
            }
    }
    
    @IBAction func didTapLoadButton(_ sender: UIButton) {
        let imageView = imageViews[sender.tag]
        loadImage(to: imageView)
    }
    
    @IBAction func didTapLoadAllButton(_ sender: UIButton) {
        imageViews.forEach(loadImage(to:))
    }
    
    private func loadImage(to imageView: UIImageView) {
        imageView.image = UIImage(systemName: "photo")
        downloadImage(at: imageView.tag) { image in
            DispatchQueue.main.async {
                imageView.image = image ?? UIImage(systemName: "photo")
            }
        }
    }
    
    private func downloadImage(at index: Int, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "https://cataas.com/cat/cute") else {
            return completion(nil)
        }
        
        let request = URLRequest(url: url)
        dataTask[index]?.cancel()
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else {
                return completion(nil)
            }
            completion(UIImage(data: data))
        }
        task.resume()
        dataTask[index] = task
    }
}
