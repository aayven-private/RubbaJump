//
//  StatisticsViewController.m
//  RunnerGame
//
//  Created by Ivan Borsa on 15/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "StatisticsViewController.h"
#import "StatisticsManager.h"

@interface StatisticsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *statLabel;

@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *jumpLabel;
@property (nonatomic, weak) IBOutlet UILabel *doubleJumpLabel;
@property (nonatomic, weak) IBOutlet UILabel *barrierLabel;

@property (nonatomic, weak) IBOutlet UIButton *okButton;

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
    
    self.statLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:25.0];
    self.distanceLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:20.0];
    self.jumpLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:20.0];
    self.doubleJumpLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:20.0];
    self.barrierLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:20.0];
    
    self.okButton.titleLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:25.0];
    
    StatisticsHelper *stat = [[StatisticsManager sharedInstance] getStatistics];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"Total distance: %d meters", stat.distance];
    self.jumpLabel.text = [NSString stringWithFormat:@"Total jumps: %d", stat.jumps];
    self.doubleJumpLabel.text = [NSString stringWithFormat:@"Total double jumps: %d", stat.doubleJumps];
    self.barrierLabel.text = [NSString stringWithFormat:@"Total barriers avoided: %d", stat.barriers];
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
