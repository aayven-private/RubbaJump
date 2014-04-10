//
//  HighScoresController.m
//  RunnerGame
//
//  Created by Ivan Borsa on 10/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "HighScoresController.h"
#import "HighScoreManager.h"
#import "HighScoreCell.h"

@interface HighScoresController ()

@property (nonatomic, weak) IBOutlet UIButton *okButton;

@property (nonatomic, weak) IBOutlet UITableView *highScoresTable;

@property (nonatomic) NSArray *scores;

@end

@implementation HighScoresController

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
    self.scores = [[HighScoreManager sharedManager] getHighScores];
    [_highScoresTable reloadData];
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
    }
    
    HighScoreHelper *cellData = [_scores objectAtIndex:indexPath.row];
    
    cell.indexLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d", cellData.score.intValue];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _scores.count;
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
