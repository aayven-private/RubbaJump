//
//  GameSceneController.m
//  RunnerGame
//
//  Created by Ivan Borsa on 10/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "GameSceneController.h"
#import "GameScene.h"
#import "HighScoreManager.h"
#import "GameOverScene.h"

@interface GameSceneController ()

@property (nonatomic) GameScene *gameScene;

@end

@implementation GameSceneController

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
    
    [GameScene loadSharedAssets];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_gameScene initEnvironment];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        //skView.showsPhysics = NO;
        
        // Create and configure the scene.
        _gameScene = [GameScene sceneWithSize:skView.bounds.size];
        _gameScene.scaleMode = SKSceneScaleModeAspectFill;
        _gameScene.delegate = self;
        
        // Present the scene.
        [skView presentScene:_gameScene];
    }
}

-(void)gameOverWithScore:(int)score
{
    HighScoreHelper *scoreHelper = [[HighScoreHelper alloc] init];
    scoreHelper.score = [NSNumber numberWithInt:score];
    scoreHelper.scoreDate = [NSDate date];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[HighScoreManager sharedManager] addHighScore:scoreHelper];
    });
    
    GameOverScene *gos = [[GameOverScene alloc] initWithSize:self.view.frame.size];
    gos.delegate = self;
    [((SKView *)self.view) presentScene:gos transition:[SKTransition flipHorizontalWithDuration:.5]];
    
}

-(void)quit
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)retry
{
    SKView * skView = (SKView *)self.view;
    
    // Create and configure the scene.
    _gameScene = [GameScene sceneWithSize:skView.bounds.size];
    _gameScene.scaleMode = SKSceneScaleModeAspectFill;
    _gameScene.delegate = self;
    
    // Present the scene.
    [skView presentScene:_gameScene transition:[SKTransition flipHorizontalWithDuration:.5]];
    [_gameScene initEnvironment];
}

@end
