//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by User on 3/26/17.
//  Copyright © 2017 TheSitePass. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    //var tableData = [Cell]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir", size: 16)!]


        // let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //let delButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteRecords(_:)))
        //self.navigationItem.rightBarButtonItem = addButton
        //self.navigationItem.rightBarButtonItem = delButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        deleteRecords()
        fetchAPIData()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchAPIData() {
        let url = URL(string: "https://newsapi.org/v1/articles?source=the-economist&sortBy=top&apiKey=29a4d7528657471baa4d0775f69c5664")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error as Any)
            } else {
                
                if let urlContent = data {
                    //process JSON here
                    do {
                        
                        var title = "not avail"
                        var url = "http://www.economist.com"
                        var pubDate = "2017-03-24T17:40:14Z"
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //var tempTableData = [Cell]()
                        if let allArticles = jsonResult["articles"] as? [NSDictionary]{
                            for i in 0...allArticles.count-1 {

                                title = allArticles[i]["title"] as! String!
                                url =  allArticles[i]["url"] as! String!
                                //pubDate = allArticles[i]["publishedAt"] as! String!
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                
                                
                                //let tempCell = Cell(title: title, url: url)
                                //tempTableData.append(tempCell)
                                //print("row: \(i) is \(tempTableData[i]) \n\n\n")
                                //save new data
                                let context = self.fetchedResultsController.managedObjectContext
                                let newEvent = Event(context: context)
                                
                                // If appropriate, configure the new managed object.
                                newEvent.title = title
                                newEvent.url = url
                                // newEvent.timestamp = dateFormatter.date(from: pubDate) as NSDate? not working
                                newEvent.timestamp = Date() as NSDate
                                print("PubDate: \(pubDate)")
                                print(newEvent.timestamp?.description)
                                print(newEvent)
                                
                                // Save the context.
                                do {
                                    try context.save()
                                } catch {
                                    // Replace this implementation with code to handle the error appropriately.
                                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
    
                            }
                            
                            self.tableView.reloadData()
                        
                        }

                        //DispatchQueue.main.sync(execute: {
                        //    self.tableData = tempTableData
                            //print(self.tableData)
                        //})

                        
                    } catch {
                        print("JSON Processing Failed")
                    }
                }
            }
        }
        task.resume()
    }

    func deleteRecords () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [Event]
        
        for object in resultData {
            context.delete(object)
        }
        
        do {
            try context.save()
            print("Delete saved")
        } catch let error as NSError {
            print(error)
        } catch {
            
        }
        
    }
    
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
             
        // If appropriate, configure the new managed object.
        newEvent.timestamp = NSDate()

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = self.fetchedResultsController.object(at: indexPath)
        self.configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent event: Event) {
        //cell.textLabel!.text = event.timestamp!.description
        cell.textLabel!.text = event.title?.description
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Event> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */
    
    struct Cell {
        var title: String!
        var url: String!
        var published: NSDate!
    }

}

