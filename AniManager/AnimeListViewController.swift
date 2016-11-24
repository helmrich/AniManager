//
//  AnimeListViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class AnimeListViewController: ListViewController {

    // MARK: - Properties
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.navigationItem.title = "Anime Lists"
        tabBarController?.navigationItem.leftBarButtonItem = nil
    }
    
    
    // MARK: - Functions
    

}