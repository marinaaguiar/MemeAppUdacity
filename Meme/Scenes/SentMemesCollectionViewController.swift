import UIKit

// MARK: - UIViewController

class SentMemesCollectionViewController: UIViewController {

    let isDebug = false

    // MARK: Properties

    let memesCollectionViewCell = SentMemesCollectionViewCell()

    var memesList: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate

        let sortedMemes = appDelegate.memes.values.sorted()

        return sortedMemes
    }

    // MARK: Outlets

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    // MARK: Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setFlowLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didLoad()
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: Methods

    func didLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }

    func setFlowLayout() {
        let space: CGFloat = 4.0
        let inset: CGFloat = 8.0

        let dimension = (collectionView.frame.size.width - (2 * (space + inset))) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}

// MARK: - UICollectionViewDataSource

extension SentMemesCollectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isDebug {
            return 3
        }

        return memesList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: memesCollectionViewCell.identifier, for: indexPath) as! SentMemesCollectionViewCell

        if isDebug {
            cell.backgroundColor = (indexPath.item % 2) == 0 ? .systemOrange : .systemTeal
            return cell
        }

        cell.memeImageView.image = memesList[indexPath.row].memedImage
        cell.memeImageView.backgroundColor = .darkGray
        cell.memeImageView.contentMode = .scaleAspectFill
        cell.memeImageView.clipsToBounds = true

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SentMemesCollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("hi honey")
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let detailViewController = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! MemeDetailViewController
        detailViewController.meme = self.memesList[indexPath.row]
        self.navigationController?.pushViewController(detailViewController, animated: true)

        print(memesList[indexPath.row].topTexField)
    }
}
