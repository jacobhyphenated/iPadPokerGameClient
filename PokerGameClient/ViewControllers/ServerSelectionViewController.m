//
//  ServerSelectionViewController.m
//  PokerGameClient
//
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import "ServerSelectionViewController.h"
#import "GameSettingsManager.h"
#import "AFNetworking.h"

@interface ServerSelectionViewController ()

@end

@implementation ServerSelectionViewController

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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *oldServerUrl = [GameSettingsManager getServerURL];
    if(oldServerUrl != nil && ![oldServerUrl isEqualToString:@""]){
        [self.serverURLTextField setText:oldServerUrl];
        [self checkServerURL];
    }else{
        self.saveButton.alpha = .5;
    }
}

#pragma mark -text changed IBAction
- (IBAction)serverTextFieldChanged:(id)sender{
    [self checkServerURL];
}

#pragma mark -button tap delegates
- (IBAction)saveButtonTap:(id)sender {
    //TODO
    NSLog(@"Save BUtton tap");
    [GameSettingsManager saveServerUrl:self.serverURLTextField.text];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -networking methods
-(void) checkServerURL{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.serverURLTextField.text,@"/ping"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if([JSON valueForKeyPath:@"success"]){
            self.saveButton.enabled = YES;
            self.saveButton.alpha = 1;
            [self.correctServerIcon setImage:[UIImage imageNamed:@"button_green.png"]];
        }
        else{
            [self incorrectServer];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        [self incorrectServer];
    }];
    [operation start];
}

#pragma mark -private helper methods
-(void) incorrectServer{
    self.saveButton.enabled = NO;
    self.saveButton.alpha = .5;
    [self.correctServerIcon setImage:[UIImage imageNamed:@"button_red.png"]];
}

- (void)viewDidUnload {
    [self setServerURLTextField:nil];
    [self setCorrectServerIcon:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}


@end
