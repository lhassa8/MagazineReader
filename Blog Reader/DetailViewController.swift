//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by User on 3/26/17.
//  Copyright © 2017 TheSitePass. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {


    @IBOutlet weak var detailDescriptionLabel: UITextField!
    @IBOutlet weak var webView: UIWebView!

    var url = URL(string: "http://economist.com")

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                // label.text = detail.timestamp!.description
                label.text = detail.url!
                url = URL(string: detail.url!)
                navigationItem.title = detail.title
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        let request = URLRequest(url: url!)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir", size: 16)!]

        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    @IBAction func goForwardPressed(_ sender: Any) {
        if webView.canGoForward == true {
            webView.goForward()
        }
    }
    
    @IBAction func goBackPressed(_ sender: Any) {
        if webView.canGoBack == true {
            webView.goBack()
        }
    }


    

}
