//
//  ViewController.swift
//  TestOnboarding
//
//  Created by Harrison Ellerm on 23/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import SwiftyBeaver

class OnBoardController: UIViewController, UICollectionViewDataSource,
                            UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let log = SwiftyBeaver.self
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()
    
    private let cellID = "cellID"
 
    private let pages: [Page] = {
        let firstPage = Page(title: "Manage your pain",
                             message: "Visually log your levels of pain or fatigue using a three dimensional model.",
                             image: #imageLiteral(resourceName: "pain"), showButton: false)
        
        let secondPage = Page(title: "View summary statistics",
                              message: "Create on the fly reports to better understand your condition.",
                              image: #imageLiteral(resourceName: "newspaper"), showButton: false)
        
        let thirdPage = Page(title: "Clearly convey symptoms",
                             message: "Offer health professionals insight into how your condition has evolved over time.",
                             image: #imageLiteral(resourceName: "doctor "), showButton: true)
       return [firstPage, secondPage, thirdPage]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.numberOfPages = self.pages.count
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1)
        return pc
    }()
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PageCell
        let page = pages[indexPath.item]
        cell.page = page
        cell.delegate = self
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 78)
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x/view.frame.width)
        pageControl.currentPage = pageNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pageControl.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pageControl.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        registerCells()
        
    }
    
    fileprivate func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellID)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension OnBoardController: PageCellDelegate {
    
    func letsGoPressed(cell: UICollectionViewCell) {
        let welcome = WelcomeController()
        self.log.info("User launched application")
        self.navigationController?.pushViewController(welcome, animated: true)
    }
}

