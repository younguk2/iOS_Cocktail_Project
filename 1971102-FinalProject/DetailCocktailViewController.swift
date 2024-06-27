//
//  DetailCocktailViewController.swift
//  1971102-FinalProject
//
//  Created by mac004 on 2024/06/04.
//

import UIKit


struct CocktailResponse: Codable {
    let drinks: [Cocktail]
}

struct Cocktail: Codable {
    let idDrink: String
    let strDrink: String
    let strDrinkThumb: String
    let strInstructions: String
    // Add other properties you need from the response
}

class DetailCocktailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!

    var cocktailName: String!
    var cocktails: [Cocktail] = [] // 칵테일 정보를 저장할 배열
    //margarita
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cocktailName = cocktailName {
            let urlString = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(cocktailName)"
            fetchCocktails(from: urlString)
        }
        tableView.dataSource = self
        tableView.delegate = self
        
//        cityTableView.register(UITableViewCell.self, forCellReuseIdentifier: "jmlee")
        
//        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
//        descriptionLabel.text = cocktails[0].strDrink
//
        //cityTableView.isEditing = true
    }
    
    
    @IBAction func editingTableViewRow(_ sender: UIBarButtonItem) {
        if tableView.isEditing == true{
            sender.title = "Edit"
            tableView.isEditing = false
        }else{
            sender.title = "Done"
            tableView.isEditing = true
        }
    }
    func fetchCocktails(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            print(urlString)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
        }
    
        guard let data = data else {
                print("No data received")
                return
        }
    
        do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(CocktailResponse.self, from: data)
                print(result)
                self.cocktails = result.drinks
                print("**********")
                print(self.cocktails.first)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
        }
        }.resume()
    }
}

extension DetailCocktailViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cocktails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ymlee")!
        cell.textLabel?.text = cocktails[indexPath.row].strDrink
        cell.detailTextLabel?.text = "in " + cocktails[indexPath.row].strInstructions
//        cell.imageView?.image = cocktails[indexPath.row].uiImage(size: CGSize(width: 200, height: 100))
        return cell
    }
}

extension DetailCocktailViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        descriptionLabel.text = cocktails[indexPath.row].strInstructions
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

//class DetailCocktailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    class CocktailCollectionViewCell: UICollectionViewCell {
//        @IBOutlet weak var drinkLabel: UILabel!
//        @IBOutlet weak var descriptionLabel: UILabel!
//        @IBOutlet weak var imageView: UIImageView!
//
//
//    }
//    //@IBOutlet weak var searchWord: UILabel!
//
//    @IBOutlet weak var collectionView: UICollectionView!
//    var cocktailName: String!
//    var cocktails: [Cocktail] = [] // 칵테일 정보를 저장할 배열
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        collectionView.register(CocktailCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
//        collectionView.delegate = self
//        collectionView.dataSource = self
//
//
//        // 칵테일 이름에 해당하는 API URL을 만듭니다.
//        let cocktailName = "margarita" // 여기에 원하는 칵테일 이름을 넣어주세요.
//        let urlString = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(cocktailName)"
//        fetchCocktails(from: urlString)
//
//
//
//    }
//    func fetchCocktails(from urlString: String) {
//            guard let url = URL(string: urlString) else {
//                print("Invalid URL")
//                return
//            }
//
//            URLSession.shared.dataTask(with: url) { data, response, error in
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                    return
//                }
//
//                guard let data = data else {
//                    print("No data received")
//                    return
//                }
//
//                do {
//                    let decoder = JSONDecoder()
//                    let result = try decoder.decode(CocktailResponse.self, from: data)
//                    print(result)
//                    self.cocktails = result.drinks
//                    print("**********")
//                    print(self.cocktails.first)
//                    DispatchQueue.main.async {
//                        self.collectionView.reloadData()
//                    }
//                } catch {
//                    print("Error decoding JSON: \(error.localizedDescription)")
//                }
//            }.resume()
//        }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 100
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CocktailCollectionViewCell else {
//                fatalError("Failed to dequeue cell")
//            }
//        //let cocktail = cocktails[indexPath.item]
//        cell.drinkLabel.text = cocktails.first?.strDrink
//        cell.descriptionLabel.text = cocktails.first?.strDrinkThumb
//        // Set other properties of cell using cocktail data
//        return cell
//
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width / 2 - 10, height: 200)
//    }
//
//
//}

