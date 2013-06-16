//
//  PokerGameViewController.m
//  PokerGameClient
//
//  Created by Jacob Kanipe-Illig on 6/14/13.
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import "PokerGameViewController.h"
#import "ServerSelectionViewController.h"
#import "GameSettingsManager.h"

@interface PokerGameViewController ()

@end

@implementation PokerGameViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([GameSettingsManager getServerURL] == nil || [[GameSettingsManager getServerURL] isEqualToString:@""] ){
        ServerSelectionViewController *serverVC = [[ServerSelectionViewController alloc] initWithNibName:@"ServerSelectionViewController" bundle:nil];
        [self presentViewController:serverVC animated:YES completion:nil];
    }
    
    //TODO present game creation view controller
}

@end
