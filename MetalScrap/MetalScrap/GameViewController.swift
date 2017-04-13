
import Cocoa
import MetalKit
import simd


///////////////////////////////////////////////////
/////////////        Matrices     ////////////////
/////////////////////////////////////////////////

func rotationZ(rad: Float) -> float4x4 {
    return float4x4([
        float4( cos(rad), sin(rad), 0, 0),
        float4(-sin(rad), cos(rad), 0, 0),
        float4(        0,        0, 1, 0),
        float4(        0,        0, 0, 1)])
}

func rotationY(rad: Float) -> float4x4 {
    return float4x4([
        float4( cos(rad), 0, -sin(rad), 0),
        float4(        0, 1,         0, 0),
        float4( sin(rad), 0, cos(rad),  0),
        float4(        0,        0, 0,  1)])
}

func translation(tx: Float, ty: Float, tz: Float) -> float4x4{
    return float4x4([
        float4(1,0,0,0),
        float4(0,1,0,0),
        float4(0,0,1,0),
        float4(tx,ty,tz,1)
        ])
}
func projectionMatrix(rad: Float, ar: Float, nearZ:Float, farZ: Float) -> float4x4 {
    let tanHalfFOV = tan(rad/2)
    let zRange = nearZ - farZ
    
    return float4x4([
        float4((1/tanHalfFOV),0,0,0),
        float4(0,(1/tanHalfFOV*ar),0,0),
        float4(0,0,((-nearZ-farZ)/zRange), 1),
        float4(0,0,((farZ*nearZ)/zRange),0)
        ])
}

class GameViewController: NSViewController, MTKViewDelegate {
    
    // needed for overall rendering
    var device: MTLDevice! = nil
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var depthStencilState: MTLDepthStencilState! = nil
    
    // buffers
    var vertexPositionBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var instanceBuffers: [MTLBuffer] = []
    var textureCoordinateBuffer: MTLBuffer! = nil
    
    // textures and meshes
    var texture: MTLTexture! = nil
    var mtkMesh: MTKMesh! = nil
    
    // specific object variables
    let instanceCount = 5
    var cowRotations:[Float] = []
    var cowTranslations:[float3] = []
    
    // used for frames
    let maximumInflightFrames = 3
    var currentFrameIndex = 0
    var frameSemaphore: DispatchSemaphore! = nil
    
    
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
    
    ///////////////////////////////////////////////////
    /////////////        Assets       ////////////////
    /////////////////////////////////////////////////

    
    func loadAssets() {
        
        let view = self.view as! MTKView
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"
        let textureLoader = MTKTextureLoader(device:device)
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
        pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;        pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat
        pipelineStateDescriptor.sampleCount = view.sampleCount
        
        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
        
        
        let allocator = MTKMeshBufferAllocator(device: device)
        
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 24, bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 32)
        
        let assetURL = Bundle.main.url(forResource: "spot", withExtension: "obj")!
        let mdlAsset = MDLAsset(url: assetURL, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)
        let mdlMesh = mdlAsset[0] as! MDLMesh
        
        mtkMesh = try! MTKMesh(mesh: mdlMesh, device: device)
        
        cowRotations = [Float](repeatElement(0, count: instanceCount))
        cowTranslations = [float3](repeatElement(float3(), count: instanceCount))
        
        var buffers = [MTLBuffer]()
        for _ in 0..<maximumInflightFrames {
            buffers.append(device.makeBuffer(length: MemoryLayout<float4x4>.stride * instanceCount, options: []))
        }
        instanceBuffers = buffers
        
        for i in 0..<instanceCount {

            cowRotations[i] = Float(drand48() * Double.pi * 2 );
            cowTranslations[i] = float3(Float(drand48()*7-3.5), Float(drand48()*7-3.5), Float(drand48()*7-3.5))
        }
        
        
        // depth buffering
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.isDepthWriteEnabled = true
        depthDescriptor.depthCompareFunction = .less
        depthStencilState = device.makeDepthStencilState(descriptor: depthDescriptor)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()
        blitEncoder.generateMipmaps(for: texture)
        blitEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        
        // GPU Stop
        frameSemaphore = DispatchSemaphore(value: maximumInflightFrames)
    }
    
    ///////////////////////////////////////////////////
    /////////////      Location       ////////////////
    /////////////////////////////////////////////////
    func update(timestep: Float){
        let contents = instanceBuffers[currentFrameIndex].contents().bindMemory(to: float4x4.self, capacity: instanceCount)
        
        for i in 0..<instanceCount {
            let position = cowTranslations[i]
            let modelMatrix = translation(tx: position.x,ty: position.y, tz: position.z) * rotationY(rad: cowRotations[i])
            cowRotations[i] += 3 * timestep; // 3radians per second
            contents[i] = modelMatrix;

        }
       
    }
    
    ///////////////////////////////////////////////////
    /////////////       Drawing       ////////////////
    /////////////////////////////////////////////////

    func draw(in view: MTKView) {
        
        update(timestep: (1/Float(view.preferredFramesPerSecond)))
        frameSemaphore.wait()
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.label = "Frame command buffer"
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder.label = "render encoder"
            
            
            let inverseTranslate = translation(tx:0, ty:0, tz:9)
            let projection = projectionMatrix(rad: Float.pi/2, ar: Float(self.view.bounds.size.width/self.view.bounds.size.height), nearZ:0.1, farZ:1000);
            var viewProjectionMatrix = projection * inverseTranslate
            
            renderEncoder.pushDebugGroup("draw morphing cows")
            renderEncoder.setRenderPipelineState(pipelineState)
            
            
            renderEncoder.setVertexBuffer(mtkMesh.vertexBuffers.first!.buffer, offset: mtkMesh.vertexBuffers.first!.offset, at: 0)
            renderEncoder.setVertexBuffer(instanceBuffers[currentFrameIndex], offset: 0, at: 1)
            renderEncoder.setVertexBytes(&viewProjectionMatrix, length: MemoryLayout<float4x4>.size, at: 3)
            renderEncoder.setFragmentTexture(texture, at: 0)
            
            renderEncoder.setDepthStencilState(depthStencilState)
            
            
            let submesh =  mtkMesh.submeshes.first!
            
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset:submesh.indexBuffer.offset,
                instanceCount:instanceCount)
            
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
            
            commandBuffer.present(currentDrawable)
        }
        
        currentFrameIndex = (currentFrameIndex+1) % maximumInflightFrames
        commandBuffer.addCompletedHandler { commandBuffer in
            self.frameSemaphore.signal()
        }
        commandBuffer.commit()
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}
