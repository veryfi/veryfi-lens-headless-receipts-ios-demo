//
//  HeadlessReceiptsResultViewController.swift
//  Veryfi-Lens
//
//  Created by Veryfi on 27/07/23.
//  Copyright © 2023 Veryfi. All rights reserved.
//

import UIKit

final class HeadlessReceiptsResultViewController: UIViewController {
    var resultImages: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onClose(_ sender: Any) {
        presentingViewController?.presentingViewController?.dismiss(
            animated: true
        )
    }
}

extension HeadlessReceiptsResultViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resultImages?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headlessImageResultCell", for: indexPath) as? HeadlessImageResultCell else {
            return UICollectionViewCell()
        }
        if let image = resultImages?[indexPath.item] {
            cell.imageView.image = image
        }
        
        return cell
    }
}

extension HeadlessReceiptsResultViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let guide = view.safeAreaLayoutGuide
        let height = guide.layoutFrame.size.height - 60
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
}
