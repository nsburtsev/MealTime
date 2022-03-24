//
//  ViewController.swift
//  MealTime
//
//  Created by Нюргун on 22.03.2022.
//  Copyright © 2022 Нюргун. All rights reserved.
//


import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var context: NSManagedObjectContext!
    var user: User!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //Создаем объект
        let meal = Meal(context: context)
        //Присваиваем meal текущую дату
        meal.date = Date()
        //Создаем копию user.meals для того чтобы добавить туда объект. Добавляем новый прием пищи.
        let meals = user.meals?.mutableCopy() as? NSMutableOrderedSet
        meals?.add(meal)
        //Присваиваем юзеру новый массив
        user.meals = meals
        
        do {
            try context.save()
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //Проверяем наличие данных и если они есть - отображаем
        let userName = "Max"
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        //Задаем предикат (для получения данных для конкретного юзера)
        fetchRequest.predicate = NSPredicate(format: "name == %@", userName)
        
        //Пробуем получить данные
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                user = User(context: context)
                user.name = userName
                try context.save()
            } else {
                user = results.first
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My happy meal time"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.meals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        guard let meal = user.meals?[indexPath.row] as? Meal,
            let mealDate = meal.date
            else { return cell }
        
        cell.textLabel!.text = dateFormatter.string(from: mealDate)
        return cell
    }
}

