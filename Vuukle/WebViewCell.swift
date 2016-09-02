//
//  WebViewCell.swift
//  Vuukle Comment
//
//  Created by Орест on 01.09.16.
//  Copyright © 2016 Midgets. All rights reserved.
//

import UIKit

class WebViewCell: UITableViewCell ,UIWebViewDelegate {

    
    @IBOutlet weak var webView: UIWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let frameworkBundle = NSBundle(forClass: WebViewCell.self)
        
        let url1 = frameworkBundle.URLForResource("non_secure", withExtension:"html")
        if let htmlUrl = url1 {
            let request = NSURLRequest(URL: htmlUrl)
            webView.loadRequest(request)
            webView.delegate = self
            webView.frame = UIScreen.mainScreen().bounds
            getDataFromHtml()
        }
    }
    
    func getDataFromHtml () {
        let url1 = NSBundle(forClass: WebViewCell.self).URLForResource("non_secure", withExtension:"html")
        
        if let myURL = url1 {
            var error: NSError?
            let myHTMLString = try! NSString(contentsOfURL: myURL, encoding: NSUTF8StringEncoding)
            
            if let error = error {
                print("Error : \(error)")
            } else {
                let url = "\(myHTMLString)"
                let firstUrl = url.stringByReplacingOccurrencesOfString("[{PAGEURL}]", withString: "\(Global.articleUrl)", options: NSStringCompareOptions.LiteralSearch, range: nil)
                var secondUrl = firstUrl.stringByReplacingOccurrencesOfString("[{APPID}]", withString: "\(Global.appId)", options: NSStringCompareOptions.LiteralSearch, range: nil)
                var newUrl = secondUrl.stringByReplacingOccurrencesOfString("[{APPNAME}]", withString: "\(Global.appName)", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                let file = "non_secure.html"
                
                let text = "\(newUrl)"
                
                if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
                    
                    do {
                        try text.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
                    }
                    catch {}
                }
            }
        } else {
            print("Error: \(url1) doesn't  URL")
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            print(request.URL!)
            return false
        }
        return true
    }
    
    func htmlToText(encodedString:String) -> String?
    {
        let encodedData = encodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        do
        {
            return try NSAttributedString(data: encodedData, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil).string
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
