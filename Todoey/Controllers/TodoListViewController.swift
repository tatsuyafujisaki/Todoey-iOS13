import ChameleonFramework
import RealmSwift
import UIKit

class TodoListViewController: SwipeTableViewController {
    var todoItems: Results<Item>?
    let realm = try! Realm()

    @IBOutlet var searchBar: UISearchBar!

    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist.")
            }
            if let navBarColour = UIColor(hexString: colourHex) {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = navBarColour
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: navBarColour, isFlat: true)!]
                navigationItem.scrollEdgeAppearance = appearance
                navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: navBarColour, isFlat: true)
                searchBar.barTintColor = navBarColour
                searchBar.searchTextField.backgroundColor = UIColor.flatWhite()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let colour = UIColor(
                hexString: selectedCategory!.colour)?.darken(byPercentage:
                CGFloat(indexPath.row) / CGFloat(todoItems!.count)
            ) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: colour, isFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }

    // MARK: - TableView Delegate Methods

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }

        tableView.reloadData()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Model Manipulation Methods

    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting Item, \(error)")
            }
        }
    }
}

// MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
