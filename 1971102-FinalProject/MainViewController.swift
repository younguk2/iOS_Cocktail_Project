//
//  MainViewController.swift
//  1971102-FinalProject
//
//  Created by mac004 on 2024/06/04.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var cocktailPickerView: UIPickerView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var bestCocktail: [BestCocktail]!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "cocktailData", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                bestCocktail = try JSONDecoder().decode([BestCocktail].self, from: data)
                // Use your cities array here
            } catch {
                // Handle error
                print("Error loading JSON:", error)
            }
        } else {
            print("JSON file not found")
        }
        cocktailPickerView.dataSource = self
        cocktailPickerView.delegate = self
        
        cocktailPickerView.selectRow(0, inComponent: 0, animated: true)
        descriptionLabel.text = bestCocktail[0].description

        // Do any additional setup after loading the view.
    }
    

    @IBAction func searchCocktail(_ sender: UIButton) {
        performSegue(withIdentifier: "detail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "detail" {
                if let destinationVC = segue.destination as? DetailCocktailViewController {
                    // TextField 내용을 DetailCocktailViewController로 전달
                    destinationVC.cocktailName = textField.text
                }
            }
        }
}
extension MainViewController : UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        return bestCocktail.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let nameLabel = UILabel()
        nameLabel.text = bestCocktail[row].name
        nameLabel.textAlignment = .center
        let imageView = UIImageView(image: bestCocktail[row].uiImage())
        var outer = UIStackView(arrangedSubviews: [imageView,nameLabel])
        outer.axis = .vertical
        return outer
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return cocktailPickerView.frame.size.height / 2
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        descriptionLabel.text = bestCocktail[row].description
    }
}



extension MainViewController{
    func getSelectedCity() -> String{
        return bestCocktail[cocktailPickerView.selectedRow(inComponent: 0)].name
    }
}
