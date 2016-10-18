import Foundation
import CoreLocation

public protocol Area {
    var area:Double? {get}
}

public struct Triangle: Area {
    public var c0: CLLocation
    public var c1: CLLocation
    public var c2: CLLocation
    public var area:Double?
}

extension Triangle {

    public init(c0: CLLocation, c1:CLLocation, c2:CLLocation) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        calcArea()
    }
    
    mutating public func calcArea()  {
        let a = c0.distance(from: c1)
        let b = c1.distance(from: c2)
        let c = c2.distance(from: c0)
        let p = (a+b+c)/2
        
        self.area = sqrt(p*(p-a) * (p-b) * (p-c))
    }
}
