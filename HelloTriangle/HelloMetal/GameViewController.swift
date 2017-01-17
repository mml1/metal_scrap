
import Cocoa
import MetalKit
import simd

//// triangle shape
//let vertexPositionData:[Float] =
//[
//    -0.0,   0.25, 0.5, 1.0,
//    -0.25, -0.25, 0.5, 1.0,
//     0.25, -0.25, 0.5, 1.0
//]
//// triangle color
//let vertexColorData:[Float] =
//[
//    0.0, 0.0, 1.0, 1.0,
//    0.0, 0.0, 0.0, 1.0,
//    1.0, 0.0, 0.0, 1.0
//]
// used to center the photo image one the triangle
//let vertexTextCoords:[Float] =
//    [
//        0.5, 0,
//        0, 1,
//        1,1
//]

// square shape
let vertexPositionData:[Float] =
    [
        0.0, 1.0, 0.5, 1.0,
        1.0, 1.0, 0.5, 1.0,
        0.0, 0.0, 0.5, 1.0,
        1.0, 0.0, 0.5, 1.0,
        0.0, 0.0, 0.5, 1.0,
        1.0, 1.0, 0.5, 1.0,
        0.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 0.5, 1.0,
        0.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.5, 1.0,
        0.0, 1.0, 0.5, 1.0,
        0.0, 1.0, 0.5, 1.0,
        0.0, 0.0, 0.5, 1.0,
        0.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.5, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.5, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.5, 1.0,
        1.0, 0.0, 0.5, 1.0,
        1.0, 0.0, 0.0, 1.0,
        1.0, 1.0, 0.5, 1.0,
        1.0, 0.0, 0.5, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 0.0, 0.5, 1.0,
        1.0, 0.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0
]
// square color
let vertexColorData:[Float] =
    [
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0
]

// used to center the photo image one the triangle
let vertexTextCoords:[Float] =
[
    0, 0,
    1, 0,
    0, 1,
    1, 1,
    0, 1,
    1, 0,
    0, 0,
    1, 0,
    0, 1,
    1, 1,
    0, 1,
    1, 0,
    0, 0,
    1, 0,
    0, 1,
    1, 1,
    0, 1,
    1, 0
    
]

func rotationZ(rad: Float) -> float4x4 {
    return float4x4([
        float4( cos(rad), sin(rad), 0, 0),
        float4(-sin(rad), cos(rad), 0, 0),
        float4(        0,        0, 1, 0),
        float4(        0,        0, 0, 1)])
}

// rotation y

func rotationY(rad: Float) -> float4x4 {
    return float4x4([
        float4( cos(rad), 0, -sin(rad), 0),
        float4( 0, 1, 0, 0),
        float4(        sin(rad),0, cos(rad), 0),
        float4(        0,        0, 0, 1)])
}

// translation function
func translation(tx: Float, ty: Float, tz: Float) -> float4x4{
    return float4x4([
        float4(1,0,0,0),
        float4(0,1,0,0),
        float4(0,0,1,0),
        float4(tx,ty,tz,1)
        ])
}
// projection matrix
func projectionMatrix(rad: Float, ar: Float, nearZ:Float, farZ: Float) -> float4x4 {
    let tanHalfFOV = tan(rad/2)
    let zRange = nearZ - farZ
    
    //col major so program expects the columns
    return float4x4([
        float4((1/tanHalfFOV),0,0,0),
        float4(0,(1/tanHalfFOV*ar),0,0),
        float4(0,0,((-nearZ-farZ)/zRange), 1),
        float4(0,0,((farZ*nearZ)/zRange),0)
        ])
}

class GameViewController: NSViewController, MTKViewDelegate {
    
    //member variables
    var device: MTLDevice! = nil
    var startTime: TimeInterval = 0
    var texture: MTLTexture! = nil // first make a texture member variable
    var textureCoordinateBuffer: MTLBuffer! = nil // fourth  make texture buffer
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var vertexPositionBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    
    var mtkMesh: MTKMesh! = nil
    var depthStencilState: MTLDepthStencilState! = nil


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()

        // setup view properties
        let view = self.view as! MTKView
        view.delegate = self
        view.device = device
        view.sampleCount = 4
        view.depthStencilPixelFormat = .depth32Float_stencil8
        loadAssets()
    }
    
    func loadAssets() {
        
        // load any resources required for rendering
        let view = self.view as! MTKView
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"
        let textureLoader = MTKTextureLoader(device:device) // second, load loader
        let URL = Bundle.main.url(forResource: "spot_texture", withExtension: "png")
        let options = [MTKTextureLoaderOptionOrigin : MTKTextureLoaderOriginBottomLeft as NSObject,
                       MTKTextureLoaderOptionAllocateMipmaps : true as NSObject]
        texture = try! textureLoader.newTexture(withContentsOf: URL!, options: options)
        
        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "passThroughFragment")!
        let vertexProgram = defaultLibrary.makeFunction(name: "passThroughVertex")!
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat // expect to write to a depth map
        pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat // not using it yet but needed for build, helps restrict geometry in other geometry
        pipelineStateDescriptor.sampleCount = view.sampleCount
        
        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }

        let vertexPositionSize = vertexPositionData.count * MemoryLayout<Float>.size
        vertexPositionBuffer = device.makeBuffer(bytes: vertexPositionData, length: vertexPositionSize, options: [])
        vertexPositionBuffer.label = "vertices"
        
        let vertexColorSize = vertexColorData.count * MemoryLayout<Float>.size
        vertexColorBuffer = device.makeBuffer(bytes: vertexColorData, length: vertexColorSize, options: [])
        vertexColorBuffer.label = "colors"
        
    
        // load asset fifth
        let vertexTextCoordSize = vertexTextCoords.count * MemoryLayout<Float>.size
        textureCoordinateBuffer = device.makeBuffer(bytes: vertexTextCoords, length: vertexTextCoordSize, options: [])
        textureCoordinateBuffer.label = "texture coodrinates"

        startTime = CACurrentMediaTime()
        
        let allocator = MTKMeshBufferAllocator(device: device)
        
        // creating mesh 121116, switching over to interleaved buffer that stores all the properities
//        let mdlMesh = MDLMesh.init(boxWithExtent: vector_float3(1,1,1), segments: vector_uint3(2,2,2), inwardNormals: false, geometryType: .triangles, allocator: allocator)
        
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 24, bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 32)
        
        let assetURL = Bundle.main.url(forResource: "spot", withExtension: "obj")!
        let mdlAsset = MDLAsset(url: assetURL, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)
        let mdlMesh = mdlAsset[0] as! MDLMesh
    
        mtkMesh = try! MTKMesh(mesh: mdlMesh, device: device)
        
        // depth buffering
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.isDepthWriteEnabled = true // will not want for particle drawing, since drawing everything opaque
        depthDescriptor.depthCompareFunction = .less // if it is closer to the camera overwrite
        depthStencilState = device.makeDepthStencilState(descriptor: depthDescriptor)

        let commandBuffer = commandQueue.makeCommandBuffer()
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()
        blitEncoder.generateMipmaps(for: texture)
        blitEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func draw(in view: MTKView) {
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.label = "Frame command buffer"
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder.label = "render encoder"
            
            
            let time = Float(CACurrentMediaTime()-startTime)

            let degreesToRadians = Float(M_PI / 180.0)

//            let rotationMatrix = rotationZ(rad: 0 * time * degreesToRadians)
            let rotationMatrix = rotationY(rad: 100 * time * degreesToRadians)

            let translate = translation(tx:0, ty:0,tz:-0.5)
            let inverseTranslate = translation(tx:0, ty:0, tz:0.5 * time)
            
            //projection matrix
            let projection = projectionMatrix(rad: Float.pi/2, ar: Float(self.view.bounds.size.width/self.view.bounds.size.height), nearZ:0.1, farZ:1000);
            
            //if I don't have the translate it will orbit around me lol
            var modelProjectMatrix = projection * inverseTranslate * rotationMatrix * translate

            renderEncoder.pushDebugGroup("draw morphing triangle")
            renderEncoder.setRenderPipelineState(pipelineState)
            
            //Location of vertex data for render call
//            renderEncoder.setVertexBuffer(vertexPositionBuffer, offset: 0, at: 0)
//            renderEncoder.setVertexBuffer(vertexColorBuffer, offset:0 , at: 1)
//            renderEncoder.setVertexBuffer(textureCoordinateBuffer, offset: 0, at: 2)
            
            renderEncoder.setVertexBuffer(mtkMesh.vertexBuffers.first!.buffer, offset: mtkMesh.vertexBuffers.first!.offset, at: 0)
            //passing to shader, passing by address is the &
            renderEncoder.setVertexBytes(&modelProjectMatrix, length: MemoryLayout<float4x4>.size, at: 3)
            
            
            // step 3 adding to texture bucket (argument table)
            renderEncoder.setFragmentTexture(texture, at: 0)
            
            //
            renderEncoder.setDepthStencilState(depthStencilState)
            
            // used to draw the triangle or traingle strip
            //renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
            //            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 36, instanceCount: 1)
            
            let submesh =  mtkMesh.submeshes.first!
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset:submesh.indexBuffer.offset)
            
            
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
            
            commandBuffer.present(currentDrawable)
        }

        commandBuffer.commit()
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}
