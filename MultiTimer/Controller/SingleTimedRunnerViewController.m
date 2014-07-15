//
//  SingleTimedRunnerViewController.m
//  MultiTimer
//
//  Created by Ryan Brooks on 3/26/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

#import "SingleTimedRunnerViewController.h"
#import "UITableViewLapTimeCell.h"
#import "NavigationBarAppearance.h"

static void * MyStatusObservationContextInViewController = &MyStatusObservationContextInViewController;
static void * ObserveAverageTimeChanged = &ObserveAverageTimeChanged;



@interface SingleTimedRunnerViewController () <UITableViewDataSource,     UITableViewDelegate, NavigationBarAppearance>

@property NSDateFormatter *formatter;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLapTimeLabel;

@property (weak, nonatomic) IBOutlet UITableView *lapTimeTable;

@property NSTimer *runTimer;

@property NSTimeInterval averageLapTime;


@end

@implementation SingleTimedRunnerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.automaticallyAdjustsScrollViewInsets = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:self.runner.runnerName];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"HH:mm:ss.S"];
    [self.formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Do any additional setup after loading the view from its nib.
    [self addObserver:self forKeyPath:@"runner.status" options:NSKeyValueObservingOptionNew context:MyStatusObservationContextInViewController];
    [self addObserver:self forKeyPath:@"averageLapTime" options:NSKeyValueObservingOptionNew context:ObserveAverageTimeChanged];
    
    [self updateAverageLapTime];
    [self.startButton.layer setBorderColor:[UIColor colorWithRed:56/255.0 green:188/255.0  blue:80/255.0  alpha:1].CGColor];
    [self.stopButton.layer setBorderColor:[UIColor colorWithRed:188/255.0 green:85/255.0  blue:107/255.0  alpha:1].CGColor];
    [self.lapCountLabel setText:[NSString stringWithFormat:@"Lap: %li",[self.runner.runnerSplitTimes count] +1]];
    //NEED TO UPDATE THE UI
    [self updateTimer];
    self.runner.status = self.runner.status;

}

- (void) updateAverageLapTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.averageLapTimeLabel.text = [NSString stringWithFormat:@"Avg:  %@",[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(self.averageLapTime = [self.runner averageLapTime]) ]] ];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.runner.runnerSplitTimes count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"LapCell";
    
    UITableViewLapTimeCell *cell = (UITableViewLapTimeCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UITableViewLapTimeCell" owner:self options:nil];
        cell = (UITableViewLapTimeCell *)[nib objectAtIndex:0];

    }
    
    [self updateLapTimeCell:cell atIndexPath:indexPath];
    return cell;
}

- (void) updateLapTimeCell:(UITableViewLapTimeCell *)lapTimeCell atIndexPath:(NSIndexPath *)indexPath
{
    NSTimeInterval lapSplitTime = [self.runner currentLapTime];
    if(indexPath.row)
    {
        lapSplitTime = [[self.runner.runnerSplitTimes objectAtIndex:indexPath.row-1] doubleValue];
        [lapTimeCell updateBackgroundColor:self.averageLapTime];
    }
    lapTimeCell.lapNumber.text = [NSString stringWithFormat:@"Lap: %li", [self.runner.runnerSplitTimes count] - (indexPath.row) + 1 ];
    lapTimeCell.lapSplit.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970: lapSplitTime]];
}

- (IBAction)startButtonDidTouchUpInside:(UIButton *)sender {
    switch (self.runner.status) {
        case TimerTableCellReady: //start
            [self.runner startRunner];
            break;
        case TimerTableCellPaused: //continue
            [self.runner resumeRunner];
            break;
        case TimerTableCellRunning: //lap
            [self.runner lapRunner];
            [self.lapTimeTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateAverageLapTime];
            break;
        default:
            break;
    }
    [self updateLapCount:[self.runner.runnerSplitTimes count] + 1 ];

}

- (IBAction)stopButtonDidTouchUpInside:(UIButton *)sender {
    switch (self.runner.status) {
        case TimerTableCellRunning: //stop
            //capture the pause time
            [self.runner pauseRunner];
            break;
        case TimerTableCellPaused: //restart 
            [self.runner restartRunner];
            [self updateLapCount:1];
            [self updateAverageLapTime]; //if only i could kvo nsmutablearray count
            
            [self.lapTimeTable reloadData];
            break;
        default:
            break;
    }
}
- (void) updateScreen
{
    [self updateTimer];
    [self updateCurrentLapCell];
}

- (void) updateTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.totalTimeLabel setText:[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:  [self.runner totalTime]  ]]];
        [self.lapTimeLabel setText:[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970: [self.runner currentLapTime]  ]]];
    });
    
}
- (void) updateCurrentLapCell{
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewLapTimeCell *cell = (UITableViewLapTimeCell *)[self.lapTimeTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.lapSplit.text = self.lapTimeLabel.text;
        
        if([self.runner.runnerSplitTimes count])
            [cell updateBackgroundColor:self.averageLapTime];
    });
}

- (void) updateLapCount:(NSUInteger)count
{
    [self.lapCountLabel setText:[NSString stringWithFormat: @"Lap: %lu", count]];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == MyStatusObservationContextInViewController)
    {
        
        TimerTableCellStatus status = ((NSNumber*)[change objectForKey: NSKeyValueChangeNewKey]).longValue;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case TimerTableCellReady:
                    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];

                    [self updateTimer];
                    break;
                case TimerTableCellRunning:
                    [self.startButton setTitle:@"Lap" forState:UIControlStateNormal];
                    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
                    self.runTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateScreen) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.runTimer forMode:NSRunLoopCommonModes];
                    break;
                case TimerTableCellPaused:
                    //move to observer
                    [self.runTimer invalidate];
                    self.runTimer = nil;
                    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
                    [self.stopButton setTitle:@"Restart" forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
        });
    }
    else if (context == ObserveAverageTimeChanged)
    {
        NSTimeInterval newAverageLapTime = ((NSNumber*)[change objectForKey: NSKeyValueChangeNewKey]).doubleValue;
        for(UITableViewLapTimeCell *cell in [self.lapTimeTable visibleCells])
        {
            NSLog(@"averageTimeChanges");
            if([self.runner.runnerSplitTimes count])
                [cell updateBackgroundColor:newAverageLapTime];
        }
    }
    
}

- (BOOL) prefersTransparentNavigationBar{ return YES; }
- (UIColor *) preferredTitleColor {return [UIColor purpleColor];}

- (void) dealloc
{
    //remove observer
    [self.runTimer invalidate];
    self.runTimer = nil;
    [self removeObserver:self forKeyPath:@"runner.status" context:MyStatusObservationContextInViewController];
    [self removeObserver:self forKeyPath:@"averageLapTime" context:ObserveAverageTimeChanged];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
