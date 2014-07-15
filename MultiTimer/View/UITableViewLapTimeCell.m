//
//  UITableViewLapTimeCell.m
//  MultiTimer
//
//  Created by Ryan Brooks on 3/27/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

#import "UITableViewLapTimeCell.h"

@implementation UITableViewLapTimeCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) updateBackgroundColor: (NSTimeInterval)averageTime
{
    //do the math later
    int hours = [self.lapSplit.text substringWithRange:NSMakeRange(0, 2)].intValue;
    int minutes = [self.lapSplit.text substringWithRange:NSMakeRange(3, 2)].intValue;
    double seconds = [self.lapSplit.text substringWithRange:NSMakeRange(6,4)].doubleValue;
    NSTimeInterval lapTime =  hours*3600 + minutes*60 + seconds;
    float percentDifference = 1 - MIN(ABS((lapTime - averageTime)/averageTime),1);
    
    
    NSLog(@"lapTime %f", lapTime);
    NSLog(@"averageTime %f", averageTime);
    
    float baseRed;
    float baseGreen;
    float baseBlue;
    if(lapTime > averageTime)
    {
        baseRed = 161;
        baseGreen = 39;
        baseBlue = 39;
    }
    else
    {
        baseRed = 33;
        baseGreen = 171;
        baseBlue = 115;
    }
    float rangeRed = 255 - baseRed;
    float rangeGreen = 255 - baseGreen;
    float rangeBlue = 255 - baseBlue;
    
    [self.contentView setBackgroundColor:[UIColor colorWithRed:(baseRed + rangeRed * percentDifference)/255.0  green:(baseGreen + rangeGreen * percentDifference)/255.0 blue:(baseBlue + rangeBlue * percentDifference)/255.0  alpha:1]];

    [self.lapSplit setTextColor:[UIColor blackColor]];
    [self.lapNumber setTextColor:[UIColor blackColor]];
}

- (void) dealloc
{
    
}

@end
