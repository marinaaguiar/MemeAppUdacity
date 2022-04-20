//
//  Meme.swift
//  Meme
//
//  Created by Marina Aguiar on 4/7/22.
//

import Foundation
import UIKit

struct Meme: Comparable {

    let id: UUID!
    let createdDate: Date
    let topTexField: String
    let bottomTextField: String
    let originalImage: UIImage
    let memedImage: UIImage

    static func < (lhs: Meme, rhs: Meme) -> Bool {
        lhs.createdDate < rhs.createdDate
    }
}
