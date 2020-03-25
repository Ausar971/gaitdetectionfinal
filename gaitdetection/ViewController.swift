//
//  ViewController.swift
//  gaitdetection
//
//  Created by Ausar Mundra on 3/13/20.
//  Copyright © 2020 Immobile Computing. All rights reserved.
//

import UIKit
import CoreMotion
import Alamofire


class ViewController: UIViewController {

    
    @IBAction func recording(_ sender: Any) {
        let file = filenametext.text ?? "walkingdata"
        let geturl = "https://020adc43.ngrok.io/record/" + file
        print(geturl)
               AF.request(geturl).responseData{
                   response in
                   debugPrint(response)
               }
        myAccelerometer()
        //myGyroscope()
    }
    
    @IBAction func stoprecord(_ sender: Any) {
        let file = filenametext.text ?? "walkingdata"
        let filefull  = file + ".csv"
        
        print(filefull)
        
        let geturl = "https://020adc43.ngrok.io/stop_record"
               print(geturl)
               AF.request(geturl).responseData{
                   response in
                   debugPrint(response)
               }
        
     let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fURL = dir.appendingPathComponent(filefull)
            
            do {
                try self.recordeddata.write(to: fURL, atomically: true, encoding: .utf8)
                //try ytext.write(to: fileURL, atomically: false, encoding: .utf8)
                //try ztext.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                print(error.localizedDescription)
            }
        senddata()
        
    }
    
    @IBOutlet weak var filenametext: UITextField!
    @IBOutlet weak var savebutton: UIButton!
    @IBAction func save(_ sender: Any) {
        let filename = filenametext.text ?? "walkingdata"
            print(filename)
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fURL = dir.appendingPathComponent(filename)
            
            do {
                try self.recordeddata.write(to: fURL, atomically: true, encoding: .utf8)
                //try ytext.write(to: fileURL, atomically: false, encoding: .utf8)
                //try ztext.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                print(error.localizedDescription)
            }
        
        
        
        
        
        
        senddata()
        
    }
    var motion = CMMotionManager()
    
    
   
    var recordeddataacel: String = ""
    var recordeddatagyro: String = ""
    var recordeddata: String = "accel_x, accel_y, accel_z" + "\n" //gyro_x, gyro_y, gyro_z" + "\n"
    
    
    var save = false
    
    
    override func viewDidLoad() {
        
    }
    
    
    

    
    
    func senddata(){
        
        let file = filenametext.text ?? "walkingdata"
        let fullfile = file + ".csv"
        
   
        
        //File In accessible iPhone directory
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fURL = dir.appendingPathComponent(fullfile)

        
        print(fURL)
        //----------------------------------------------------------------------------------------------
        
        
       
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(fURL, withName: fullfile)
            },
            to: "https://020adc43.ngrok.io/senddata").responseData {
            response in
            debugPrint(response)
        }
        
      
    }

    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    
    func myAccelerometer() {
        print("Start Accelerometer")
        
        
        motion.accelerometerUpdateInterval = 0.5
        motion.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data, error) in
            print(data as Any)
            
            //if(self.save == false){
            
            if let trueData =  data {
                
                self.view.reloadInputViews()
                let x = trueData.acceleration.x
                let y = trueData.acceleration.y
                let z = trueData.acceleration.z
                
                
                
                let xtext = "\(Double(x).rounded(toPlaces: 3))"
                let ytext = "\(Double(y).rounded(toPlaces: 3))"
                let ztext = "\(Double(z).rounded(toPlaces: 3))"
            
                let dataa = xtext + " ," + ytext + " ," + ztext + "\n"
            
                
                self.recordeddata = self.recordeddata + dataa
                //self.recordeddataacel = self.recordeddataacel + dataa
            
                print(self.recordeddataacel)
               
                
                }
            }
  
        
    
        
        return
    }

    
    func myGyroscope(){
        print("Start Gyroscope")
        motion.gyroUpdateInterval = 0.5
        motion.startGyroUpdates(to: OperationQueue.current!) {
            (data, error) in
            print(data as Any)
            //if(self.save == false){
            if let trueData =  data {
                
                self.view.reloadInputViews()
                
                let xtext2 = "\(Double(trueData.rotationRate.x).rounded(toPlaces: 3))"
                let ytext2 = "\(Double(trueData.rotationRate.y).rounded(toPlaces: 3))"
                let ztext2 = "\(Double(trueData.rotationRate.z).rounded(toPlaces: 3))"
                
                
                let datta = xtext2 + " ," + ytext2 + " ," + ztext2 + "\n"
                
                self.recordeddata = self.recordeddata + datta
                
                }
            }

        return
        }
 
}

extension Double {
     func rounded(toPlaces places:Int) -> Double {
         let divisor = pow(10.0, Double(places))
         return (self * divisor).rounded()
     }
 }
 
 
extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

