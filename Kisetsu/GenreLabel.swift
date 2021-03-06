//
//  GenreLabel.swift
//  AniManager
//
//  Created by Tobias Helmrich on 03.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class GenreLabel: UILabel {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        font = UIFont(name: Constant.FontName.mainRegular, size: 16.0)
        backgroundColor = Style.Color.Background.genreLabel
        textColor = Style.Color.Text.genreLabel
        textAlignment = .center
        layer.cornerRadius = 2.0
    }
    
    override var intrinsicContentSize: CGSize {
        let contentSize = super.intrinsicContentSize
        return CGSize(width: contentSize.width + 20, height: contentSize.height + 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

}
