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
    
    public init(other: Triangle, c0: CLLocation) {
        self.init(c0: c0, c1: other.c1, c2: other.c2)
    }
    public init(other: Triangle, c2: CLLocation) {
        self.init(c0: other.c0, c1: other.c1, c2: c2)
    }
    mutating public func calcArea()  {
        let a = c0.distance(from: c1)
        let b = c1.distance(from: c2)
        let c = c2.distance(from: c0)
        let p = (a+b+c)/2
        
        self.area = sqrt(p*(p-a) * (p-b) * (p-c))
    }
}

typealias CoordinateTripple = (CLLocation?, CLLocation?,CLLocation?)

let createTriangles: ([CoordinateTripple], CLLocation) -> [CoordinateTripple] = { r, cNew in
    var result = r
    let lastTriangle = r.last
    let newTuple:CoordinateTripple = (lastTriangle?.1, lastTriangle?.2, c2:cNew)
    result.append(newTuple)
    return result
}

let removeMin: (Double) -> (([Triangle], Triangle)->[Triangle]) =  { min in
    var newC0 :CLLocation?
    
    return { r, triangleIn in
        var triangles = r
        if  triangleIn.area! > min {
            if let c0 = newC0 {
                var newTriangle = Triangle(other: triangleIn, c0:c0)
                newC0 = nil
                triangles.append(newTriangle)
            } else {
                triangles.append(triangleIn)
            }
        } else {
            if let newTriangle = triangles.last {
                triangles[triangles.count-1] = Triangle(other:newTriangle, c2:triangleIn.c2)
            }
            newC0 = triangleIn.c0
        }
        return triangles
    }
}

enum NoElementsError: Error {
    case NoElements
}

public struct LineSimplificator {
    private var triangles: [Triangle]
    public init(_ coordinates:[CLLocationCoordinate2D]) {
        triangles = coordinates
            .map{ CLLocation(latitude:$0.latitude, longitude:$0.longitude)}
            .reduce([], createTriangles)
            .map { tuple in
                guard let c0 = tuple.0, let c1 = tuple.1, let c2 = tuple.2
                    else { return nil }
                return Triangle(c0: c0, c1: c1, c2: c2) }
            .flatMap { $0 }
    }
    
    public mutating func simplify(tolerance: Double) -> [CLLocationCoordinate2D] {
        var minArea = -1.0
        while (minArea < tolerance ){
           minArea = triangles.flatMap{$0.area}
                .reduce(Double.infinity, min)
            print("minArea: \(minArea)")
            guard minArea < tolerance else { break }
            triangles = triangles.reduce([],removeMin(minArea))
           
        }
        
        var reducedCoordinates = triangles.map { $0.c0.coordinate }
        if let last = triangles.last {
            reducedCoordinates.append(last.c1.coordinate)
            reducedCoordinates.append(last.c2.coordinate)
        }
    
        return reducedCoordinates
    }
}
