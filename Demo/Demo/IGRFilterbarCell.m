//
//  IGRToolbarCell.m
//  IGRFastFilterViewFramework
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

#import "IGRFilterbarCell.h"

@interface IGRFilterbarCell ()

@end       

@implementation IGRFilterbarCell

- (void)setSelected:(BOOL)selected
{
    [self setNeedsDisplay];
    
    super.selected = selected;
}

@end
