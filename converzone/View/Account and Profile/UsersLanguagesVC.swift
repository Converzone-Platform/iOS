//
//  UsersLanguagesVC.swift
//  converzone
//
//  Created by Goga Barabadze on 08.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

enum addingFor {
    
    case speaking
    case learning
    
}

var addingForType: addingFor = .speaking

class UsersLanguagesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add a continue button
        if master?.changingData == .registration {
            guessSpeakLanguages()
            
            let continueButton = UIBarButtonItem(title: "Continue", style: .done, target: self, action: #selector(continuePressed))
            self.navigationItem.rightBarButtonItem = continueButton
        }
        
    }
    
    @objc func continuePressed(){
        
        // Check if there is at least one language selected which the master speaks
        if ((master?.speak_languages.count)! > 0){
            
            if master?.changingData == .registration {
                
                Navigation.push(viewController: "EditProfileVC", context: self)
                
            }else{
                Navigation.pop(context: self)
            }
            
            
        }else{
            
            //Display warning
            alert("At least one language", "Please select at least one language which you speak.", self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        master?.speak_languages.removeDuplicates()
        master?.learn_languages.removeDuplicates()
        
        master?.sortLanguagesAlphabetically()
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if master?.changingData == .editing{
            // Send languages
            Internet.database(url: Internet.baseURL + "/deleteAllLanguages.php", parameters: ["USERID" : master!.uid!]) { (backdata, response, error) in
                
                if error != nil{
                    print(error!.localizedDescription)
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode != 200{
                        print(httpResponse)
                    }
                    
                }
                
            }
            for language in master!.speak_languages{
                
                let language_data: [String : Any] = [
                    "USERID": master!.uid!,
                    "PROFICIENCY": "s",
                    "LANGUAGE": language.name
                ]
                
                Internet.database(url: Internet.baseURL + "/addLanguages.php", parameters: language_data) { (backdata, response, error) in
                    
                    if error != nil{
                        print(error!.localizedDescription)
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        if httpResponse.statusCode != 200{
                            print(httpResponse)
                        }
                        
                    }
                    
                }
            }
            for language in master!.learn_languages{
                
                let language_data: [String : Any] = [
                    "USERID": master!.uid!,
                    "PROFICIENCY": "l",
                    "LANGUAGE": language.name
                ]
                
                Internet.database(url: Internet.baseURL + "/addLanguages.php", parameters: language_data) { (backdata, response, error) in
                    
                    if error != nil{
                        print(error!.localizedDescription)
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        if httpResponse.statusCode != 200{
                            print(httpResponse)
                        }
                        
                    }
                    
                    
                }
            }
        }
    }
    
    func guessSpeakLanguages(){
        
        //The person probably speaks the languages of his device - add preferred languages
        if(master?.speak_languages.count != nil && (master?.speak_languages.count)! == 0 ){
            for language in NSLocale.preferredLanguages {
                
                let current = Locale(identifier: "en_US")
                
                let temp = Language(name: current.localizedString(forLanguageCode: language)!)
                
                master?.speak_languages.append(temp)
            }
        }
    }
    
}

extension UsersLanguagesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            return (master?.speak_languages.count)! + 1
        }
        
        return (master?.learn_languages.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = nil
        
        if(indexPath.section == 0 && indexPath.row == (master?.speak_languages.count) || indexPath.section == 1 && indexPath.row == (master?.learn_languages.count)){
            
            cell = tableView.dequeueReusableCell(withIdentifier: "AddLanguageCell")
            return cell!
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell")
            
        if(indexPath.section == 0){
            cell?.textLabel?.text = master?.speak_languages[indexPath.row].name
        }else{
            cell?.textLabel?.text = master?.learn_languages[indexPath.row].name
        }
        
        return cell!
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return NSLocalizedString("Languages you speak", comment: "A list of the languages the user selected which he/she speaks")
        }
        
        return NSLocalizedString("Languages you learn (optional)", comment: "A list of the languages the user selected which he/she is learning")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if(editingStyle == .delete){
            if(indexPath.section == 0){
                master?.speak_languages.remove(at: indexPath.row)
            }else{
                master?.learn_languages.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.section == 0 && indexPath.row == (master?.speak_languages.count)){ return false }
        if(indexPath.section == 1 && indexPath.row == (master?.learn_languages.count)){ return false }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0 && indexPath.row == (master?.speak_languages.count)){
            addingForType = .speaking
        }
        if(indexPath.section == 1 && indexPath.row == (master?.learn_languages.count)){
            addingForType = .learning
        }
        
        //Let the user select the language
        Navigation.push(viewController: "LanguagesVC", context: self)
    }

}