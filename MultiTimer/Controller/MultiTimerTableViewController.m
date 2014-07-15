//
//  MultiTimerTableViewController.m
//  MultiTimer
//
//  Created by Ryan Brooks on 3/22/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

static void * RunnerStatusObservationContext = &RunnerStatusObservationContext;


#import "MultiTimerTableViewController.h"
#import "SingleTimedRunnerViewController.h"
#import "NavigationBarAppearance.h"
#import "TimerTableViewCell.h"
#import "TimedRunner.h"

@interface MultiTimerTableViewController ()  <UITableViewDataSource,     UITableViewDelegate, TimerTableViewCellDelegate,UITextFieldDelegate, UIAlertViewDelegate,NavigationBarAppearance>

@property (weak, nonatomic) IBOutlet UITableView *timerTable;
@property NSTimer *timer;
@property NSMutableArray *timedRunners;
@property UIAlertView *addRunnerAlertView;

@property UIButton *leftButton;
@property UIButton *rightButton;

@property TimerTableViewCell *expandedCell;

@end

@implementation MultiTimerTableViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"MultiTimer";
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Timers" style:UIBarButtonItemStylePlain target:nil action:nil]];
    self.timedRunners = [NSMutableArray new];
    // Do any additional setup after loading the view from its nib.
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitle:@"Add" forState:UIControlStateNormal];
    [self.rightButton sizeToFit];
    [self.rightButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [self.rightButton setTintColor:[UIColor clearColor]];
    [self.rightButton addTarget:self action:@selector(addRunner) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithCustomView:self.rightButton]];

    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.leftButton setTitle:@"Done" forState:UIControlStateSelected];
    [self.leftButton sizeToFit];
    [self.leftButton setFrame:CGRectMake(self.leftButton.frame.origin.x, self.leftButton.frame.origin.y, self.leftButton.frame.size.width+20, self.leftButton.frame.size.height)];
    [self.leftButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [self.leftButton setTintColor:[UIColor clearColor]];
    [self.leftButton addTarget:self action:@selector(toggleEditing) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithCustomView:self.leftButton]];
}

- (void) viewWillAppear:(BOOL)animated
{
    if(self.expandedCell)
    {
        NSIndexPath *index = [self.timerTable indexPathForCell:self.expandedCell];
        TimedRunner *runner = [self.timedRunners objectAtIndex: index.row ];
        [self  updateCell:self.expandedCell WithRunnerInfo:runner];
        self.expandedCell = nil;
    }
}


- (void) addRunner
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addRunnerAlertView = [[UIAlertView alloc]initWithTitle:@"Title" message:@"Enter Runner's Name" delegate:self cancelButtonTitle:@"Nvm" otherButtonTitles:@"Time me!", nil];
        self.addRunnerAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [self.addRunnerAlertView textFieldAtIndex:0].delegate = self;
        [((UITextField *)[self.addRunnerAlertView textFieldAtIndex:0]) setAutocorrectionType:UITextAutocorrectionTypeYes];
        [self.addRunnerAlertView show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[self.addRunnerAlertView buttonTitleAtIndex:buttonIndex] isEqual:@"Time me!"])
    {
        NSString *newRunnerName =  [self.addRunnerAlertView textFieldAtIndex:0].text;
        TimedRunner *newRunner = [[TimedRunner alloc ] init];
        newRunner.runnerName = newRunnerName;
        
        //add a new runner model to the data source
        [self.timedRunners insertObject:newRunner atIndex:0];
        [self.timerTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //observe status on the runner
        [newRunner addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:RunnerStatusObservationContext];
    }
    [self.addRunnerAlertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

- (void) toggleEditing
{
    if(self.timerTable.isEditing)
    {
        [self.rightButton setEnabled:YES];
        [self.rightButton setAlpha:1];
        [self.leftButton setSelected:NO];
        [self.timerTable setEditing:NO animated:YES];
    }
    else
    {
        if([self.timedRunners count])
        {
            
            [self.rightButton setEnabled:NO];
            [self.rightButton setAlpha:.5];
            [self.leftButton setSelected:YES];
            [self.timerTable setEditing:YES animated:YES];
        }
    }
}
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimedRunner *runner = [self.timedRunners objectAtIndex:indexPath.row];
    [self updateTimerTableCellView:(TimerTableViewCell *)[self.timerTable cellForRowAtIndexPath:indexPath] toTimerViewStatus:TimerTableCellPaused];
    [self.timedRunners removeObjectAtIndex:indexPath.row];
    [self.timerTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [runner removeObserver:self forKeyPath:@"status" context:RunnerStatusObservationContext];
    
    if(![self.timedRunners count])
    {
        [self toggleEditing];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimedRunner *runner = [self.timedRunners objectAtIndex:indexPath.row];
    SingleTimedRunnerViewController *strvc = [[SingleTimedRunnerViewController alloc ] init];
    strvc.runner = runner;
    if([self.navigationController topViewController] == self)
    {
        self.expandedCell = (TimerTableViewCell *)[self.timerTable cellForRowAtIndexPath:indexPath];
        [self.expandedCell.timer invalidate];
        self.expandedCell.timer = nil;
        [self.navigationController pushViewController:strvc animated:YES];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timedRunners count];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"TimedRunner";
    
    TimerTableViewCell *cell = (TimerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TimerTableViewCell" owner:self options:nil];
        cell = (TimerTableViewCell *)[nib objectAtIndex:0];
    }

    TimedRunner *runner = (TimedRunner*)[self.timedRunners objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.nameLabel.text = runner.runnerName;
    [self updateCell:cell WithRunnerInfo:runner];
    [self updateTimerTableCellView:cell toTimerViewStatus:runner.status];
    return cell;
}

- (void) updateCell:(TimerTableViewCell *)cell WithRunnerInfo:(TimedRunner *)runner
{

    [cell setTotalTimeLabelTime: [runner totalTime]];
    [cell setLapTimeLabelTime: [runner currentLapTime]];
    [cell setCurrentLapCountText: [runner currentLapNumber]];

}

-  (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //invalidate the timer
    NSLog(@"cell end displaying");
    [((TimerTableViewCell *)cell).timer invalidate];
    ((TimerTableViewCell *)cell).timer = nil;
}

- (void) timerTableViewCelldidTouchStart:(TimerTableViewCell *)timerCell
{
    TimedRunner *runner = [self.timedRunners objectAtIndex: [self.timerTable indexPathForCell:timerCell].row];
    switch (runner.status) {
        case TimerTableCellReady: //start
            [runner startRunner];
            break;
        case TimerTableCellPaused: //continue
            [runner resumeRunner];
            break;
        case TimerTableCellRunning: //lap
            [runner lapRunner];
            break;
        default:
            break;
    }
    [timerCell setCurrentLapCountText:[runner currentLapTime]];
}


- (void) timerTableViewCelldidTouchStop:(TimerTableViewCell *)timerCell
{
    TimedRunner *runner = [self.timedRunners objectAtIndex: [self.timerTable indexPathForCell:timerCell].row];
    switch (runner.status) {
        case TimerTableCellRunning: //stop
            //capture the pause time
            [runner pauseRunner];
            break;
        case TimerTableCellPaused: //restart
            [runner restartRunner];
            break;
        default:
            break;
    }
}

- (void) timerTableViewCelldidRequestTimerUpdate:(TimerTableViewCell *)timerCell
{
    //get the runner
    TimedRunner *runner = [self.timedRunners objectAtIndex: [self.timerTable indexPathForCell:timerCell].row];
    [self updateCell:timerCell WithRunnerInfo:runner];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == RunnerStatusObservationContext)
    {
        //object = runner
        TimerTableCellStatus status = ((NSNumber*)[change objectForKey: NSKeyValueChangeNewKey]).longValue;
        TimerTableViewCell *timerCell = (TimerTableViewCell *)[self.timerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow: [self.timedRunners indexOfObject:object]  inSection:0]];
        [self updateTimerTableCellView:timerCell toTimerViewStatus:status];
    }
}

- (void) updateTimerTableCellView:(TimerTableViewCell *)timerCell toTimerViewStatus:(TimerTableCellStatus )status
{
    switch (status) {
        case TimerTableCellReady:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [timerCell.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
                //[timerCell.stopButton setAlpha:.5];
                //[timerCell.stopButton setEnabled:NO];
                [timerCell setTotalTimeLabelTime:0];
                [timerCell setLapTimeLabelTime:0];
                [timerCell setCurrentLapCountText:1];
            });
        }
            break;
        case TimerTableCellRunning:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [timerCell.startButton setTitle:@"Lap" forState:UIControlStateNormal];
                [timerCell.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
                //[timerCell.stopButton setAlpha:1];
                //[timerCell.stopButton setEnabled:YES];
            });
            
            timerCell.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:timerCell selector:@selector(requestTimersUpdate) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timerCell.timer forMode:NSRunLoopCommonModes];
            
        }
            break;
        case TimerTableCellPaused:
        {
            //move to observer
            dispatch_async(dispatch_get_main_queue(), ^{
                [timerCell.startButton setTitle:@"Start" forState:UIControlStateNormal];
                [timerCell.stopButton setTitle:@"Restart" forState:UIControlStateNormal];
            });
            NSLog(@"paused");
            [timerCell.timer invalidate];
            timerCell.timer  = nil;
        }
            break;
        default:
        {}
            break;
    }
}

- (BOOL) prefersTransparentNavigationBar{ return NO; }
- (UIColor *) preferredTitleColor {return [UIColor blackColor];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    for(TimedRunner *runner in self.timedRunners)
    {
        [runner removeObserver:self forKeyPath:@"status" context:RunnerStatusObservationContext];
    }
    for(TimerTableViewCell *cell in [self.timerTable indexPathsForVisibleRows])
    {
       
        [cell.timer invalidate];
        cell.timer = nil;
    }
}

@end
