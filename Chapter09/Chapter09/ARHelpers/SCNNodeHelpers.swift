//
//  SCNNodeHelpers.swift
//  Chapter09
//
//  Created by frank.zhang on 2019/8/14.
//  Copyright © 2019 Frank. All rights reserved.
//

import SceneKit

let surfaceLength: CGFloat = 3.0
let surfaceHeight: CGFloat = 0.1
let surfaceWidth: CGFloat = 3.0

let scaleX: Float = 2.0
let scaleY: Float = 2.0

let wallWidth: CGFloat = 0.1
let wallHeight: CGFloat = 3.0
let wallLength: CGFloat = 3.0

func createPlaneNode(center: vector_float3, extent: vector_float3) -> SCNNode{
    let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.4)
    plane.materials = [planeMaterial]
    
    let planeNode = SCNNode(geometry: plane)
    planeNode.position = SCNVector3Make(center.x, 0, center.z)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    return planeNode
}

func updatePlaneNode(_ node: SCNNode, center: vector_float3, extent: vector_float3){
    let geometry = node.geometry as? SCNPlane
    geometry?.width = CGFloat(extent.x)
    geometry?.height = CGFloat(extent.z)
    node.position = SCNVector3Make(center.x, 0, center.z)
}

func repeatTextures(geometry: SCNGeometry, scaleX: Float, scaleY: Float){
    let firstMaterial = geometry.firstMaterial
    let modeRepeat = SCNWrapMode.repeat
    firstMaterial?.diffuse.wrapS = modeRepeat
    firstMaterial?.selfIllumination.wrapS = modeRepeat
    firstMaterial?.normal.wrapS = modeRepeat
    firstMaterial?.specular.wrapS = modeRepeat
    firstMaterial?.emission.wrapS = modeRepeat
    firstMaterial?.roughness.wrapS = modeRepeat
    
    firstMaterial?.diffuse.wrapT = modeRepeat
    firstMaterial?.selfIllumination.wrapT = modeRepeat
    firstMaterial?.normal.wrapT = modeRepeat
    firstMaterial?.specular.wrapT = modeRepeat
    firstMaterial?.emission.wrapT = modeRepeat
    firstMaterial?.roughness.wrapT = modeRepeat
    
    firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    firstMaterial?.selfIllumination.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    firstMaterial?.normal.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    firstMaterial?.specular.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    firstMaterial?.emission.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    firstMaterial?.roughness.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
}

func makeOuterSurfaceNode(width: CGFloat, height: CGFloat, length: CGFloat) -> SCNNode{
    let outerSurface = SCNBox(width: surfaceWidth, height: surfaceHeight, length: surfaceLength, chamferRadius: 0)
    outerSurface.firstMaterial?.diffuse.contents = UIColor.white
    outerSurface.firstMaterial?.transparency = 0.000001
    let outerSurfaceNode = SCNNode(geometry: outerSurface)
    outerSurfaceNode.renderingOrder = 10
    return outerSurfaceNode
}

func makeFloorNode() -> SCNNode{
    let outerFloorNode = makeOuterSurfaceNode(width: surfaceWidth, height: surfaceHeight, length: surfaceLength)
    outerFloorNode.position = SCNVector3(surfaceHeight * 0.5, -surfaceHeight, 0)
    
    let floorNode = SCNNode()
    floorNode.addChildNode(outerFloorNode)
    
    let innerFloor = SCNBox(width: surfaceWidth, height: surfaceHeight, length: surfaceLength, chamferRadius: 0)
    innerFloor.firstMaterial?.lightingModel = .physicallyBased
    innerFloor.firstMaterial?.diffuse.contents = UIImage(named: "ARResource.scnassets/floor/textures/FloorDiffuse.png")
    innerFloor.firstMaterial?.normal.contents = UIImage(named: "ARResource.scnassets/floor/textures/FloorNormal.png")
    innerFloor.firstMaterial?.roughness.contents = UIImage(named: "ARResource.scnassets/floor/textures/FloorRoughness.png")
    innerFloor.firstMaterial?.specular.contents = UIImage(named: "ARResource.scnassets/floor/textures/FloorSpecular.png")
    innerFloor.firstMaterial?.selfIllumination.contents = UIImage(named: "ARResource.scnassets/floor/textures/FloorGloss.png")
    
    repeatTextures(geometry: innerFloor, scaleX: scaleX, scaleY: scaleY)
    
    let innerFloorNode = SCNNode(geometry: innerFloor)
    innerFloorNode.renderingOrder = 100
    innerFloorNode.position = SCNVector3(surfaceHeight * 0.5, 0, 0)
    floorNode.addChildNode(innerFloorNode)
    return floorNode
}

func makeCeilingNode() -> SCNNode{
    let outerCeilingNode = makeOuterSurfaceNode(width: surfaceWidth, height: surfaceHeight, length: surfaceLength)
    outerCeilingNode.position = SCNVector3(surfaceWidth * 0.5, surfaceHeight, 0)
    let ceilingNode = SCNNode()
    ceilingNode.addChildNode(outerCeilingNode)
    let innerCeiling = SCNBox(width: surfaceWidth, height: surfaceHeight, length: surfaceLength, chamferRadius: 0)
    innerCeiling.firstMaterial?.lightingModel = .physicallyBased
    innerCeiling.firstMaterial?.diffuse.contents = UIImage(named: "ARResource.scnassets/ceiling/textures/CeilingDiffuse.png")
    innerCeiling.firstMaterial?.emission.contents = UIImage(named: "ARResource.scnassets/ceiling/textures/CeilingEmis.png")
    innerCeiling.firstMaterial?.normal.contents = UIImage(named: "ARResource.scnassets/ceiling/textures/CeilingNormal.png")
    innerCeiling.firstMaterial?.specular.contents = UIImage(named: "ARResource.scnassets/ceiling/textures/CeilingSpecular.png")
    innerCeiling.firstMaterial?.selfIllumination.contents = UIImage(named: "ARResource.scnassets/ceiling/textures/CeilingGloss.png")
    repeatTextures(geometry: innerCeiling, scaleX: scaleX, scaleY: scaleY)
    
    let innerCeilingNode = SCNNode(geometry: innerCeiling)
    innerCeilingNode.renderingOrder = 100
    innerCeilingNode.position = SCNVector3(surfaceHeight * 0.5, 0, 0)
    ceilingNode.addChildNode(innerCeilingNode)
    return ceilingNode
}

func makeWallNode(length: CGFloat = wallLength, height: CGFloat = wallHeight, maskLowerSide: Bool = false) -> SCNNode{
    let outerWall = SCNBox(width: wallWidth, height: height, length: length, chamferRadius: 0)
    outerWall.firstMaterial?.diffuse.contents = UIColor.white
    outerWall.firstMaterial?.transparency = 0.000001
    let outerWallNode = SCNNode(geometry: outerWall)
    let multiplier: CGFloat = maskLowerSide ? -1 : 1
    outerWallNode.position = SCNVector3(wallWidth * multiplier, 0, 0)
    outerWallNode.renderingOrder = 10
    let wallNode = SCNNode()
    wallNode.addChildNode(outerWallNode)
    let innerWall = SCNBox(width: wallWidth, height: height, length: length, chamferRadius: 0)
    innerWall.firstMaterial?.lightingModel = .physicallyBased
    innerWall.firstMaterial?.diffuse.contents = UIImage(named: "ARResource.scnassets/wall/textures/WallsDiffuse.png")
    innerWall.firstMaterial?.metalness.contents = UIImage(named: "ARResource.scnassets/wall/textures/WallsMetalness.png")
    innerWall.firstMaterial?.roughness.contents = UIImage(named: "ARResource.scnassets/wall/textures/WallsRoughness.png")
    innerWall.firstMaterial?.normal.contents = UIImage(named: "ARResource.scnassets/wall/textures/WallsNormal.png")
    innerWall.firstMaterial?.specular.contents = UIImage(named: "ARResource.scnassets/wall/textures/WallsSpec.png")
    innerWall.firstMaterial?.selfIllumination.contents = UIImage(named: "ARResource.scnassets/wall/textures/WallsGloss.png")
    let innerWallNode = SCNNode(geometry: innerWall)
    innerWallNode.renderingOrder = 100
    wallNode.addChildNode(innerWallNode)
    return wallNode
}


