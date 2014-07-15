//
//  TimerTableViewCell.m
//  MultiTimer
//
//  Created by Ryan Brooks on 3/22/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

#import "TimerTableViewCell.h"

static void * MyStatusObservationContext = &MyStatusObservationContext;

@implementation TimerTableViewCell

- (IBAction)startButtonDidTouchUpInside:(UIButton *)sender {
    [self.delegate timerTableViewCelldidTouchStart:self];
    [self flashTimes];    
}

- (IBAction)stopButtonDidTouchUpInside:(UIButton *)sender {
    [self.delegate timerTableViewCelldidTouchStop:self];
    [self flashTimes];
    
}
- (void) flashTimes
{
    [UIView animateWithDuration:.2 animations:^{
        [self.lapTimeLabel setAlpha:.3];
        [self.lapCount setAlpha:.3];
        [self.totalTimeLabel setAlpha:.3];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            [self.lapTimeLabel setAlpha:1];
            [self.lapCount setAlpha:1];
            [self.totalTimeLabel setAlpha:1];
        }];
    }];
}


- (void) requestTimersUpdate
{
    [self.delegate timerTableViewCelldidRequestTimerUpdate:self];
}

- (void) setTotalTimeLabelTime:(NSTimeInterval)totalDuration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.totalTimeLabel setText:[self formatTimeForLabelText:totalDuration]];
    });
    
}
- (void) setLapTimeLabelTime:(NSTimeInterval)lapDuration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lapTimeLabel setText:[self formatTimeForLabelText:lapDuration]];
    });
}

- (NSString *) formatTimeForLabelText:(NSTimeInterval)timeToDisplay
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss:S"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:  timeToDisplay]];
}
- (void) setCurrentLapCountText:(NSUInteger)count
{
    [self.lapCount setText:[NSString stringWithFormat: @"Lap %lu", (unsigned long)count]];

}

- (void) dealloc
{
    
}
- (void)awakeFromNib
{
    // Initialization code
    //add observer on status property
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    //open up the lap structure
}
@end
