import UIKit

// MARK: - UIViewController

class SentMemesCollectionViewController: UIViewController {

    // MARK: Properties

    let memesCollectionViewCell = SentMemesCollectionViewCell()

    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }

    // MARK: Outlets

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    // MARK: Life Cycle

    func setFlowLayout() {
        let space: CGFloat = 3.0
        let dimension = (collectionView.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}

// MARK: - UICollectionViewDataSource

extension SentMemesCollectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: memesCollectionViewCell.identifier, for: indexPath) as! SentMemesCollectionViewCell

        cell.memeImageView.image = memes[indexPath.row].memedImage
        debugPrint(memes[0].memedImage)

//        cell.imageView!.image = memes[indexPath.row].memedImage

        return cell
    }
}




//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
//
//        //Populate view controller with data from the selected item
//        detailController.detailImageView.image = memes[(indexPath as NSIndexPath).row].memedImage
//
//        // Present the view controller using navigation
//        navigationController!.pushViewController(detailController, animated: true)
//    }

