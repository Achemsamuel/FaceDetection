//
//  ViewController.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var beginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        beginButton.layer.cornerRadius = 10
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }

    
    @IBAction func beginButtonTapped(_ sender: UIButton) {
        navigationController?.pushViewController(VideoRecordViewController(), animated: true)
    }
    
}


