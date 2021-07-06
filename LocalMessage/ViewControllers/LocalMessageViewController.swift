///
///  LocalMessageViewController.swift
///  Created by Harutyun.Amiryan on 02.01.21.
///  Copyright © 2021. All rights reserved.
///

import UIKit

protocol LocalMessageViewControllerDelegate: AnyObject {
    func removeMessagePanel()
}

final class LocalMessageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HeaderDelegate, LocalMessageCellDelegate  {
    private var collectionView: UICollectionView!
    private(set) var itemHeight: CGFloat = 60
    private(set) var itemSpacing: CGFloat = 4
    private(set) var groupDensity: CGFloat = 8
    
    private var messages: [LocalMessage] = []
    private var panelLayout = LMPanelLayout()
    fileprivate var isGrouped = false
    fileprivate var contentHeight: CGFloat = 0
    private weak var delegate: LocalMessageViewControllerDelegate?

    var headerHeight: CGFloat {
        return isGrouped || (!isGrouped && messages.count < 2) ? 0 : 40
    }
    
    convenience init(frame: CGRect, delegate: LocalMessageViewControllerDelegate) {
        self.init()
        self.delegate = delegate
        view.frame = frame
        view.frame.size.height = contentHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: panelLayout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: LocalMessageCell.name, bundle: nil),
                                forCellWithReuseIdentifier: LocalMessageCell.name)
        collectionView.register(UINib(nibName: Header.name, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Header.name)
        panelLayout.viewController = self
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        panelLayout.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: headerHeight)
    }
    
    private var panelHeight: CGFloat {
        let top = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        let height = contentHeight + top
        return height < UIScreen.main.bounds.height ? height : UIScreen.main.bounds.height
    }
    
    func show(message: LocalMessage) {
        collectionView.performBatchUpdates({
            messages.insert(message, at: 0)
            collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
        }, completion: nil)
       
        refreshPanelHeightWithAnimation()
    }
    
    private func refreshPanelHeightWithAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.frame.size.height = self.panelHeight
        }) { [weak self] (_)  in
            guard let self = self else { return }
            if self.messages.isEmpty  {
                self.delegate?.removeMessagePanel()
            }
        }
    }
    
    // MARK: - Calculate item height
    
    func heightForItem(at index: Int) -> CGFloat {
        let size = CGSize(width: view.frame.width - 100, height: .greatestFiniteMagnitude)
        let boundingBox = messages[index].info.boundingRect(with: size, options: [.usesLineFragmentOrigin], context: nil)
        let extraHeight = boundingBox.height < 18 ? 0 : boundingBox.height
        return itemHeight + extraHeight
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocalMessageCell.name, for: indexPath) as! LocalMessageCell
        cell.delegate = self
        cell.setInfo(message: messages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Header.name, for: indexPath) as! Header
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && isGrouped {
            collectionView.performBatchUpdates({
                isGrouped = false
            }, completion: nil)
            refreshPanelHeightWithAnimation()
        }
    }
    
    // MARK: - LocalMessageCellDelegate
    
    func removeMessage(_ cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            collectionView.performBatchUpdates({
                messages.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }) { (_) in
                self.refreshPanelHeightWithAnimation()
            }
        }
    }
    
    // MARK: - HeaderDelegate
    
    func groupAction() {
        collectionView.performBatchUpdates({
            self.isGrouped = true
        }) { (_) in
            self.refreshPanelHeightWithAnimation()
        }
    }
}

fileprivate class LMPanelLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var insertedItemsIndexPaths: Set<IndexPath> = []
    private var deletedItemsIndexPaths: Set<IndexPath> = []

    weak var viewController: LocalMessageViewController!

    private var contentWidth: CGFloat {
        return viewController.view.frame.width
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: viewController.contentHeight)
    }
    
    override func prepare() {
        super.prepare()
        if collectionView != nil {
            layoutAttributes = layoutAttributes(for: collectionView!, grouped: viewController.isGrouped)
        }
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        insertedItemsIndexPaths.removeAll()
        deletedItemsIndexPaths.removeAll()
        
        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate, update.updateAction == .insert {
                insertedItemsIndexPaths.insert(indexPath)
            }
            if let indexPath = update.indexPathBeforeUpdate, update.updateAction == .delete {
                deletedItemsIndexPaths.insert(indexPath)
            }
        }
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        if insertedItemsIndexPaths.contains(itemIndexPath) {
            attributes?.alpha = 0.0
            attributes?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        if deletedItemsIndexPaths.contains(itemIndexPath) {
            attributes?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        return attributes
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        insertedItemsIndexPaths.removeAll()
        deletedItemsIndexPaths.removeAll()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in layoutAttributes {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        if let sectionAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) {
            visibleLayoutAttributes.append(sectionAttributes)
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }
        layoutAttributes.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                                        size: CGSize(width: contentWidth,
                                                     height: viewController.headerHeight))
        return layoutAttributes
    }
  
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
        
    private func layoutAttributes(for collectionView: UICollectionView, grouped: Bool) -> [UICollectionViewLayoutAttributes] {
        var attributes: [UICollectionViewLayoutAttributes] = []
        var yInset: CGFloat = viewController.headerHeight
        var xInset: CGFloat = 0

        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        for index in 0..<numberOfItems {
            let height = !grouped ? viewController.heightForItem(at: index) : viewController.heightForItem(at: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            let frame = CGRect(x: xInset/2, y: yInset, width: contentWidth - xInset, height: height)
            attribute.frame = frame
            attribute.zIndex = numberOfItems - index
            attributes.append(attribute)
            yInset += grouped ? viewController.groupDensity : height + viewController.itemSpacing
            xInset += grouped ? viewController.groupDensity : 0
            viewController.contentHeight = frame.maxY + viewController.itemSpacing + viewController.groupDensity
        }
        return attributes
    }
}

extension UIResponder {
    static var name: String {
        return String(describing: self)
    }
}
