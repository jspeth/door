//
//  ViewController.swift
//  Door
//
//  Created by James Speth on 2/21/19.
//  Copyright © 2019 James Speth. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    @IBOutlet var urlField: NSTextField!
    @IBOutlet var webView: WebView!
    @IBOutlet var pathField: NSTextField!
    @IBOutlet var valueField: NSTextField!
    @IBOutlet var resultField: NSTextField!

    @objc var domDocument: DOMDocument?

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frameLoadDelegate = self

        pathField.stringValue = "body.firstChild.data"
        if let path = Bundle.main.path(forResource: "index", ofType: "html") {
            homeURL = URL(fileURLWithPath: path)
        }
        goHome(sender: nil)
    }

    var homeURL = URL(string: "https://www.apple.com/")

    @IBAction func goHome(sender: Any?) {
        guard let url = homeURL else { return }
        webView.mainFrame.load(URLRequest(url: url))
    }

    @IBAction func loadURL(sender: NSTextField) {
        guard let url = URL(string: sender.stringValue) else { return }
        webView.mainFrame.load(URLRequest(url: url))
    }

    @IBAction func getValue(sender: Any?) {
        guard let document = webView.mainFrame.domDocument else { return }
        let keyPath = pathField.stringValue
        let obj = document.value(forKeyPath: keyPath)
        let result = "\(String(describing: obj))"
        print("\(keyPath) -> \(result)")
        resultField.stringValue = result
    }

    // Example:
    // body.firstChild.data
    @IBAction func setValue(sender: Any?) {
        guard let document = webView.mainFrame.domDocument else { return }
        let keyPath = pathField.stringValue
        let value = valueField.stringValue
        document.setValue(value, forKeyPath: keyPath)
        let obj = document.value(forKeyPath: keyPath)
        let result = "\(String(describing: obj))"
        print("\(keyPath) -> \(result)")
        resultField.stringValue = result
    }
}

extension ViewController: WebFrameLoadDelegate {
    func webView(_ sender: WebView!, didReceiveTitle title: String!, for frame: WebFrame!) {
        guard frame == sender.mainFrame else { return }
        self.title = title
    }

    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        guard frame == sender.mainFrame else { return }
        urlField.stringValue = sender.mainFrameURL
        domDocument = frame.domDocument
    }
}
