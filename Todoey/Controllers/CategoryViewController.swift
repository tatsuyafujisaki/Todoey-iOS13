import ChameleonFramework
import RealmSwift
import UIKit

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    var categories: Results<Category>?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        loadCategories()
//    }

    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        // If you call loadCategories() in viewDidLoad() function,
        // the cell colors will not be as expected when you go back from TodoListViewController.
        loadCategories()
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }

    // MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
            guard let categoryColour = UIColor(hexString: category.colour) else { fatalError() }
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColour, isFlat: true)
        }
        return cell
    }

    // MARK: - TableView Delegate Methods

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    // MARK: - Data Manipulation Methods

    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }

    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }

    // MARK: - Delete Data from Swipe

    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        if let cateoryForDeletion = categories?[indexPath.row] {
            do {
                try realm.write {
                    self.realm.delete(cateoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }

    // MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { _ in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()

            self.save(category: newCategory)
        }

        alert.addAction(action)
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Add a new category"
        }

        present(alert, animated: true, completion: nil)
    }
}
