//
//  RSSDownloader.swift
//  HelloMyRSSReader02
//
//  Created by 胡靜諭 on 2018/2/6.
//  Copyright © 2018年 胡靜諭. All rights reserved.
//

import UIKit

class RSSDownloader {
    
    typealias DoneHandler = ( _ error:Error?, _ item:[NewsItem]?)-> Void
    
   // func download(url:URL,doneHandler:(Error?, [Any]?)-> Void) {
        
    func download(url:URL,doneHandler:@escaping DoneHandler){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) {(data,response, error) in
            if let error = error {
                
                NSLog ("Download Fail: \(error)")
                doneHandler(error, nil)
                return
            }
            
            guard let data = data else {
                NSLog("Data is nil")
                let error = NSError(domain: "Data is nil", code: -1, userInfo: nil)
                doneHandler(error,nil)
                
                return
                }
            //Convert data to string content
            
            guard let content = String (data:data, encoding: .utf8) else {
                NSLog("Convert to string fail.")
                _ = NSError(domain: "Convert to string fail.", code: -2, userInfo: nil)
                return
            }
            print("RSS Content: \(content)")
            
//            Parse data
            
            let parser = XMLParser (data:data)
            let parserDelegate = RSSParserDelegate()
            parser.delegate = parserDelegate
            if parser.parse() {
                NSLog("Parse OK.")
                doneHandler(nil, parserDelegate.results)
            }else {
                NSLog("Parse Fail.")
                let error = NSError(domain:"Parse Fail.", code: -3, userInfo:nil)
                 doneHandler(error, nil)
            }
            }
        
        task.resume()
    }
}


// Define data struct of each news

struct NewsItem{
    
    var title:String?
    var link: String?
    var pubDate:String?
    
}
    
//    Define RSSParserDelegate,
    
class RSSParserDelegate: NSObject, XMLParserDelegate{
        
        private var currentItem: NewsItem?
        private var currentElementValue: String?
        fileprivate (set) var results = [NewsItem]()
        
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            
            // 碰到item開頭時 先建立空的 NewsItem 的物件 之後再補上物件的內容
            if elementName == "item" {
                currentItem = NewsItem()
            } else {
                // 如果標籤不是item 就把 標籤以外的東西(暫存區) 清空
                currentElementValue = nil
            }
        }
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            
            // currentElementValue 標籤以外的東西(暫存區) ex: <item>不是這種格式   標題 新聞內容
            // 如果是空 就給他 不是 要繼續貼資料 因為有可能資料過長 還沒到結尾 就結束的話 可能會擷取不到完整資料
            if currentElementValue == nil {
                currentElementValue = string
            } else {
                currentElementValue?.append(string)
            }
        }
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            //if let
            //只有 elementName == "item" 而且 currentItem != nil
            if elementName == "item", let item = currentItem {
                results.append(item)
                currentItem = nil
            } else if elementName == "title" {
                currentItem?.title = currentElementValue
            } else if elementName == "link" {
                currentItem?.link = currentElementValue
            } else if elementName == "pubDate" {
                currentItem?.pubDate = currentElementValue
            }
            // Prevent currrntElementValue be appended with any extra character.
//           有時候會把空白貼上 所以要加以下的才不會 有問題
            currentElementValue = nil
        }
}





