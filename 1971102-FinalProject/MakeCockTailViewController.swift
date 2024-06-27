//
//  MakeCockTailViewController.swift
//  1971102-FinalProject
//
//  Created by mac004 on 2024/06/05.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore

struct CocktailUser: Codable {
    let cocktailName: String
    let cocktailPrice: String
    let cocktailDescription: String
}

class MakeCockTailViewController: UIViewController {

    
    @IBOutlet weak var cocktailPrice: UITextField!
    @IBOutlet weak var cocktailName: UITextField!
    @IBOutlet weak var cocktailDescription: UITextView!
    
    @IBOutlet weak var cocktailTableView: UITableView!
    var cocktails: [CocktailUser] = [] // 칵테일 정보를 저장할 배열
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cocktailTableView.dataSource = self
        cocktailTableView.delegate = self
        fetchCocktailsFromFirestore()
    }
    
    @IBAction func saveCocktail(_ sender: UIButton) {
        guard let name = cocktailName.text, !name.isEmpty,
                      let price = cocktailPrice.text, !price.isEmpty,
                      let description = cocktailDescription.text, !description.isEmpty else {
                    let alert = UIAlertController(title: "Error", message: "All fields must be filled out", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return
                }

                let cocktail = CocktailUser(cocktailName: name, cocktailPrice: price, cocktailDescription: description)
                saveCocktailToFirestore(cocktail)
    }
    func saveCocktailToFirestore(_ cocktail: CocktailUser) {
        let db = Firestore.firestore()
                do {
                    let data = try JSONEncoder().encode(cocktail)
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    db.collection("cocktails").addDocument(data: json) { [weak self] error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added successfully")
                            self?.fetchCocktailsFromFirestore()
                        }
                    }
                } catch {
                    print("Error encoding cocktail: \(error)")
                }
    }
    func fetchCocktailsFromFirestore() {
        let db = Firestore.firestore()
                db.collection("cocktails").getDocuments { [weak self] (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        self?.cocktails = querySnapshot?.documents.compactMap { document -> CocktailUser? in
                            do {
                                let data = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                                let cocktail = try JSONDecoder().decode(CocktailUser.self, from: data)
                                return cocktail
                            } catch {
                                print("Error decoding cocktail: \(error)")
                                return nil
                            }
                        } ?? []
                        self?.cocktailTableView.reloadData()
                    }
                }
    }
    
}
extension MakeCockTailViewController:UITableViewDataSource{
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return cocktails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailCell", for: indexPath)
            let cocktail = cocktails[indexPath.row]
            cell.textLabel?.text = cocktail.cocktailName
            cell.detailTextLabel?.text = "\(cocktail.cocktailPrice) - \(cocktail.cocktailDescription)"
            return cell
    }
}

extension MakeCockTailViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            cocktails.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let city = cocktails.remove(at: sourceIndexPath.row)
        cocktails.insert(city, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
}
