//
//  FClient.swift
//  VirtualTourist
//
//  Created by stephen on 9/11/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation

// Implement HTTP Methods for Flickr API
class FClient {
    // MARK: Singleton Declaration
    static let sharedInstance = FClient()
    private init(){}
    
    // MARK: This Region is for HTTPS Request Methods and Higher Logic Handling
    
    // request image data based on stringUrl, and change to Data as ret variable
    func taskForRequestImageData(filePath: String, completionHandlerForRequestImageData: @escaping (_ imageData: Data?, _ errorString: String? ) -> Void)  -> URLSessionTask{
        let url = URL.init(string: filePath)
        let request = URLRequest.init(url: url!)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                let err = "There was an error with your request: \(error!)"
                completionHandlerForRequestImageData(nil, err)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let err = "Your request returned a status code other than 2xx!"
                completionHandlerForRequestImageData(nil, err)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let err = "No data was returned by the request!"
                completionHandlerForRequestImageData(nil, err)
                return
            }
            
            completionHandlerForRequestImageData(data, nil)
            
        }
        
        task.resume()
        return task
        
        
    }
    
    // this is the public function for request flickr data(in string url) based on longtitude & latitude
    func requestImageUrlSet( longtitude: Double, latitude: Double, completionHandlerForRequestData: @escaping(_ dataSet: [String]?, _ errorString: String? ) -> Void) {
        
        // load default parameters
        var methodParameters: [String: AnyObject] = [:]
        loadMethodParameters(methodParameters: &methodParameters)
        
        // add the longtitude & latitude argument
        
//        methodParameters[VConstant.FlickrParameterKeys.BoundingBox]
//            = getBBox(longtitude: longtitude, latitude: latitude) as AnyObject
        let latitude = latitude.rounded(toPlaces: 2)
        let longtitude = longtitude.rounded(toPlaces: 2)
        
        methodParameters[VConstant.FlickrParameterKeys.Latitude] = latitude as AnyObject
        methodParameters[VConstant.FlickrParameterKeys.Longitude] = longtitude as AnyObject
        
        getPageLimitFromFlickr(methodParameters) { (pageLimit, errorString) in
            // successful
            if (errorString == nil ){
                let randomPage = arc4random_uniform(UInt32(pageLimit!)) + 1
                
                self.getImageUrlFromFlickr(methodParameters, pageNumber: Int(randomPage), completionHandlerForGetData: { (dataSet, errorString) in
                    if(errorString == nil) {
                        
                        // successful
                        completionHandlerForRequestData(dataSet!, nil)
                    } else {
                        // failed to get data on that particular page
                        completionHandlerForRequestData(nil, errorString!)
                    }
                })
                
            }
            else {
                completionHandlerForRequestData(nil, errorString!)
            }
        }
        
    }

    
    
    func getPageLimitFromFlickr(_ methodParameters: [String: AnyObject],
                                            completionHandlerForGetPageLimit: @escaping( _ pageLimit: Int?, _ errorString: String? )->Void) {
        let session = URLSession.shared
        let url = flickrURLFromParameters(methodParameters)
        let request = URLRequest(url: url)
        
        
        let taskPage = session.dataTask(with: request) { (data, response, error) in
            func displayError(_ error:String){
                DebugM.log( "url at time of error:\(url)" )
                completionHandlerForGetPageLimit(nil, error)
            }
            
            guard (error == nil) else{
                displayError("error is:" + (error?.localizedDescription)!)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                displayError("Your request returned a status code other than 2xx ")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // Parse the data
            let parsedResult:[String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                
            }
            catch{
                displayError("Could not parse the data as JSON: \(data)")
                return
            }
            guard let photosDictionary = parsedResult[VConstant.FlickrResponseKeys.Photos] as? [String:AnyObject] else{
                displayError("Could not find \(VConstant.FlickrResponseKeys.Photos)")
                return
            }
            
            
            guard let pageCount = photosDictionary[VConstant.FlickrResponseKeys.Pages] as? Int else {
                displayError("Coult not parse the page number")
                return
            }
            
            let pageLimit = min(pageCount, 40)
            completionHandlerForGetPageLimit(pageLimit, nil)
            //let randomPage = arc4random_uniform(UInt32(pageLimit)) + 1
            
        }
        
        
        taskPage.resume()
        
        // TODO: Make request to Flickr!
    }
    
    // given a randomPageNumber
    func  getImageUrlFromFlickr( _ methodParameters: [String: AnyObject], pageNumber: Int, completionHandlerForGetData: @escaping( _ photoStrDataSet:[String]?, _ errorString: String? )->Void){
        let session = URLSession.shared
        // Add additional argument to generate the new url
        
        var methodParameters = methodParameters
        methodParameters[VConstant.FlickrResponseKeys.Pages] = pageNumber as AnyObject
        
        let url = flickrURLFromParameters(methodParameters)
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            func displayError(_ error:String){
                print(error)
                print("url at time of error:", url)
            }
            
            guard (error == nil) else{
                displayError("error is:" + (error?.localizedDescription)!)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                displayError("Your request returned a status code other than 2xx ")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // Parse the data
            let parsedResult:[String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                
            }
            catch{
                displayError("Could not parse the data as JSON: \(data)")
                return
            }
            
            guard let photosDictionary = parsedResult[VConstant.FlickrResponseKeys.Photos] as? [String:AnyObject],
                let photoArray = photosDictionary[VConstant.FlickrResponseKeys.Photo] as?
                    [[String:AnyObject]]
                
                else {
                    displayError("Could not find the key \(VConstant.FlickrResponseKeys.Photos) or the key \(VConstant.FlickrResponseKeys.Photo)")
                    return
            }
            
            if(photoArray.count == 0){
                // return empty array
                completionHandlerForGetData([], nil)
            }
            else{

                
                // initialize imageDataSet: ignore warning as it's being passed to func addImage
                var imageStrDataSet = [String]()
                
                if photoArray.count <= VConstant.Flickr.MaxPhotoLimit {
                    
                    for photo in photoArray {
                        guard let imageUrlString = photo[VConstant.FlickrResponseKeys.MediumURL] as? String else {
                            // handle error
                            return
                        }
                        imageStrDataSet.append(imageUrlString)
                    }
                    
                } else {
                    // select random offset
                    let randomPhotoOffSet = Int(arc4random_uniform(UInt32(photoArray.count)))
                    var count = 0
                    while ( count < VConstant.Flickr.MaxPhotoLimit ) {
                        let photoIndex = (randomPhotoOffSet + count) % (photoArray.count)
                        let photo = photoArray[photoIndex]
                        
                        guard let imageUrlString = photo[VConstant.FlickrResponseKeys.MediumURL] as? String else {
                            // handle error
                            return
                        }
                        imageStrDataSet.append(imageUrlString)
                        count += 1;
                    }
                    
                }
                // successfully return this data
                completionHandlerForGetData(imageStrDataSet, nil)
            }
        }
        
        task.resume()
        
    }
    
    
    // MARK: Helper for Creating a URL from Parameters
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        
        components.scheme = VConstant.Flickr.APIScheme
        components.host = VConstant.Flickr.APIHost
        components.path = VConstant.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}

// MARK: Helper Functions
extension FClient {
    
    // MARK: Return Proper Formatted Lattidue and Longtitude Format as specified by Flickr
    func getBBox(longtitude: Double, latitude: Double)->String{
    
        let latitude = latitude.rounded(toPlaces: 2)
        let longtitude = longtitude.rounded(toPlaces: 2)
        print("latitude \(latitude), longtitude \(longtitude)")
    
        let latitudeMin = max( VConstant.Flickr.SearchLatRange.0, latitude - VConstant.Flickr.SearchBBoxHalfHeight )
        let latitudeMax = min( VConstant.Flickr.SearchLatRange.1, latitude + VConstant.Flickr.SearchBBoxHalfHeight)
        
        
        let longtitudeMin = max( VConstant.Flickr.SearchLonRange.0, longtitude - VConstant.Flickr.SearchBBoxHalfWidth )
        let longtitudeMax = min( VConstant.Flickr.SearchLonRange.1, longtitude + VConstant.Flickr.SearchBBoxHalfWidth )
        
        print(String(longtitudeMin) + "," + String(latitudeMin) + "," + String(longtitudeMax) + ","  + String(latitudeMax))
        
        return String(longtitudeMin) + "," + String(latitudeMin) + "," + String(longtitudeMax) + ","  + String(latitudeMax)
        
    }

    
    
    // MARK: method Parametesr Load
    func loadMethodParameters( methodParameters:inout [String: AnyObject]){
        
        methodParameters[VConstant.FlickrParameterKeys.Extras] = VConstant.FlickrParameterValues.MediumURL as AnyObject
        methodParameters[VConstant.FlickrParameterKeys.SafeSearch] = VConstant.FlickrParameterValues.UseSafeSearch as AnyObject
        methodParameters[VConstant.FlickrParameterKeys.APIKey] = VConstant.FlickrParameterValues.APIKey as AnyObject
        methodParameters[VConstant.FlickrParameterKeys.Format] = VConstant.FlickrParameterValues.ResponseFormat as AnyObject
        methodParameters[VConstant.FlickrParameterKeys.NoJSONCallback] = VConstant.FlickrParameterValues.DisableJSONCallback as AnyObject
        methodParameters[VConstant.FlickrParameterKeys.Method] = VConstant.FlickrParameterValues.SearchMethod as AnyObject
        
    }
    
    
}



