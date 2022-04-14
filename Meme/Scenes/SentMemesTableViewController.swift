import UIKit

// MARK: - UIViewController

class SentMemesTableViewController: UIViewController {

    // MARK: Properties

    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }

    // MARK: Outlets

    @IBOutlet private weak var tableView: UITableView?

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - UITableViewDataSource

extension SentMemesTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! SentMemesTableViewCell

        cell.memeImageView.image = memes[indexPath.row].memedImage
        cell.memeImageView.backgroundColor = .darkGray
        cell.memeImageView.contentMode = .scaleAspectFill
        cell.memeTitleLabel.text = "\(memes[indexPath.row].topTexField) \(memes[indexPath.row].bottomTextField)"

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SentMemesTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let detailViewController = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! MemeDetailViewController
        detailViewController.meme = self.memes[indexPath.row]
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}






