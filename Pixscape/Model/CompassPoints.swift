import UIKit
import SceneKit

final class CompassPoints: NSObject {
    
    var angle: Float
    var distance: Int
    var name: String
    
    init(angle: Float, distance: Int, name: String) {
        self.angle = angle
        self.distance = distance
        self.name  = name
        
        super.init()
    }
    
    lazy var sphere: SCNNode = {
        let sphere                      = SCNSphere(radius: 1.5)
        let sphereMaterial              = SCNMaterial()
        sphereMaterial.diffuse.contents = self.name == "Scape North" ? UIColor.primary : UIColor.red
        let node                        = SCNNode(geometry: sphere)
        node.geometry?.materials        = [sphereMaterial]
        node.transform                  = CompassPoints.transform(rotationY: GLKMathDegreesToRadians(self.angle), distance: self.distance)
        return node
    }()
    
    lazy var text: SCNNode = {
        let textBlock                             = SCNText(string: "\(name)", extrusionDepth: 0.5)
        textBlock.font                            = UIFont (name: "AvenirNext-DemiBold", size: 6)
        textBlock.firstMaterial?.diffuse.contents = UIColor.white
        textBlock.flatness                        = 0.25
        let node                                  = SCNNode(geometry: textBlock)
        node.transform                            = CompassPoints.transform(rotationY: GLKMathDegreesToRadians(self.angle), distance: self.distance)
        return node
    }()
    
    static func transform(rotationY: Float, distance: Int) -> SCNMatrix4 {
        // Translate first on -z direction
        let translation = SCNMatrix4MakeTranslation(0, 0, Float(-distance))
        // Rotate (yaw) around y axis
        let rotation    = SCNMatrix4MakeRotation(-1 * rotationY, 0, 1, 0)
        // Final transformation: TxR
        let transform   = SCNMatrix4Mult(translation, rotation)
        return transform
    }
}
