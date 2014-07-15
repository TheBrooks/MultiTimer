//
//  UITableViewLapTimeCell.h
//  MultiTimer
//
//  Created by Ryan Brooks on 3/27/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewLapTimeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lapNumber;
@property (weak, nonatomic) IBOutlet UILabel *lapSplit;

- (void) updateBackgroundColor: (NSTimeInterval)averageColor;

@end
