//
//  DetailViewController.swift
//  Meme
//
//  Created by Marina Aguiar on 4/11/22.
//

import UIKit

class MemeDetailViewController: UIViewController {

    // MARK: Properties

    var meme: Meme!

    // MARK: Outlets

    @IBOutlet weak var detailImageView: UIImageView!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        detailImageView.image = meme.memedImage
    }

    // MARK: Interaction Methods

    @IBAction func editButtonPressed(_ sender: Any) {

        let memeEditorViewController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        self.navigationController?.pushViewController(memeEditorViewController, animated: true)
    }
}
