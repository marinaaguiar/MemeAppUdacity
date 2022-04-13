//
//  DetailViewController.swift
//  Meme
//
//  Created by Marina Aguiar on 4/11/22.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!

    var meme: Meme!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        detailImageView.image = meme.memedImage

    }

}
