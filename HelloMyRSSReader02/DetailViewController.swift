//
//  DetailViewController.swift
//  HelloMyRSSReader02
//
//  Created by 胡靜諭 on 2018/2/6.
//  Copyright © 2018年 胡靜諭. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet var mainWebView: WKWebView!
    
    func configureView() {
        // Update the user interface for the detail item.
       // if let detail = detailItem {
            //            if let label = detailDescriptionLabel {
            //                label.text = detail.description
        
        guard let item = detailItem else{
            return
//
            }
        
        guard let webView = mainWebView else {
            return
        }
        guard let link = item.link else{
            return
        }
        guard let url = URL(string: link) else {
            return
        }
        let request = URLRequest (url: url)
        webView.load(request)
        self.title = item.title // SHOW NEWS TITLE
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NewsItem? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

