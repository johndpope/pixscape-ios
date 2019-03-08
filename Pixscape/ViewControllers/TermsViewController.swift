//
//  TermsViewController.swift
//  Pixscape
//
//  Created by bils on 30/05/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit
import WebKit

final class TermsViewController: UICircularViewController {
    
    private lazy var closeButton: JJFloatingActionButton = {
        let button = JJFloatingActionButton()
        button.buttonImage = #imageLiteral(resourceName: "ic_close_white")
        button.buttonColor = .primary
        button.buttonImageColor = UIColor.secondary
        button.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pdfFilePath = Bundle.main.url(forResource: "ScapePrivacy", withExtension: "pdf")
        let urlRequest = URLRequest.init(url: pdfFilePath!)
        let webView = WKWebView(frame: self.view.frame)
        webView.load(urlRequest)
        
        self.view.addSubview(webView)
        webView.addSubview(closeButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UICircularViewController.radialPopViewController))
        closeButton.addGestureRecognizer(tap)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        layoutFrames()
    }
    
    private func layoutFrames() {
        closeButton.anchorInCorner(.bottomRight, xPad: 10, yPad: 15, width: 40, height: 40)
    }
}
