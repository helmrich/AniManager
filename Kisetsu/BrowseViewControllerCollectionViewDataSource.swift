//
//  BrowseViewControllerCollectionViewDataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 27.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit
import Kingfisher
    
extension BrowseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if numberOfBasicSeriesInBrowseList == 0 {
            nothingFoundLabel.text = "No \(seriesType.rawValue) found"
            UIView.animate(withDuration: 0.25) {
                self.nothingFoundLabel.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.nothingFoundLabel.alpha = 0.0
            }
        }
        return numberOfBasicSeriesInBrowseList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        guard let browseList = browseList,
            let basicSeries = browseList.basicSeries else {
                return cell
        }
        
        guard numberOfBasicSeriesInBrowseList > indexPath.row else {
            return cell
        }
        
        /*
            Get the current series from the browse series list,
            if the cell doesn't have a series ID, assign the current
            series' ID to the cells seriesId property and set the
            cell's title label to the current series' title and
            show it

            Then download the cover image and set the cell's image
            view's image property to the received image
         */
        guard let currentSeries = basicSeries[indexPath.row] as? BasicSeries else {
            return cell
        }
        
        if cell.seriesId == nil {
            cell.seriesId = Int(currentSeries.id)
        }
        
        cell.titleLabel.text = currentSeries.titleForSelectedTitleLanguageSetting
        cell.titleLabel.alpha = 1.0
        cell.imageView.backgroundColor = Style.Color.Background.seriesCollectionImageView
        cell.imageOverlay.alpha = 0.7
        
        if cell.imageView.image == nil,
            let imageMediumURLString = currentSeries.imageMediumURLString,
            let imageMediumURL = URL(string: imageMediumURLString),
            let imageLargeURLString = currentSeries.imageLargeURLString,
            let imageLargeURL = URL(string: imageLargeURLString) {
            cell.imageView.kf.setImage(
                with: UserDefaults.standard.bool(forKey: UserDefaultsKey.downloadHighQualityImages.rawValue) ? imageLargeURL : imageMediumURL,
                placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil, completionHandler: nil)
        }
        
        return cell
        
    }
}
