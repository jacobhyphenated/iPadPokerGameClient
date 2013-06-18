//
//  PokerGameViewController.h
//  PokerGameClient
//
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PokerGameViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *card1;
@property (weak, nonatomic) IBOutlet UIImageView *card2;
@property (weak, nonatomic) IBOutlet UIImageView *card3;
@property (weak, nonatomic) IBOutlet UIImageView *card4;
@property (weak, nonatomic) IBOutlet UIImageView *card5;
@property (weak, nonatomic) IBOutlet UILabel *potChipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *potChips;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *blindsLabel;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (weak, nonatomic) IBOutlet UIButton *dealFlopButton;
@property (weak, nonatomic) IBOutlet UIButton *dealTurnButton;
@property (weak, nonatomic) IBOutlet UIButton *dealRiverButton;
@property (weak, nonatomic) IBOutlet UIButton *startHandButton;
@property (weak, nonatomic) IBOutlet UIButton *endHandButton;
@property (weak, nonatomic) IBOutlet UITableView *seatingTableView;
@property (weak, nonatomic) IBOutlet UILabel *gameIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameIdDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *blindTimerLabel;

- (IBAction)clearInfoButtonTap:(id)sender;
- (IBAction)startGameButtonTap:(id)sender;
- (IBAction)startHandButtonTap:(id)sender;
- (IBAction)endHandButtonTap:(id)sender;
- (IBAction)dealFlopButtonTap:(id)sender;
- (IBAction)dealTurnButtonTap:(id)sender;
- (IBAction)dealRiverButtonTap:(id)sender;


@end
