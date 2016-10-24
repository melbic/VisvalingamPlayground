import UIKit
import PlaygroundSupport
import MapKit

PlaygroundPage.current.needsIndefiniteExecution = true

//PlaygroundTestObserver.observe()
//TestRunner(TriangleTests.self).run()

enum MapViewDelegateError:Error {
    case unsupportedOverlayKind
}
class MapViewDelegate:NSObject, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard(overlay is MKPolyline) else {
            let r = MKPolygonRenderer(overlay:overlay)
            r.strokeColor = UIColor.white
            r.lineWidth = 1
            return r
        }
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        let color : UIColor
        let lineWidth : Float
        if let title = overlay.title , title == "Reduced" {
            lineWidth = 1
            color = UIColor.red
        } else {
            color = UIColor.blue
            lineWidth = 3
        }
        
        
        
        polylineRenderer.strokeColor = color
        polylineRenderer.lineWidth = CGFloat(lineWidth)
        return polylineRenderer
    
    }
}


let frame = CGRect( x:0, y:0, width:  400, height:600)

let mapView = MKMapView(frame:frame)

PlaygroundPage.current.liveView = mapView
let center = CLLocationCoordinate2D(latitude:47.368336381620345, longitude:8.518940246409496)

let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
mapView.setRegion(region, animated: false)
let delegate =  MapViewDelegate()
mapView.delegate = delegate

let input = [[8.518940246409496,47.368336381620345],[8.518714940852211,47.36869970309936],[8.519476688212407,47.3688668301392],[8.518854415720982,47.36963706095784],[8.51865056783587,47.36992771117395],[8.518446719950756,47.370240158369846],[8.518446719950756,47.37037094966961],[8.51755622655797,47.370603466734806],[8.51960543424509,47.3717442387348],[8.518918788737322,47.372318248434794],[8.51960543424509,47.37273966930006],[8.521150386637473,47.37149719466227],[8.522266185587458,47.37198401569832],[8.522867000406709,47.372231057490424],[8.523414171045705,47.3723981733403],[8.523854053324008,47.372441768692376],[8.52587107450296,47.372834125239194],[8.525849616830875,47.372957644288476],[8.525956905191476,47.3730157708003],[8.526310956781355,47.373902192160806],[8.527694976632885,47.37482492643777],[8.52704051763329,47.37539890260625]].map{($0[0],$0[1])}
var coordinates = input.map { CLLocationCoordinate2D(latitude: $0.1, longitude:$0.0)}

let path = MKPolyline(coordinates:&coordinates, count: coordinates.count)
mapView.add(path, level: .aboveRoads)

typealias CoordinateTripple = (CLLocation?, CLLocation?,CLLocation?)

let appendCoordinates: ([CoordinateTripple], CLLocation) -> [CoordinateTripple] = { r, cNew in
    var result = r
    let lastTriangle = r.last
    let newTuple:CoordinateTripple = (lastTriangle?.1, lastTriangle?.2, c2:cNew)
    result.append(newTuple)
    return result}


let removeMin: (Double) -> (([Triangle], Triangle)->[Triangle]) =  { minimum in
    var newC0 :CLLocation?

    return { r, t in
            var rr = r
    if  t.area! > minimum {
        if let c0 = newC0 {
            var tt = t
            tt.c0 = c0
            newC0 = nil
            rr.append(tt)
        } else {
            rr.append(t)
        }
    } else {
        if var l = rr.last {
            l.c2 = t.c2
        }
        newC0 = t.c0
    }
    return rr
    }
}

var triangles:[Triangle] = coordinates
    .map{ CLLocation(latitude:$0.latitude, longitude:$0.longitude)}
    .reduce([(nil,nil,nil)], appendCoordinates)
    .map { tuple in
        guard let c0 = tuple.0, let c1 = tuple.1, let c2 = tuple.2
            else { return nil }
        return Triangle(c0: c0, c1: c1, c2: c2) }
    .flatMap { $0 }


for i in 0...6 {
   triangles = triangles.map {
        var t = $0
        t.calcArea()
        return t
        }
    let minArea = triangles.flatMap{$0.area}.reduce(Double.infinity, min)
    print("Smallest area is:\(minArea)")
    triangles = triangles.reduce([],removeMin(minArea))
}

enum NoElementsError: Error {
    case NoElements
}
var reducedCoordinates = triangles.map { $0.c0.coordinate }
guard let last = triangles.last else {throw  NoElementsError.NoElements }

reducedCoordinates.append(last.c1.coordinate)
reducedCoordinates.append(last.c2.coordinate)

reducedCoordinates.count

//let polygons:[MKPolygon] = triangles.flatMap{
//    if let a = $0.c0?.coordinate, let b = $0.c1?.coordinate, let c = $0.c2?.coordinate {
//        var t = [a,b, c]
//        return MKPolygon(coordinates:&t, count:3)
//    }
//    return nil
//}

print(reducedCoordinates.count)

let reducedPath = MKPolyline(coordinates:&reducedCoordinates, count: reducedCoordinates.count)
reducedPath.title = "Reduced"

mapView.add(reducedPath, level: .aboveRoads)

