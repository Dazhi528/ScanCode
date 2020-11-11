//
//  ViewController.swift
//  ScanCode
//
//  Created by Dazhi528 on 11/10/2020.
//  Copyright (c) 2020 Dazhi528. All rights reserved.
//

import UIKit
import ScanCode

class ViewController: UIViewController {
    @IBOutlet weak var scanRetShow: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func mClickGotoScan(_ sender: UIButton) {
        let mScanViewController = ScanViewController()
        if #available(iOS 13.0, *) {
            mScanViewController.modalPresentationStyle = .fullScreen
        }
        weak var weakSelf = self
        mScanViewController.mScanBlockCallback = {
            (scanCodeResult:String) in
            // 注意：更新UI必须切换到主线程
            DispatchQueue.main.async {
                weakSelf?.scanRetShow.text = scanCodeResult
            }
        }
        self.present(mScanViewController, animated: true, completion: nil)
    }
    
}

