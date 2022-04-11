//
//  SentMemesTableViewController.swift
//  Meme
//
//  Created by Marina Aguiar on 4/11/22.
//

import UIKit

var memes: [Meme]! {
    let object = UIApplication.shared.delegate
    let appDelegate = object as! AppDelegate
    return appDelegate.memes
}
