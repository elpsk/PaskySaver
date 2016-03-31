//
//  AppDelegate.swift
//  PaskySaver
//
//  Created by Alberto Pasca on 31/03/16.
//  Copyright © 2016 albertopasca.it. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    lazy var screenSaverView = APScreenSaverView (frame: NSZeroRect, isPreview: false)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let screenSaverView = screenSaverView {
            screenSaverView.frame = window.contentView!.bounds;
            window.contentView!.addSubview(screenSaverView);
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {

    }


}

