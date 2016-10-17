//
//  GooglePlaces.swift
//
//  Created by Kirby Shabaga on 9/8/14.

// ------------------------------------------------------------------------------------------
// Ref: https://developers.google.com/places/documentation/search#PlaceSearchRequests
//
// Example search
//
// https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AddYourOwnKeyHere
//
// required parameters: key, location, radius
// ------------------------------------------------------------------------------------------

import CoreLocation
import Foundation
import MapKit

protocol GooglePlacesDelegate {
    
    func googlePlacesSearchResult(locationArray: [MKMapItem])
    
}

class GooglePlaces {
    
    let URL_NEARBY_SEARCH = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    let URL_NAME_SEARCH = "https://maps.googleapis.com/maps/api/place/textsearch/json?"

    let LOCATION = "location="
    let RADIUS = "radius="
    let QUERY = "query="
    var KEY = "key="
    
    var delegate : GooglePlacesDelegate? = nil
    
    // ------------------------------------------------------------------------------------------
    // init requires google.plist with key "places-key"
    // ------------------------------------------------------------------------------------------

    init() {
        let path = NSBundle.mainBundle().pathForResource("google", ofType: "plist")
        if path != nil {
            let google = NSDictionary(contentsOfFile: path!)
            if let apiKey = google!["places-key"] as? String {
                self.KEY = "\(self.KEY)\(apiKey)"
            } else {
                // TODO: Exception handling
               print("Exception: places-key is not set in google.plist")
            }
        } else {
            self.KEY = "\(self.KEY)AIzaSyDkIuJE7J81Xbksl7ilGhCKHiYtLbzQIRA"
        }
    }
    
    // ------------------------------------------------------------------------------------------
    // Google Places search with callback
    // ------------------------------------------------------------------------------------------

    func search(
        location : CLLocationCoordinate2D,
        radius : Int,
        query : String,
        callback : (items : [MKMapItem]?, errorDescription : String?) -> Void) {
        
        let urlEncodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let urlString = "\(URL_NEARBY_SEARCH)\(LOCATION)\(location.latitude),\(location.longitude)&\(RADIUS)\(radius)&\(KEY)&name=\(urlEncodedQuery!)"
            
        let url = NSURL(string: urlString)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            
        print(url)
        
        session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error != nil {
                callback(items: nil, errorDescription: error!.localizedDescription)
            }
            
            if let statusCode = response as? NSHTTPURLResponse {
                if statusCode.statusCode != 200 {
                    callback(items: nil, errorDescription: "Could not continue.  HTTP Status Code was \(statusCode)")
                }
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                callback(items: GooglePlaces.parseFromData(data!), errorDescription: nil)
            })
        }.resume()
    }
    
    func searchLocationName (
        query : String,
        callback : (items : [MKMapItem]?, errorDescription : String?) -> Void) {
            
            let urlEncodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            let urlString = "\(URL_NAME_SEARCH)\(KEY)&\(QUERY)\(urlEncodedQuery!)"
            
            let url = NSURL(string: urlString)
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            
            print(url)
            
            session.dataTaskWithURL(url!) { (data, response, error) -> Void in
                if error != nil {
                    callback(items: nil, errorDescription: error!.localizedDescription)
                }
                
                if let statusCode = response as? NSHTTPURLResponse {
                    if statusCode.statusCode != 200 {
                        callback(items: nil, errorDescription: "Could not continue.  HTTP Status Code was \(statusCode)")
                    }
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback(items: GooglePlaces.parseFromData(data!), errorDescription: nil)
                })
            }.resume()
    }
    
    
    // ------------------------------------------------------------------------------------------
    // Google Places search with delegate
    // ------------------------------------------------------------------------------------------
    
    func searchWithDelegate(
        location : CLLocationCoordinate2D,
        radius : Int,
        query : String) {
            
            self.search(location, radius: radius, query: query) { (items, errorDescription) -> Void in
                if self.delegate != nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.delegate!.googlePlacesSearchResult(items!)
                    })
                }
            }
            
    }
    
    func searchLocationNameWithDelegate (
        query : String) {
            
            self.searchLocationName(query) { (items, errorDescription) -> Void in
                if self.delegate != nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.delegate!.googlePlacesSearchResult(items!)
                    })
                }
            }
            
    }
    
    // ------------------------------------------------------------------------------------------
    // Parse JSON into array of MKMapItem
    // ------------------------------------------------------------------------------------------

    class func parseFromData(data : NSData) -> [MKMapItem] {
        var mapItems = [MKMapItem]()
        
        do {
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                print(jsonResult)
                
                let results = jsonResult["results"] as? Array<NSDictionary>
                
                for result in results! {
                    
                    let name = result["name"] as! String
                    
                    var coordinate : CLLocationCoordinate2D!
                    
                    if let geometry = result["geometry"] as? NSDictionary {
                        if let location = geometry["location"] as? NSDictionary {
                            let lat = location["lat"] as! CLLocationDegrees
                            let long = location["lng"] as! CLLocationDegrees
                            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            
                            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                            let mapItem = MKMapItem(placemark: placemark)
                            mapItem.name = name
                            mapItems.append(mapItem)
                        }
                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return mapItems
    }
    
}