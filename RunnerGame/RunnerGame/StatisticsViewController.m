//
//  StatisticsViewController.m
//  RunnerGame
//
//  Created by Ivan Borsa on 15/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "StatisticsViewController.h"
#import "StatisticsManager.h"
#import "Constants.h"
#import "StrokeLabel.h"
#import "HighScoreManager.h"

@interface StatisticsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *statLabel;

@property (nonatomic, weak) IBOutlet StrokeLabel *distanceLabel;
@property (nonatomic, weak) IBOutlet StrokeLabel *jumpLabel;
@property (nonatomic, weak) IBOutlet StrokeLabel *doubleJumpLabel;
@property (nonatomic, weak) IBOutlet StrokeLabel *barrierLabel;
@property (nonatomic, weak) IBOutlet StrokeLabel *globalPositionLabel;

@property (nonatomic, weak) IBOutlet UIButton *okButton;

@property (nonatomic, weak) IBOutlet UIImageView *bgView;

@end

@implementation StatisticsViewController

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
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        HighScoreManager *manager = [HighScoreManager sharedManager];
        [manager getGlobalPositionFromServerWithCompletion:^(int result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.globalPositionLabel.hidden = NO;
                self.globalPositionLabel.text = [NSString stringWithFormat:@"Global position: %d", result];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:result] forKey:kGlobalPositionKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
        } andFail:^{
            
        }];
    });
    
    self.statLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:25.0];
    self.distanceLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:20.0];
    self.jumpLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:20.0];
    self.doubleJumpLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:20.0];
    self.barrierLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:30.0];
    self.globalPositionLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:20.0];
    
    self.okButton.titleLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:25.0];
    
    StatisticsHelper *stat = [[StatisticsManager sharedInstance] getStatistics];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"Total distance: %d meters", stat.distance];
    self.jumpLabel.text = [NSString stringWithFormat:@"Total jumps: %d", stat.jumps];
    self.doubleJumpLabel.text = [NSString stringWithFormat:@"Total double jumps: %d", stat.doubleJumps];
    self.barrierLabel.text = [NSString stringWithFormat:@"Total Score: %d", stat.barriers];
    
    self.barrierLabel.strokeColor = [UIColor redColor];
    
    if (IS_PHONEPOD5()) {
        self.bgView.image = [UIImage imageNamed:@"statistics_bg_a4-568h"];
    } else {
        self.bgView.image = [UIImage imageNamed:@"statistics_bg_a4"];
    }
    
    NSNumber *globalPos = [[NSUserDefaults standardUserDefaults] objectForKey:kGlobalPositionKey];
    if (globalPos) {
        self.globalPositionLabel.text = [NSString stringWithFormat:@"Global position: %@", globalPos];
    } else {
        self.globalPositionLabel.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)okClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
