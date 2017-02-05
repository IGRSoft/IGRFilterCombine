//
//  ViewController.swift
//  DemoSwift
//
//  Created by Vitalii Parovishnyk on 1/8/17.
//  Copyright © 2017 IGR Software. All rights reserved.
//

import UIKit

import IGRFilterCombine

class ViewController: UIViewController {
    
    @IBOutlet weak fileprivate var collectionView: UICollectionView?
    @IBOutlet weak fileprivate var imageView: UIImageView?
    
    fileprivate var filterCombine: IGRFilterCombine?
    
    static let kImageNotification = NSNotification.Name(rawValue: "WorkImageNotification")
    let kDemoImage = UIImage.init(named: "demo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterCombine = IGRFilterCombine(delegate: self as IGRFilterCombineDelegate)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(setupWorkImage(_:)),
                                       name: ViewController.kImageNotification,
                                       object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.once(token: "com.igrsoft.fastfilter.demo") {
            self.setupDemoView()
        }
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self,
                                          name: ViewController.kImageNotification,
                                          object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupDemoView() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.post(name: ViewController.kImageNotification, object: kDemoImage)
    }
    
    func setupWorkImage(_ notification: Notification) {
        assert(notification.object is UIImage, "Image only allowed!")
        let image = notification.object as! UIImage
        
        self.filterCombine?.setImage(image, completion: { (processedImage, idx) in
            let indexPath = IndexPath(row: Int(idx), section: 0)
            if (self.collectionView?.indexPathsForSelectedItems?.contains(indexPath))! {
                self.imageView?.image = processedImage
            }
        }) { (processedImage, idx) in
            let indexPath = IndexPath(row: Int(idx), section: 0)
            if (self.collectionView?.indexPathsForVisibleItems.contains(indexPath))! {
                let cell = self.collectionView?.cellForItem(at: indexPath) as! IGRFilterbarCell
                cell.icon?.image = processedImage
            }
        }
        
        self.imageView?.image = image
        self.collectionView?.reloadData()
    }
    
    func prepareImage() -> UIImage {
        return (self.imageView?.image)!
    }
    
    @IBAction func onTouchGetImageButton(_ sender: UIBarButtonItem)
    {
        let alert = UIAlertController.init(title: NSLocalizedString("Select image", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.popoverPresentationController?.barButtonItem = sender
        
        func completeAlert(type: UIImagePickerControllerSourceType) {
            let pickerView = UIImagePickerController.init()
            pickerView.delegate = self
            pickerView.sourceType = type
            self.present(pickerView, animated: true, completion: nil)
        }
        
        let style = UIAlertActionStyle.default
        var action = UIAlertAction.init(title: NSLocalizedString("From Library", comment: ""),
                                        style: style) { (UIAlertAction) in
                                            completeAlert(type: UIImagePickerControllerSourceType.photoLibrary)
        }
        
        alert.addAction(action)
        
        action = UIAlertAction.init(title: NSLocalizedString("From Camera", comment: ""),
                                    style: style) { (UIAlertAction) in
                                        completeAlert(type: UIImagePickerControllerSourceType.camera)
        }
        
        alert.addAction(action)
        
        action = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""),
                                    style: style)
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func onTouchShareButton(_ sender: UIBarButtonItem) {
        
        let image = prepareImage()
        
        let avc = UIActivityViewController.init(activityItems: [image], applicationActivities: nil)
        
        avc.popoverPresentationController?.barButtonItem = sender
        avc.popoverPresentationController?.permittedArrowDirections = .up
        
        self.present(avc, animated: true, completion: nil)
    }
    
    func igr_borderOffsetFromFiltersbar(collectionView: UICollectionView) -> CGFloat {
        return collectionView.frame.size.height * 0.5
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(self.filterCombine!.count())
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGRFilterbarCell", for: indexPath) as! IGRFilterbarCell
        
        cell.icon?.image = self.filterCombine?.filteredPreviewImage(at: UInt(indexPath.row))
        cell.title?.text = self.filterCombine?.filtereName(at: UInt(indexPath.row))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 100.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let borderOffset = self.igr_borderOffsetFromFiltersbar(collectionView: collectionView)
        
        let attrs = collectionView.layoutAttributesForItem(at: indexPath)
        var frame = attrs?.frame
        frame = UIEdgeInsetsInsetRect(frame!, UIEdgeInsetsMake(0.0, -borderOffset, 0.0, -borderOffset))
        collectionView.scrollRectToVisible(frame!, animated: true)
        
        self.imageView?.image = self.filterCombine?.filteredImage(at: UInt(indexPath.row))
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        let notificationCenter = NotificationCenter.default
        notificationCenter.post(name: ViewController.kImageNotification, object: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - IGRFilterCombineDelegate

extension ViewController : IGRFilterCombineDelegate {
    func previewSize() -> CGSize {
        return CGSize(width: 70.0, height: 70.0)
    }
}

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

