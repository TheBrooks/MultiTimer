//
//  TimedRunner.m
//  MultiTimer
//
//  Created by Ryan Brooks on 3/23/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

#import "TimedRunner.h"

@implementation TimedRunner


- (id) init
{
    self = [super init];
    if(self){
        self.runnerSplitTimes = [NSMutableArray new];
    }
    return self;
}

- (NSTimeInterval) totalTime
{
    NSDate *baseDate = [NSDate date];
    if(self.status == TimerTableCellPaused)
        baseDate = self.currentOffsetStartTime;
    return  [baseDate timeIntervalSinceDate: self.totalStartTime] - self.offsetTotalDuration;
}

- (NSTimeInterval) currentLapTime
{
    NSDate *baseDate = [NSDate date];
    if(self.status == TimerTableCellPaused)
        baseDate = self.currentOffsetStartTime;
   return [baseDate timeIntervalSinceDate:self.lapStartTime ] - self.offsetLapDuration;
}

 - (NSTimeInterval) averageLapTime
{
    NSTimeInterval value = 0;
    for(NSNumber *lapSplit in self.runnerSplitTimes)
    {
        value += lapSplit.doubleValue;
    }
    if([self.runnerSplitTimes count])
         value /= [self.runnerSplitTimes count];
    return value;
}

- (void) deleteLap:(NSUInteger) lapNumber
{
    if(lapNumber < [self.runnerSplitTimes count])
    {
        self.offsetTotalDuration += [[self.runnerSplitTimes objectAtIndex:lapNumber] doubleValue];
        [self.runnerSplitTimes removeObjectAtIndex:lapNumber];
    }
}

- (NSUInteger) currentLapNumber
{
    return [self.runnerSplitTimes count] +1;
}

- (void) startRunner
{
    //if(!self.totalStartTime)
        self.totalStartTime =  self.lapStartTime = [NSDate date];
    //[self resumeRunner];
    self.status= TimerTableCellRunning;
    
    
}

- (void) pauseRunner
{
    self.currentOffsetStartTime = [NSDate date];
    self.status= TimerTableCellPaused;
}

- (void) resumeRunner
{
    self.offsetTotalDuration += [[NSDate date] timeIntervalSinceDate:self.currentOffsetStartTime];
    self.offsetLapDuration += [[NSDate date] timeIntervalSinceDate:self.currentOffsetStartTime];
    self.currentOffsetStartTime = nil;
    self.status = TimerTableCellRunning;

}

- (void) lapRunner
{
    
    [self.runnerSplitTimes insertObject:[NSNumber numberWithDouble:[ [NSDate date] timeIntervalSinceDate:self.lapStartTime ] - self.offsetLapDuration] atIndex:0 ];
    self.offsetLapDuration = 0;
    self.currentOffsetStartTime = nil;
    self.lapStartTime = [NSDate date];
}


- (void) restartRunner
{
    self.runnerSplitTimes = [NSMutableArray new];
    self.totalStartTime = nil;
    self.lapStartTime = nil;
    self.currentOffsetStartTime = nil;
    self.offsetTotalDuration = 0;
    self.offsetLapDuration = 0;
    self.status = TimerTableCellReady;

}

- (void) logSelf
{
    NSLog(@"Runner name: %@",self.runnerName);
    NSLog(@" splits: %@",self.runnerSplitTimes);
    
    NSLog(@" totalStartTime: %@",self.totalStartTime);
    NSLog(@" lapStartTime: %@",self.lapStartTime);
    
    NSLog(@" currentOffsetStartTime: %@",self.currentOffsetStartTime);
    NSLog(@" offsetTotalDuration: %f",self.offsetTotalDuration);
    NSLog(@" offsetLapDuration: %f",self.offsetLapDuration);
    NSLog(@" status: %lu",self.status);
}
@end
