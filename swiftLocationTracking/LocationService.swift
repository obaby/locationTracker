import UIKit
import CoreLocation
import RealmSwift
class LocationService: NSObject, CLLocationManagerDelegate
{
    var deferringUpdates: Bool = false
    var currentLocation: CLLocation!
    var locationManager:CLLocationManager?
    override init() {
        super.init()
        setUpLocationManager()
    }
    
    func setUpLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        if #available(iOS 9.0, *) {
            self.locationManager?.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.activityType = .AutomotiveNavigation
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = kCLDistanceFilterNone
    }
    func startLocationService() {
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopLocationService() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: AnyObject = (locations as NSArray).lastObject {
            if let loc = location as? CLLocation {
                print("Location update ---->>>> \(loc)")
                self.currentLocation = loc
            }
        }
        
        if (self.deferringUpdates == false) {
            self.locationManager?.allowDeferredLocationUpdatesUntilTraveled(100, timeout: CLTimeIntervalMax)
            self.deferringUpdates = true
            updateLocationToServer(self.currentLocation)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        self.deferringUpdates = false
    }
    func updateLocationToServer(location : CLLocation) {
        //API call to update vehicle location
        
        self.sendLocalNotification(String(format: "new location update with coordinate %@",location), interval: 1)
        
        self.addPingToDatabase(location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        
    }
    
    func sendLocalNotification(text : String,interval : NSTimeInterval)
    {
        
        //make the local notification
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow:interval)
        localNotification.alertBody = text
        localNotification.timeZone = NSTimeZone.localTimeZone()
        //set the notification
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        
        
    }
    
    func addPingToDatabase(latittude : Double? = nil,longitude : Double? = nil)
    {
        
        let realm = try! Realm() // 1
        try! realm.write { // 2
            let ping = pingData() // 3
            
            if latittude != nil
            {
                ping.latitude = latittude!
            }
            
            if longitude != nil
            {
                ping.longitude = longitude!
            }
            
            let df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            ping.time = df.stringFromDate(NSDate())
            
            realm.add(ping) // 5
        }
   
    }
    
}