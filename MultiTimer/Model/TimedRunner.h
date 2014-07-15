//
//  TimedRunner.h
//  MultiTimer
//
//  Created by Ryan Brooks on 3/23/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimerTableViewCell.h"

@interface TimedRunner : NSObject

@property NSString *runnerName;
@property NSMutableArray *runnerSplitTimes;

@property NSDate *totalStartTime;
@property NSDate *lapStartTime;

@property NSDate *currentOffsetStartTime;
@property NSTimeInterval offsetTotalDuration;
@property NSTimeInterval offsetLapDuration;

@property TimerTableCellStatus status;

- (NSTimeInterval) totalTime;
- (NSTimeInterval) currentLapTime;
- (NSTimeInterval) averageLapTime;

- (void) startRunner;
- (void) pauseRunner;
- (void) resumeRunner;
- (void) lapRunner;
- (void) restartRunner;

- (void) deleteLap:(NSUInteger) lapNumber;
- (NSUInteger) currentLapNumber;

- (void) logSelf;

@end
