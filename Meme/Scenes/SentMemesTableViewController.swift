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

    @IBOutlet private weak var tableView: UITableView!
    let memesTableViewCell = SentMemesTableViewCell()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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

        let cell = tableView.dequeueReusableCell(withIdentifier: memesTableViewCell.identifier) as! SentMemesTableViewCell

        cell.imageView?.image = memes[indexPath.row].memedImage
        debugPrint(memes[0].memedImage)

        return cell
    }
}






