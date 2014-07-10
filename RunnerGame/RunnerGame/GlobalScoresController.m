//
//  GlobalScoresController.m
//  RunnerGame
//
//  Created by Ivan Borsa on 10/07/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "GlobalScoresController.h"
#import "HighScoreManager.h"
#import "Constants.h"
#import "HighScoreCell.h"

@interface GlobalScoresController ()

@property (nonatomic, weak) IBOutlet UIButton *okButton;

@property (nonatomic, weak) IBOutlet UITableView *highScoresTable;
@property (nonatomic, weak) IBOutlet UIImageView *bgView;

@property (nonatomic) int lastMaxScore;

@property (nonatomic) NSDictionary *scores;
@property (nonatomic) NSUInteger selfPosition;
@property (nonatomic) GlobalScoreHelper *selfResult;

@property (nonatomic) int selfGlobalPosition;

@end

@implementation GlobalScoresController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    NSNumber *lastScore = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUploadedScoreKey];
    if (!lastScore) {
        lastScore = [NSNumber numberWithInt:[[HighScoreManager sharedManager] getMaximumHighScore]];
    }
    self.lastMaxScore = lastScore.intValue;
    
    self.scores = [[HighScoreManager sharedManager] getGlobalScores];
    
    NSArray *more = [self.scores objectForKey:@"more"];
    self.selfPosition = more.count;
    
    self.selfResult = [[GlobalScoreHelper alloc] init];
    self.selfResult.score = lastScore;
    self.selfResult.userName = @"YOU";
    
    
    NSNumber *globalPos = [[NSUserDefaults standardUserDefaults] objectForKey:kGlobalPositionKey];
    if (!globalPos) {
        globalPos = [NSNumber numberWithInt:1];
    }
    self.selfGlobalPosition = globalPos.intValue;
    self.selfResult.position = [NSNumber numberWithInteger:self.selfGlobalPosition];
    
    [_highScoresTable reloadData];
    
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[HighScoreManager sharedManager] downloadSurroundingsWithCompletion:^(NSDictionary *scores) {
            self.scores = scores;
            NSArray *more = [self.scores objectForKey:@"more"];
            self.selfPosition = more.count;
            NSNumber *lastScore = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUploadedScoreKey];
            
            if (!lastScore) {
                lastScore = [NSNumber numberWithInt:[[HighScoreManager sharedManager] getMaximumHighScore]];
            }
            self.lastMaxScore = lastScore.intValue;
            
            self.selfResult = [[GlobalScoreHelper alloc] init];
            self.selfResult.score = lastScore;
            self.selfResult.userName = @"YOU";
            
            
            NSNumber *globalPos = [[NSUserDefaults standardUserDefaults] objectForKey:kGlobalPositionKey];
            if (!globalPos) {
                globalPos = [NSNumber numberWithInt:1];
            }
            self.selfGlobalPosition = globalPos.intValue;
            
            self.selfResult.position = [NSNumber numberWithInteger:self.selfGlobalPosition];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_highScoresTable reloadData];
            });
        } andFail:^{
            
        }];
    });
    
    self.okButton.titleLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:25.0];
    
    if (IS_PHONEPOD5()) {
        self.bgView.image = [UIImage imageNamed:@"high_score_bg_a4-568h"];
    } else {
        self.bgView.image = [UIImage imageNamed:@"high_score_bg_a4"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"highScoreCell";
    
    HighScoreCell *cell = (HighScoreCell *)[_highScoresTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HighScoreCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[HighScoreCell class]]) {
                cell = (HighScoreCell *) currentObject;
                break;
            }
        }
        
        cell.indexLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:30.0];
        cell.scoreLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:30.0];
        cell.distanceLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:15.0];
    }
    
    GlobalScoreHelper *cellData = nil;
    
    NSArray *more = [_scores objectForKey:@"more"];
    NSArray *less = [_scores objectForKey:@"less"];
    
    int position = 0;
    
    if (indexPath.row < self.selfPosition) {
        cellData = [more objectAtIndex:indexPath.row];
        position = _selfGlobalPosition - (more.count - indexPath.row);
    } else if (indexPath.row > self.selfPosition) {
        cellData = [less objectAtIndex:indexPath.row - more.count - 1];
        position = _selfGlobalPosition + (indexPath.row - self.selfPosition);
    } else {
        cellData = _selfResult;
        position = _selfGlobalPosition;
    }
    
    cell.indexLabel.text = [NSString stringWithFormat:@"%d.", position];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d", cellData.score.intValue];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%@", cellData.userName ? cellData.userName : @"anonym"];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *more = [_scores objectForKey:@"more"];
    NSArray *less = [_scores objectForKey:@"less"];
    return more.count + less.count + 1;
}

-(IBAction)okClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HighScoreCell *hsCell = (HighScoreCell *)cell;
    if (indexPath.row == self.selfPosition) {
        hsCell.distanceLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:20.0];
        hsCell.distanceLabel.textColor = [UIColor redColor];
    } else {
        hsCell.distanceLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:15.0];
        hsCell.distanceLabel.textColor = [UIColor lightGrayColor];
    }
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
