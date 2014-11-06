//
//  Sharing.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 11/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class SocialSharing {

  enum SocialNetwork {
    case Facebook
    case Twitter
  }

  class func postToSocialNetwork(
    socialNetwork: SocialNetwork,
    message: String,
    presentingViewController: UIViewController,
    urlString: String? = "http://www.goodcity.hk/",
    image: UIImage? = nil) {

      if socialNetwork == .Facebook {
        postToNetwork(SLServiceTypeFacebook, message: message, presentingViewController: presentingViewController, image: image, urlString: urlString)
      } else if socialNetwork == .Twitter {
        postToNetwork(SLServiceTypeTwitter, message: message, presentingViewController: presentingViewController, image: image, urlString: urlString)
      } else {
        println("Error: Unknown social network requested for post")
      }
  }

  private class func postToNetwork(type: NSString, message: String, presentingViewController: UIViewController, urlString: String?, image: UIImage?) {

    if SLComposeViewController.isAvailableForServiceType(type) {
      let sheet = SLComposeViewController(forServiceType: type)
      sheet.setInitialText(message)

      if urlString != nil {
        sheet.addURL(NSURL(string: urlString!))
      }

      if image != nil {
        sheet.addImage(image)
      }

      presentingViewController.presentViewController(sheet, animated: true, completion:nil)
    } else {
      println("Error: social network is not available")
    }
  }
}