import UIKit

// MARK: - UIViewController

class SentMemesTableViewController: UIViewController {

    // MARK: Properties

    var memesList: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        let sortedMemes = appDelegate.memes.values.sorted()
        return sortedMemes
    }

    // MARK: Outlets

    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private var editButton: UIBarButtonItem!

    // MARK: Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
        tabBarController?.tabBar.isHidden = false
        enableEditButton()
    }

    // MARK: Interaction Methods

    @IBAction func editButtonPressed(_ sender: Any) {

        if tableView?.isEditing == false {
            // Toggle table view editing.
            editButton.style = .done
            editButton.title = "Done"
            tableView?.setEditing(true, animated: true)

        } else {
            editButton.style = .plain
            editButton.title = "Edit"
            tableView?.setEditing(false, animated: true)
        }
    }

    // MARK: Methods

    func enableEditButton() {

        if memesList.count == 0 {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
    }
}

// MARK: - UITableViewDataSource

extension SentMemesTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memesList.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! SentMemesTableViewCell

        cell.memeImageView.image = memesList[indexPath.row].memedImage
        cell.memeImageView.backgroundColor = .darkGray
        cell.memeImageView.contentMode = .scaleAspectFill
        cell.memeTitleLabel.text = "\(memesList[indexPath.row].topTexField) \(memesList[indexPath.row].bottomTextField)"

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SentMemesTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            let detailViewController = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! MemeDetailViewController
            detailViewController.meme = self.memesList[indexPath.row]
            self.navigationController?.pushViewController(detailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            // Declare Alert message
            let alert = UIAlertController(title: "Discard Meme?", message: "You will lose the meme you created", preferredStyle: .alert)

            // Create Cancel button with action handler
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                alert.dismiss(animated: true)
                debugPrint("cancel button tapped")
               })

            // Create Discard button with action handler
            let discard = UIAlertAction(title: "Discard", style: .destructive) { (action) -> Void in
                let object = UIApplication.shared.delegate
                let appDelegate = object as! AppDelegate
                appDelegate.memes.removeValue(forKey: self.memesList[indexPath.row].id)
                tableView.deleteRows(at: [indexPath], with: .fade)
                alert.dismiss(animated: true)
                self.dismiss(animated: true)
            }
            //Add Cancel and Discard button to dialog message
            alert.addAction(cancel)
            alert.addAction(discard)

            // Present dialog message to user
            self.present(alert, animated: true, completion: nil)
        }
    }
}


