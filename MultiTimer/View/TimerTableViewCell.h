//
//  TimerTableViewCell.h
//  MultiTimer
//
//  Created by Ryan Brooks on 3/22/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TimerTableCellReady,
    TimerTableCellRunning,
    TimerTableCellPaused
} TimerTableCellStatus;

@class TimerTableViewCell;
@protocol TimerTableViewCellDelegate <NSObject>

- (void) timerTableViewCelldidTouchStart:(TimerTableViewCell *)timerCell;
- (void) timerTableViewCelldidTouchStop:(TimerTableViewCell *)timerCell;
- (void) timerTableViewCelldidRequestTimerUpdate:(TimerTableViewCell *)timerCell;

@end


@interface TimerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (weak, nonatomic) IBOutlet UILabel *lapTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapCount;

@property id<TimerTableViewCellDelegate> delegate;

@property NSTimer *timer;

- (void) setCurrentLapCountText:(NSUInteger)count;
- (void) setTotalTimeLabelTime:(NSTimeInterval)totalDuration;
- (void) setLapTimeLabelTime:(NSTimeInterval)lapDuration;
- (void) requestTimersUpdate;

@end
