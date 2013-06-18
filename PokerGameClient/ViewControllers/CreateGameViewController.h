//
//  CreateGameViewController.h
//  PokerGameClient
//
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGameViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *gameNameField;
@property (weak, nonatomic) IBOutlet UITextField *structureField;
@property (weak, nonatomic) IBOutlet UITableView *structureTable;
@property (weak, nonatomic) IBOutlet UIButton *createGameButton;

- (IBAction)createButtonTap:(id)sender;

@end
