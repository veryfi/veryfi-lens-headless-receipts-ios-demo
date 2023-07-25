//
//  ViewController.swift
//  LensReceiptsDemo
//
//  Created by Diego Giraldo on 24/03/22.
//

import UIKit
import VeryfiLensHeadlessReceipts

class LogsViewController: UIViewController {
    @IBOutlet weak var logsTextView: UITextView!
    
    private var isLensConfigured = false
    private var topViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lens Logs"
        
        let CLIENT_ID = getEnvironmentVar(key: "VERYFI_CLIENT_ID") // replace with your assigned Client Id
        let AUTH_USERNAME = getEnvironmentVar(key: "VERYFI_USERNAME") // replace with your assigned Username
        let AUTH_APIKEY = getEnvironmentVar(key: "VERYFI_API_KEY") // replace with your assigned API Key
        let URL = getEnvironmentVar(key: "VERYFI_URL") // replace with your assigned Endpoint URL
        
        let credentials = VeryfiLensHeadlessCredentials(clientId: CLIENT_ID,
                                                        username: AUTH_USERNAME,
                                                        apiKey: AUTH_APIKEY,
                                                        url: URL)
        
        let settings = VeryfiLensReceiptSettings()
        
        VeryfiLensHeadless.shared().delegate = self
         
        VeryfiLensHeadless.shared().configure(with: credentials, settings: settings) { success in
            if !success {
                DispatchQueue.main.async { [weak self] in
                    let alertController = UIAlertController(title: "Wrong Credentials", message: "Please make sure correct credentials are used", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
            self.isLensConfigured = success
        }
    }
    
    func string(from json: [String : Any]) -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
        return String(data: jsonData!, encoding: .utf8)
    }
    
    //Func to get environment variables.
    func getEnvironmentVar(key: String) -> String {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }
    
    @IBAction func showLens(_ sender: Any) {
        if isLensConfigured {
           performSegue(withIdentifier: "showLens", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        topViewController = segue.destination
    }
}

extension LogsViewController: VeryfiLensHeadlessDelegate {
    func veryfiLensClose(_ json: [String : Any]) {
        if let receiptHeadless = topViewController as? HeadlessReceiptViewController {
            receiptHeadless.dismiss(animated: true)
            topViewController = nil
        }
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensError(_ json: [String : Any]) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensSuccess(_ json: [String : Any]) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
    
    func veryfiLensUpdate(_ json: [String : Any]) {
        if let string = string(from: json) {
            logsTextView.text.append("\n\(string)")
        }
    }
}

