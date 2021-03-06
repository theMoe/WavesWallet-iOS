//
//  UIViewController+Additionals.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RESideMenu

extension UIViewController {
    
    func createBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_back"), style: .plain, target: self, action: #selector(backTapped))
    }
    
    func createMenuButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .done, target: self, action: #selector(menuTapped))
    }
    
    @objc func menuTapped() {
        let menu = AppDelegate.shared().menuController
        menu.presentLeftMenuViewController()
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    func hideTopBarLine() {
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    // TODO: Меня смущает проверка (<= 44) в showImage.
    func setupTopBarLine() {
        
        if let nav = navigationController {
            let showImage = nav.navigationBar.frame.size.height.rounded(.down) <= 44
            if showImage {
                if nav.navigationBar.shadowImage != nil {
                    nav.navigationBar.shadowImage = nil
                }
            }
            else {
                if nav.navigationBar.shadowImage == nil {
                    nav.navigationBar.shadowImage = UIImage()
                }
            }
        }
    }
    
    func setupSmallNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    func setupBigNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func addBgBlueImage() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        if Platform.isIphone5 {
            imageView.image = UIImage(named: "bg-iphone5")
        }
        else if Platform.isIphoneX {
            imageView.image = UIImage(named: "bg-iphonex")
        }
        else if Platform.isIphonePlus {
            imageView.image = UIImage(named: "bg-iphone8plus")
        }
        else {
            imageView.image = UIImage(named: "bg-iphone8")
        }
        
        view.insertSubview(imageView, at: 0)
    }
    
    
}
