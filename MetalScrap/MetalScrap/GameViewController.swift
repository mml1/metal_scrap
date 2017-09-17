
import Cocoa
import MetalKit
import simd


///////////////////////////////////////////////////
/// Structs needed for Ray-Sphere Interaction ////
/////////////////////////////////////////////////

struct Sphere {

    public var center:float3 = float3(0,0,0)
    public var radius:Float = 0
    
    public init(_center: float3, _radius: Float) {
        center = _center
        radius = _radius
    }
    public init() {}
    
}

struct Ray {
    public var point:float3 = float3(0.0,0.0,0.0)
    public var direction:float3 = float3(0.0,0.0,0.0)
    
    public init(_point: float3, _direction: float3) {
        point = _point
        direction = _direction
    }
    public init(){}
}


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


func perspectiveMatrix(rad: Float, ar: Float, nearZ:Float, farZ: Float) -> float4x4 {
    let tanHalfFOV = tan(rad/2)
    let zRange = nearZ - farZ
    
    return float4x4([
        float4((1/tanHalfFOV),0,0,0),
        float4(0,(1/tanHalfFOV*ar),0,0),
        float4(0,0,((-nearZ-farZ)/zRange), 1),
        float4(0,0,((farZ*nearZ)/zRange),0)
        ])
}

func nonUniformScale(xs: Float, ys: Float) -> float4x4 {
    return float4x4([
        float4(xs,0,0,0),
        float4(0,ys,0,0),
        float4(0, 0, 1,0),
        float4(0, 0, 0,1)
        ])

}
// Helper fxns

func expn(num:Float) ->Float{
    return num*num
}
func raySphereInterection(ray: Ray, sphere: Sphere) -> Bool {
    print("Inside raySpehere fxn");
    // B = 2 * (Xd * (X0 - Xc) + Yd * (Y0 - Yc) + Zd * (Z0 - Zc))
    // C = (X0 - Xc)^2 + (Y0 - Yc)^2 + (Z0 - Zc)^2 - Sr^2

    // Shorten variables for ray and sphere
    let rPt = ray.point
    let rDr = ray.direction
    let sc = sphere.center
    let sr = sphere.radius
    
//    print(rDr.x,rDr.y,rDr.z)
//    print((rPt.x - sc.x),(rPt.y - sc.y),(rPt.z - sc.z))
//    
    // Creating the quadratic formula
    let b = 2 * ((rDr.x * (rPt.x - sc.x)) + (rDr.y * (rPt.y - sc.y)) + (rDr.z * (rPt.z - sc.z)))
//    let c = ((rPt.x - sc.x)*(rPt.x - sc.x)) + ((rPt.y - sc.y)*(rPt.y - sc.y)) + ((rPt.z - sc.z)*(rPt.z - sc.z))-(sr*sr)
    let c = expn(num:(rPt.x - sc.x)) + expn(num:(rPt.y - sc.y)) + expn(num:(rPt.z - sc.z)) - expn(num:sr)

    
//    print(b,c)
    let radicand = expn(num:b)-(4*c)

    print(b*b,c)
    // Did the ray intersect the sphere
    if radicand >= 0 {
    
        let tO = (-1*b + sqrt(radicand))/2
        if tO >= 0{
            return true
        }
        
        return false
    } else {
        
        return false
    }
    
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
    let instanceCount = 1
    var cowRotations:[Float] = []
    var cowTranslations:[float3] = []
    
    var cowBoundingSphere:Sphere = Sphere()
    var rayForIntersection:Ray = Ray()
    var rayNearMouse:Ray = Ray()
    var rayFarMouse:Ray = Ray()
    var hit:Bool = false
    
    // used for frames
    let maximumInflightFrames = 3
    var currentFrameIndex = 0
    var frameSemaphore: DispatchSemaphore! = nil

    // matrix properties
    var projectionMatrix:float4x4 = float4x4()
    var viewMatrix:float4x4 = float4x4()


    
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
    
    func inverseViewPort(windowCoordinate: NSPoint, z:Float) -> float4{
        
        let windowWidth = Float(self.view.bounds.size.width)
        let windowHeight = Float(self.view.bounds.size.height)
        
        // scale windowCoordinates to normalized
        
        let flip = nonUniformScale(xs: 0.5, ys: 0.5)
        let originTranslation = translation(tx: 0.5, ty: 0.5, tz: 0)
        let viewPortScale = nonUniformScale(xs: windowWidth, ys: windowHeight)
        
        let viewPortTransform = viewPortScale * originTranslation * flip
        
        let inverseViewPortTransform = viewPortTransform.inverse
        
        let mouseCoordWindow = float4(Float(windowCoordinate.x), Float(windowCoordinate.y), z,1)
        
        
        return inverseViewPortTransform * mouseCoordWindow
    }
    
    ////////////////
    //Creating Ray//
    ////////////////
    

    override func mouseDown(with theEvent : NSEvent) {
        super.mouseDown(with: theEvent)

        // Calculating the Ray direction
        let mousePosInWindow:NSPoint = theEvent.locationInWindow
        let farNdcMousePos = inverseViewPort(windowCoordinate: mousePosInWindow,z: 1)
        var rayEyeFar = projectionMatrix.inverse * farNdcMousePos
        rayEyeFar = float4(rayEyeFar.x,rayEyeFar.y,-1.0,0.0);
        let rayEyeFarCamToWor = viewMatrix.inverse * rayEyeFar
        let rayDirection = normalize(float3(rayEyeFarCamToWor.x, rayEyeFarCamToWor.y, rayEyeFarCamToWor.z))
        
        // Create Ray from camera location with calculated clickedPointRayDirection
        rayFarMouse = Ray(_point: float3(0.0,0.0,5.0), _direction: rayDirection);
        
        print("MD")
        print(cowBoundingSphere)
        print(raySphereInterection(ray: rayFarMouse, sphere: cowBoundingSphere));
        
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
        pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
        pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat
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
        
        ////////////////////////////////////////////////////////
        // Creating Bounding Box in order to click on cow :D //
        //////////////////////////////////////////////////////
        
        let cowMeshBox = mdlMesh.boundingBox

        // creating sphere around bounding box
        cowBoundingSphere.center = (cowMeshBox.maxBounds + cowMeshBox.minBounds) * 0.5
        cowBoundingSphere.radius = length(cowBoundingSphere.center - cowMeshBox.minBounds)
        
        print("inl")
        print(cowBoundingSphere)
        
        
        mtkMesh = try! MTKMesh(mesh: mdlMesh, device: device)

        
        // Buffers needed to avoid tearing
        var buffers = [MTLBuffer]()
        for _ in 0..<maximumInflightFrames {
            buffers.append(device.makeBuffer(length: MemoryLayout<float4x4>.stride * instanceCount, options: []))
        }
        
        //Rotations and translations
        cowRotations = [Float](repeatElement(0, count: instanceCount))
        cowTranslations = [float3](repeatElement(float3(), count: instanceCount))
        
        instanceBuffers = buffers
        
            cowRotations[0] = Float(drand48() * Double.pi * 2 );
            cowTranslations[0] = float3(Float(drand48()*7-3.5), Float(drand48()*7-3.5), Float(drand48()*7-3.5))
        
        
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
        
            let position = cowTranslations[0]
            let modelMatrix = translation(tx: position.x,ty: position.y, tz: position.z)
        
            cowRotations[0] += 3 * timestep; // 3radians per second
            contents[0] = modelMatrix;
       
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
            
            
            viewMatrix = translation(tx:0, ty:0, tz:5)
            projectionMatrix = perspectiveMatrix(rad: Float.pi/2, ar: Float(self.view.bounds.size.width/self.view.bounds.size.height), nearZ:0.1, farZ:100);
            
            
            var viewProjectionMatrix = projectionMatrix * viewMatrix
            
            
            
            
            
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
