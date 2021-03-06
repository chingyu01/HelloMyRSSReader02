//
//  MasterViewController.swift
//  HelloMyRSSReader02
//
//  Created by 胡靜諭 on 2018/2/6.
//  Copyright © 2018年 胡靜諭. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [NewsItem]()
    var serverReach: Reachability?
    let downloader = RSSDownloader()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        navigationItem.leftBarButtonItem = editButtonItem
//
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        navigationItem.rightBarButtonItem = addButton
        
        
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector (downloadNewsList))
        navigationItem.rightBarButtonItem = refreshBtn
        
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
        }
        
        //prepare serverReach
        serverReach = Reachability (hostName: "google.com")//Remember to offer DomainNmae not URL
        serverReach = Reachability.forInternetConnection()// Just comfirm if it is connected, not regrading to which Domain....it's often used...
        //        Reachbility(address:)
        
        //        automatically inspect the connection
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: .reachabilityChanged, object: nil)
        //        self -->ViewController
        
        serverReach?.startNotifier()
        
    }
    
    
    
    @objc func networkStatusChanged() {
        
        guard let status = serverReach?.currentReachabilityStatus() else{
            
            return
        }
        
        if status == NotReachable {
            NSLog("Network is not reachable")
        }
    }

    @objc  func downloadNewsList(){
        guard serverReach?.currentReachabilityStatus() != NotReachable else{
            return
        }
        let urlString = "https://tw.appledaily.com/rss/newcreate/kind/rnews/type/new"
        
        guard let url = URL (string:urlString) else {
            return
        }
        downloader.download(url:url) {(error, items) in
            if let error = error {
                NSLog("Downloader download fail:\(error)")
                return
            }
            guard let items = items else {
                return
            }
//            Use the items...
            self.objects = items
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
    }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }

//    @objc
//    func insertNewObject(_ sender: Any) {
//        objects.insert(NSDate(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] 
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        

        let item = objects[indexPath.row]
        cell.textLabel!.text = item.title
        cell.detailTextLabel?.text = item.pubDate
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

