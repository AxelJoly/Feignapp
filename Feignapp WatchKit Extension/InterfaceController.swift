//
//  InterfaceController.swift
//  TrainApp WatchKit Extension
//
//  Created by Joly Axel on 27/01/2018.
//  Copyright © 2018 Axel. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON
import WatchConnectivity
import EMTLoadingIndicator


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var loadingImage: WKInterfaceImage!
    @IBOutlet var switchButton: WKInterfaceButton!
    @IBOutlet var travelsTable: WKInterfaceTable!
    
    var state: boolean_t = 0
    var dataArray: NSMutableArray = NSMutableArray()
    var travels: [TravelStruct] = []
    var hours: [String] = [String]()
    var city1: StationStruct = StationStruct(name: "Sanary", latitude: "43.12254507", longitude: "5.82503447")
    var city2: StationStruct = StationStruct(name: "Toulon", latitude: "43.12831598", longitude: "5.92945828")
    var count: Int = 0
    var session : WCSession!
    var indicator: EMTLoadingIndicator?
    var env: Environment = Environment()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let defaults = UserDefaults.standard
        if(defaults.string(forKey: "nbJourney") != nil ){
            self.count = Int(defaults.string(forKey: "nbJourney")!)!
            print("Count value: \(self.count)");
        }else{
            self.count = 5
        }
        
        if( (defaults.string(forKey: "arrivalName") != nil) && (defaults.string(forKey: "departureName") != nil) && (defaults.string(forKey: "departureLat") != nil) && (defaults.string(forKey: "departureLon") != nil) && (defaults.string(forKey: "arrivalLat") != nil) && (defaults.string(forKey: "arrivalLon") != nil)){
       
           self.city1 = StationStruct(name: defaults.string(forKey: "departureName")!, latitude: defaults.string(forKey: "departureLat")!, longitude: defaults.string(forKey: "departureLon")!)
            self.city2 = StationStruct(name: defaults.string(forKey: "arrivalName")!, latitude: defaults.string(forKey: "arrivalLat")!, longitude: defaults.string(forKey: "arrivalLon")!)
            self.switchButton.setTitle("To \(city2.name)")
        }
        urlRequest(departure: self.city1, arriving: self.city2)
    }
    
    // Init session between the Watch app and iOS app
    override func willActivate() {
        super.willActivate()
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        direction()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    // Call the sendMessage method after clicking on TableView cell.
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.sendMessage(index: rowIndex)
    }
   
   @IBAction func switchDirection() {
       if(state == 1){
            urlRequest(departure: self.city1, arriving: self.city2)
            state = 0
            switchButton.setTitle("To \(city2.name)")
        }else if(state == 0){
            urlRequest(departure: self.city2, arriving: self.city1)
            state = 1
            switchButton.setTitle("To \(city1.name)")
        }
    }
    
    // Url request to SNCF api and set data in TravelStruct object.
    func urlRequest(departure: StationStruct, arriving: StationStruct){
        indicator = EMTLoadingIndicator(interfaceController: self, interfaceImage: loadingImage!,
                                        width: 40, height: 40, style: .dot)
        indicator?.showWait()
        var travels = [TravelStruct]()
        let user = self.env.SNCF_TOKEN
        let password = ""
        var headers: HTTPHeaders = [:]
        print("Count value: \(count)")
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        Alamofire.request("https://api.sncf.com/v1/coverage/sncf/journeys?from=\(departure.longitude)%3B\(departure.latitude)&to=\(arriving.longitude)%3B\(arriving.latitude)&count=\(self.count)&", headers: headers)
         .responseJSON { response in
            if let json = response.result.value {
                let values = JSON(json)
                self.hours = []
                let journeys = values["journeys"]
                for i in 0...journeys.count {
                    let departureDateTime = journeys[i]["departure_date_time"]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+1")
                    let dateFormatterMessage = DateFormatter()
                    dateFormatterMessage.dateFormat = "HH:mm"
                    let date: Date = dateFormatter.date(from: departureDateTime.stringValue)!
                    let direction = journeys[i]["sections"][1]["display_informations"]["direction"].stringValue
                    let travel = TravelStruct(direction: direction, departure_date: date)
                    let finalDateStr:String = dateFormatterMessage.string(from: travel.departure_date)
                    if travels.count < 10 {
                        if(travel.direction != ""){
                        travels.append(travel)
                        self.hours.append(finalDateStr)
                        }
                    }
                }
                  self.setupTable(travels: travels, direction: arriving.name)
            }
        }
    }
    
    // Display the TableView with journeys data.
    func setupTable(travels: [TravelStruct], direction: String) {
        travelsTable.setNumberOfRows(travels.count, withRowType: "TravelRow")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd - HH:mm"
       
        for i in 0...travels.count {
            if let row = travelsTable.rowController(at: i) as? TravelRow {
                let finalDateStr:String = dateFormatter.string(from: travels[i].departure_date)
                row.date.setText(String (describing: finalDateStr))
                if city1.name == direction{
                    row.departure.setText(city2.name)
                    row.arrival.setText(city1.name)
                }else {
                    row.departure.setText(city1.name)
                    row.arrival.setText(city2.name)
                }
            }
        }
        indicator?.hide()
    }
    
    // Establish session between the Watch App and iOS App. Retrieve how much journey you want from iOS UITextfield.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let value = message["nbJourney"] as? String
        let departure = message["departureName"] as? String
        let arrival = message["arrivalName"] as? String
        let departureLat = message["departureLat"] as? String
        let departureLon = message["departureLon"] as? String
        let arrivalLat = message["arrivalLat"] as? String
        let arrivalLon = message["arrivalLon"] as? String

        DispatchQueue.main.async { () -> Void in
            self.count = Int(value!)!
            let defaults = UserDefaults.standard
            let nbJourney = value!
            defaults.set(nbJourney, forKey: "nbJourney")
            defaults.set(departure, forKey: "departureName")
            defaults.set(arrival, forKey: "arrivalName")
            defaults.set(departureLat, forKey: "departureLat")
            defaults.set(arrivalLat, forKey: "arrivalLat")
            defaults.set(departureLon, forKey: "departureLon")
            defaults.set(arrivalLon, forKey: "arrivalLon")
            self.city1 = StationStruct(name: departure!, latitude: departureLat!, longitude: departureLon!)
            self.city2 = StationStruct(name: arrival!, latitude: arrivalLat!, longitude: arrivalLon!)
            self.switchButton.setTitle("To \(self.city2.name)")
            self.direction()
        }
    }
    
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    // Determine the direction of the journey.
    func direction(){
        if(self.state == 1){
            urlRequest(departure: self.city2, arriving: self.city1)
        }else{
            urlRequest(departure: self.city1, arriving: self.city2)
        }
    }
    
    // Open the Message App and send a message which contains the hour of the departure.
    func sendMessage(index: Int){
        let messageBody = "Mon train est a \(self.hours[index])"
        let urlSafeBody = messageBody.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        if let urlSafeBody = urlSafeBody, let url = NSURL(string: "sms:\(self.env.PHONE_NUMBER)&body=\(urlSafeBody)") {
            WKExtension.shared().openSystemURL(url as URL)
        }
    }
}

