//
//  BasicInformationsLabel.swift
//  AniManager
//
//  Created by Tobias Helmrich on 05.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BasicInformationsLabel: AniManagerLabel {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        font = UIFont(name: Constant.FontName.mainBold, size: 18.0)
        textAlignment = .left
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
