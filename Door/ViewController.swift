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
    @IBOutlet var valueSlider: NSSlider!
    @IBOutlet var resultField: NSTextField!

    @objc var domDocument: DOMDocument?
    @objc var stringValue: String? {
        didSet {
            print("JGS - stringValue: \(stringValue)")
            //guard let document = webView.mainFrame.domDocument else { return }
            //document.setValue(stringValue, forKeyPath: "body.firstChild.data")
            setValue(sender: nil)
        }
    }
    @objc var doubleValue: Double = 0 {
        didSet {
            print("JGS - doubleValue: \(doubleValue)")
            //guard let document = webView.mainFrame.domDocument else { return }
            //document.setValue(stringValue, forKeyPath: "body.firstChild.data")
            setDoubleValue(sender: nil)
        }
    }
    @objc var colorValue: NSColor = .black {
        didSet {
            print("JGS - colorValue: \(colorValue)")
            setColorValue(sender: nil)
        }
    }

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

    @IBAction func setDoubleValue(sender: Any?) {
        guard let document = webView.mainFrame.domDocument else { return }
        let keyPath = pathField.stringValue
        let value = "\(doubleValue)px"
        document.setValue(value, forKeyPath: keyPath)
        let obj = document.value(forKeyPath: keyPath)
        let result = "\(String(describing: obj))"
        print("\(keyPath) -> \(result)")
        resultField.stringValue = result
    }

    @IBAction func setColorValue(sender: Any?) {
        guard let document = webView.mainFrame.domDocument else { return }
        let keyPath = pathField.stringValue
        let value = colorValue.cssString
        let components = keyPath.split(separator: ".")
        let prefix = components.dropLast()
        let added = prefix + ["color"]
        let newPath = added.joined(separator: ".")
        document.setValue(value, forKeyPath: newPath)
        let obj = document.value(forKeyPath: newPath)
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

extension DOMCSSStyleDeclaration {
    @objc var colorValue: NSColor {
        get {
            // "rgb(85, 85, 136)"
            guard let stringValue = color() else { return .black }
            return NSColor(cssString: stringValue)
        }
        set {
            print("JGS - color: \(newValue)")
            let stringValue = newValue.cssString
            setColor(stringValue)
        }
    }
}

extension NSColor {
    convenience init(cssString: String) {
        let stripped = cssString.trimmingCharacters(in: CharacterSet(charactersIn: "rgb()"))
        let components = stripped.components(separatedBy: ", ")
        let rInt = Int(components[0]) ?? 0
        let gInt = Int(components[1]) ?? 0
        let bInt = Int(components[2]) ?? 0
        self.init(red: CGFloat(rInt) / 255.0, green: CGFloat(gInt) / 255.0, blue: CGFloat(bInt) / 255.0, alpha: 1.0)
    }
    var cssString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rInt = Int(round(255.0 * r))
        let gInt = Int(round(255.0 * g))
        let bInt = Int(round(255.0 * b))
        let aInt = Int(round(255.0 * a))
        let stringValue = String(format: "rgb(%d, %d, %d)", rInt, gInt, bInt, aInt)
        return stringValue
    }
}
