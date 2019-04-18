//
//  ViewController.swift
//  D07
//
//  Created by Volodymyr KOZHEMIAKIN on 1/24/19.
//  Copyright © 2019 Volodymyr KOZHEMIAKIN. All rights reserved.
//

import UIKit
import RecastAI
import ForecastIO

var random : Int = 0

class ViewController: UIViewController {
    var bot : RecastAIClient?
    // put the tokens recovered on the sites of the developers
    let RECASTAI_TOKEN = "2e4038371c9608cb6fe85505fc255cea"
    let FORECASTIO_TOKEN = "0a244f3c897fc6a2753617903a7bb4ca"
    
    //var imageWeather : String
    
    let dict = [
        "Overcast" : "1.png",
        "Mostly Cloudy" : "1.png",
        "Partly Cloudy" : "2.png",
        "Clear" : "33.png",
        "Sunny" : "33.png",
        "Drizzle" : "4.png",
        "Breezy" : "4.png",
        "Rainy" : "4.png",
        "Rain" : "4.png",
        "Snow" :  "5.png" ,
        "Snowy" : "5.png",
        "Light Snow" : "6.png",
        "Cloudy" : "1.png",
         "Drizzle and Windy" : "4.png",
        "8.png" : "8.png"
    ]
    
    // "Partly Cloudy" , "Light Rain", "Light Snow"
    
    
    @IBOutlet weak var answer: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    
    @IBOutlet weak var question: UITextField!
    
    @IBAction func goButton(_ sender: UIButton) {
        print("prepare called")
        print("content of the text field : \(String(describing: question.text))")
        guard let myString = question.text, !myString.isEmpty else {
            print("String is nil or empty.")
            return
        }
        makeRequest(request : question.text ?? "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bot = RecastAIClient(token : RECASTAI_TOKEN, language: "en")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    //  Make text request to Recast.AI API
    func makeRequest(request: String) {
        //Call makeRequest with string parameter to make a text request
        self.bot?.textRequest(request, successHandler: recastRequestDone, failureHandle: processError)
    }
    
    /**
     Method called when the request was successful
     - parameter response: the response returned from the Recast API
     - returns: void
     */
    func recastRequestDone(_ response : Response) {
        print("recastRequestDone: \(response)")
        if let location = response.get(entity: "location") {
            print(location)
            //answer.text = "Location found : \(location["raw"]!), processing in progress..."
            callForecast(location: location["raw"] as! String, lat: location["lat"] as! Double, lng: location["lng"] as! Double)
        }
        else {
            DispatchQueue.main.async { // you have to go back to the main thread to touch the display
                random = Int(arc4random_uniform(3))
                if random == 0 {
                    self.answer.text = "I don't know fucking city"
                    self.weatherLabel.text = ""
                    self.tempLabel.text = ""
                    self.cityLabel.text = ""
                    self.weatherImage.image = UIImage(named: self.dict["8.png"] ?? "")
                } else if random == 1 {
                    self.answer.text = "Sorry, I didn't get it"
                    self.weatherLabel.text = ""
                    self.tempLabel.text = ""
                    self.cityLabel.text = ""
                    self.weatherImage.image = UIImage(named: self.dict["8.png"] ?? "")
                } else {
                    self.answer.text = "... be more creative, I know you can !"
                    self.weatherLabel.text = ""
                    self.tempLabel.text = ""
                    self.cityLabel.text = ""
                    self.weatherImage.image = UIImage(named: self.dict["8.png"] ?? "")
                }
            }
        }
    }
    
    func processError(_ err: Error) {
        DispatchQueue.main.async { // you have to go back to the main thread to touch the display
            print("processError : \(err)")
            self.answer.text = "Error"
        }
    }
    
    func callForecast(location: String, lat: Double, lng: Double){
        print("callForecast")
        let client = DarkSkyClient(apiKey: FORECASTIO_TOKEN)
        client.units = .si
        
        client.getForecast(latitude: lat, longitude: lng) { result in
            DispatchQueue.main.async { // you have to go back to the main thread to touch the display
                switch result {
                case .success(let currentForecast, let requestMetadata):
                    //  We got the current forecast!
                    print("we received an answer")
                    print("currentForecast : \(currentForecast)")
                    print("requestMetadata : \(requestMetadata)")
                    for all in self.dict {
                        if (currentForecast.currently?.summary ?? "").contains(all.key) {
                            self.weatherImage.image = UIImage(named: all.value)
                            break
                        }
                    }
                    self.weatherImage.image = UIImage(named: self.dict[(currentForecast.currently?.summary ?? "")] ?? "")
                    self.weatherLabel.text = currentForecast.currently?.summary
                    self.tempLabel.text = String(describing: ((Int)((currentForecast.currently?.temperature)!))) + " °C" // int
                    self.cityLabel.text = location
                    self.answer.text = ""
//                    self.answer.text = location + " : " + (currentForecast.currently?.summary)! + " Current temperature : " + String(describing: (currentForecast.currently?.temperature)!) + " °C"
                case .failure(let error):
                    // We have an error!
                    print("Error : \(error)")
                    self.answer.text = "Error"
                }
                
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        print("prepare called")
    }
}


