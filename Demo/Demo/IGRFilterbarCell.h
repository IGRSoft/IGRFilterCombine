//
//  IGRToolbarCell.h
//  IGRFastFilterViewFramework
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface IGRFilterbarCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel     *title;
@property (nonatomic, weak) IBOutlet UIImageView *icon;

@end

NS_ASSUME_NONNULL_END
