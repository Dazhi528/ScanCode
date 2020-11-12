import UIKit
import AVFoundation


private let kScreenWidth = UIScreen.main.bounds.size.width // 屏幕宽度
private let kScreenHeight = UIScreen.main.bounds.size.height // 屏幕高度

public class ScanViewController: UIViewController {
    // 声明一个闭包回调函数
    public var mScanBlockCallback:((_ scanResult:String)->Void)?
    
    // 中间扫描框的宽高
    private let mBoxWH : CGFloat = kScreenWidth * 0.5
    // 中间扫描框的中间点的Y
    private let mBoxCentY : CGFloat = kScreenHeight * 0.4
    // Bundle资源
    private lazy var mBundle: Bundle = {
        let strBundlePath = Bundle(for: type(of: self))
            .path(forResource: "ScanCode", ofType: "bundle") ?? ""
        return Bundle(path: strBundlePath) ?? Bundle.main
    }()
    // 扫描会话
    private let session = AVCaptureSession()
    
    //MARK: 预览图层
    private lazy var preview : AVCaptureVideoPreviewLayer = {
        // ===== 预览视图定义部分
        let preview = AVCaptureVideoPreviewLayer(session: self.session)
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height:kScreenHeight)
        preview.backgroundColor = UIColor.black.cgColor
        
        // ===== 遮罩部分
        // 定义贝塞尔绘制路径:遮罩
        let maskPath = UIBezierPath(rect: view.bounds)
        // 定义贝塞尔绘制路径:透明部分
        let transparentPath = UIBezierPath(rect: CGRect(
            x: (kScreenWidth - mBoxWH)/2, y: mBoxCentY - (mBoxWH/2),
            width: mBoxWH, height: mBoxWH))
        // 路径组合
        maskPath.append(transparentPath)
        // 定义绘制图层范围，并把绘制路径传入图层用于图层绘制
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd // 取非公共部分
        maskLayer.fillColor = UIColor.black.withAlphaComponent(0.4).cgColor
        
        // ===== 扫描边框通用参数定义
        //let edgeColor = UIColor(red: 59/255, green: 141/255, blue: 233/255, alpha: 1).cgColor
        let edgeColor = UIColor.green.cgColor
        let edgeWidth : CGFloat = 30
        let edgeSize = CGSize(width: edgeWidth, height: edgeWidth)
        let edgeLineWidth : CGFloat = 2
        // ===== 扫描边框左顶脚边
        // 定义绘制图层范围
        let leftTopLayer = CAShapeLayer()
        let leftTopPoint = CGPoint.init(x: (kScreenWidth - mBoxWH)/2, y: (mBoxCentY - (mBoxWH/2)))
        leftTopLayer.frame = CGRect(origin: leftTopPoint, size: edgeSize)
        // 定义贝塞尔绘制路径
        let leftTopPath = self.createBezierPath(points: [CGPoint(x: 0, y: 0),CGPoint(x: edgeWidth, y: 0),CGPoint(x: edgeWidth, y: edgeLineWidth),CGPoint(x: edgeLineWidth, y: edgeLineWidth),CGPoint(x: edgeLineWidth, y: edgeWidth),CGPoint(x: 0, y: edgeWidth)])
        // 绘制路径传入图层用于图层绘制
        leftTopLayer.path = leftTopPath.cgPath
        leftTopLayer.fillColor = edgeColor
        
        // ===== 扫描边框右顶脚边
        let rightTopLayer = CAShapeLayer()
        let rightTopPoint = CGPoint.init(x: (kScreenWidth + mBoxWH)/2, y: (mBoxCentY - (mBoxWH/2)))
        rightTopLayer.frame = CGRect.init(origin: CGPoint.init(x: rightTopPoint.x - edgeWidth, y: rightTopPoint.y), size: edgeSize)
        let rightTopPath = self.createBezierPath(points: [CGPoint.init(x: edgeWidth, y: 0),CGPoint.init(x: 0, y: 0),CGPoint.init(x: 0, y: edgeLineWidth),CGPoint.init(x: edgeWidth - edgeLineWidth, y: edgeLineWidth),CGPoint.init(x: edgeWidth - edgeLineWidth, y: edgeWidth),CGPoint.init(x: edgeWidth, y: edgeWidth)])
        rightTopLayer.path = rightTopPath.cgPath
        rightTopLayer.fillColor = edgeColor
        
        // ===== 扫描边框右底脚边
        let rightBottomLayer = CAShapeLayer()
        let rightBottomPoint = CGPoint.init(x: (kScreenWidth + mBoxWH)/2, y: (mBoxCentY + (mBoxWH/2)))
        rightBottomLayer.frame = CGRect.init(origin: CGPoint.init(x: rightBottomPoint.x - edgeWidth, y: rightBottomPoint.y - edgeWidth), size: edgeSize)
        let rightBottomPath = self.createBezierPath(points: [CGPoint.init(x: edgeWidth, y: edgeWidth),CGPoint.init(x: edgeWidth, y: 0),CGPoint.init(x: edgeWidth - edgeLineWidth, y: 0),CGPoint.init(x: edgeWidth - edgeLineWidth, y: edgeWidth - edgeLineWidth),CGPoint.init(x: 0, y: edgeWidth - edgeLineWidth),CGPoint.init(x: 0, y: edgeWidth)])
        rightBottomLayer.path = rightBottomPath.cgPath
        rightBottomLayer.fillColor = edgeColor
        
        // ===== 扫描边框左底脚边
        let leftBottomLayer = CAShapeLayer()
        let leftBottomPoint = CGPoint.init(x: (kScreenWidth - mBoxWH)/2, y: (mBoxCentY + (mBoxWH/2)))
        leftBottomLayer.frame = CGRect.init(origin: CGPoint.init(x: leftBottomPoint.x, y: leftBottomPoint.y - edgeWidth), size: edgeSize)
        let leftBottomPath = self.createBezierPath(points: [CGPoint.init(x: 0, y: edgeWidth),CGPoint.init(x: edgeWidth, y: edgeWidth),CGPoint.init(x: edgeWidth, y: edgeWidth - edgeLineWidth),CGPoint.init(x: edgeLineWidth, y: edgeWidth - edgeLineWidth),CGPoint.init(x: edgeLineWidth, y: 0),CGPoint.init(x: 0, y: 0)])
        leftBottomLayer.path = leftBottomPath.cgPath
        leftBottomLayer.fillColor = edgeColor
        
        // ===== 预览视图中，添加子图层
        preview.addSublayer(maskLayer)
        preview.addSublayer(leftTopLayer)
        preview.addSublayer(rightTopLayer)
        preview.addSublayer(rightBottomLayer)
        preview.addSublayer(leftBottomLayer)
        return preview
    }()
    
    private func createBezierPath( points : [CGPoint]) -> UIBezierPath {
        var points = points
        let path = UIBezierPath()
        path.move(to: points.first!)
        points.remove(at: 0)
        for point in points {
            path.addLine(to: point)
        }
        path.close()
        return path
    }
    
    //MARK: 页面关闭按钮
    private lazy var closeButton : UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(origin: CGPoint(x: 60, y: mBoxCentY+mBoxWH),
                                   size: CGSize(width: 60, height: 60))
        closeButton.setImage(UIImage(named: "ScanClose", in: mBundle, compatibleWith: nil),
                             for: .normal)
        let imgSize = closeButton.imageView?.bounds.size
        let interval:CGFloat = 20
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        closeButton.setTitle(NSLocalizedString("libscan_close",
                                               bundle: mBundle , comment: ""),
                             for: .normal)
        closeButton.titleEdgeInsets = UIEdgeInsets(top: (imgSize?.height ?? 0) + interval,
                                                   left: -((imgSize?.width ?? 0) + interval-5), bottom: 0, right: 0)
        closeButton.addTarget(self, action: #selector(scanClose), for: .touchUpInside)
        return closeButton
    }()
    
    //MARK: 手电筒按钮
    private lazy var torchButton : UIButton = {
        let torchButton = UIButton(type: .custom)
        torchButton.frame = CGRect(origin: CGPoint(x: kScreenWidth-90, y: mBoxCentY+mBoxWH),
                                   size: CGSize(width: 60, height: 60))
        torchButton.setImage(UIImage(named: "ScanTorch", in: mBundle, compatibleWith: nil),
                             for: .normal)
        let imgSize = torchButton.imageView?.bounds.size
        let interval:CGFloat = 20
        torchButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        torchButton.setTitle(NSLocalizedString("libscan_lighton",
                                               bundle: mBundle , comment: ""),
                             for: .normal)
        torchButton.titleEdgeInsets = UIEdgeInsets(top: (imgSize?.height ?? 0) + interval,
                                                   left: -((imgSize?.width ?? 0) + interval-5), bottom: 0, right: 0)
        torchButton.addTarget(self, action: #selector(scanTorch), for: .touchUpInside)
        return torchButton
    }()
    
    //MARK: 生命周期--视图加载完成
    override public func viewDidLoad() {
        super.viewDidLoad()
        // 获取设备
        //        let devices = AVCaptureDevice.devices(for: .video) // 过时
        //        let mAVCaptureDevice = devices.filter({ return $0.position == .back }).first
        // 上面过时方法的替换方法
        guard let mAVCaptureDevice=AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            return
        }
        // 视频输入
        let videoInput = try? AVCaptureDeviceInput(device: mAVCaptureDevice)
        let videoOutput = AVCaptureMetadataOutput()
        videoOutput.setMetadataObjectsDelegate(self,
                                               queue: DispatchQueue.global(qos: .default))
        if session.canAddInput(videoInput!) {
            session.addInput(videoInput!)
        }
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        //扫描类型
        videoOutput.metadataObjectTypes = [
            .qr,
            .code39,
            .code128,
            .code39Mod43,
            .ean13,
            .ean8,
            .code93]
        //可识别区域；注意看rectOfInterest，它以右上角为原点 并且rect的值是个比例，在[0,1]之间
        videoOutput.rectOfInterest = CGRect.init(x: (mBoxCentY - (mBoxWH/2))/kScreenHeight, y: 1 - (kScreenWidth + mBoxWH)/2/kScreenWidth, width: mBoxWH/kScreenHeight, height: mBoxWH/kScreenWidth)
        view.layer.addSublayer(preview)
    }
    
    //MARK: 生命周期--视图将于添加
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        self.view.addSubview(closeButton)
        self.view.addSubview(torchButton)
        //
        session.startRunning()
    }
    
    //MARK: 生命周期--视图已移除
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopRunning()
    }
    // 结束扫描
    private func stopRunning()  {
        session.stopRunning()
    }
}

//MARK: 扫描相关按钮点击事件
extension ScanViewController {
    @objc private func scanClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func scanTorch() {
        guard let mAVCaptureDevice=AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            return
        }
        guard mAVCaptureDevice.hasTorch else { return }
        do {
            try mAVCaptureDevice.lockForConfiguration()
            torchButton.isSelected = !torchButton.isSelected
            if (torchButton.isSelected) {
                try? mAVCaptureDevice.setTorchModeOn(level: 1.0)
            } else {
                mAVCaptureDevice.torchMode = AVCaptureDevice.TorchMode.off
            }
            mAVCaptureDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
        torchButton.isSelected = (mAVCaptureDevice.torchMode == AVCaptureDevice.TorchMode.on)
        if (torchButton.isSelected) {
            torchButton.setTitle(NSLocalizedString("libscan_lightoff",
                              bundle: mBundle , comment: ""),
            for: .normal)
        }else {
            torchButton.setTitle(NSLocalizedString("libscan_lighton",
                              bundle: mBundle , comment: ""),
            for: .normal)
        }
    }
}

//MARK: 相机扫描结果回调
extension ScanViewController : AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0  {
            let obj = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            let qrcodeResult : String = obj.stringValue!
            stopRunning()
            mScanBlockCallback?(qrcodeResult)
            mScanBlockCallback = nil
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}


