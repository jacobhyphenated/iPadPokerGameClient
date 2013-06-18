//
//  PokerGameViewController.m
//  PokerGameClient
//
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import "PokerGameViewController.h"
#import "ServerSelectionViewController.h"
#import "GameSettingsManager.h"
#import "CreateGameViewController.h"
#import "AFNetworking.h"
#import "CardImageManager.h"

@interface PokerGameViewController (){
    NSArray *playerList;
    NSTimer *blindTimer;
}

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
    
    self.seatingTableView.delegate = self;
    self.seatingTableView.dataSource = self;
    [self.seatingTableView setSeparatorColor:[UIColor clearColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    //Neutral state UI appearance
    [super viewWillAppear:animated];
    self.potChips.alpha = 0;
    self.potChipsLabel.alpha = 0;
    [self.card1 setHidden:YES];
    [self.card2 setHidden:YES];
    [self.card3 setHidden:YES];
    [self.card4 setHidden:YES];
    [self.card5 setHidden:YES];
    [self.dealFlopButton setHidden:YES];
    [self.dealTurnButton setHidden:YES];
    [self.dealRiverButton setHidden:YES];
    [self.startHandButton setHidden:YES];
    [self.startGameButton setHidden:YES];
    [self.endHandButton setHidden:YES];
    [self.seatingTableView setHidden:YES];
    [self.gameIdDescriptionLabel setHidden:YES];
    [self.gameIdLabel setHidden:YES];
    self.stateLabel.text = @"Waiting...";
    self.blindsLabel.text = @"not started";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"Game ID: %i", [GameSettingsManager getGameId]);
    if([GameSettingsManager getServerURL] == nil || [[GameSettingsManager getServerURL] isEqualToString:@""] ){
        ServerSelectionViewController *serverVC = [[ServerSelectionViewController alloc] initWithNibName:@"ServerSelectionViewController" bundle:nil];
        [self presentViewController:serverVC animated:YES completion:nil];
    }
    else if([GameSettingsManager getGameId] <= 0){
        CreateGameViewController *createGameVC = [[CreateGameViewController alloc] initWithNibName:@"CreateGameViewController" bundle:nil];
        [self presentViewController:createGameVC animated:YES completion:nil];
    }
    else{
        [self getGameStatus];
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [blindTimer invalidate];
}

- (void)viewDidUnload {
    blindTimer = nil;
    [self setCard1:nil];
    [self setCard2:nil];
    [self setCard3:nil];
    [self setCard4:nil];
    [self setCard5:nil];
    [self setPotChips:nil];
    [self setStateLabel:nil];
    [self setBlindsLabel:nil];
    [self setStartGameButton:nil];
    [self setDealFlopButton:nil];
    [self setStartHandButton:nil];
    [self setEndHandButton:nil];
    [self setPotChipsLabel:nil];
    [self setSeatingTableView:nil];
    [self setGameIdLabel:nil];
    [self setGameIdDescriptionLabel:nil];
    [self setBlindTimerLabel:nil];
    [self setDealTurnButton:nil];
    [self setDealRiverButton:nil];
    [super viewDidUnload];
}

#pragma mark - Alert View Delegate Methods
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    //Clear all data pressed
    if(buttonIndex > 0){
        //Clear settings and present server url view controller
        [GameSettingsManager saveGameId:0];
        [GameSettingsManager saveServerUrl:@""];
        [GameSettingsManager saveHandId:0];
        ServerSelectionViewController *serverVC = [[ServerSelectionViewController alloc] initWithNibName:@"ServerSelectionViewController" bundle:nil];
        [self presentViewController:serverVC animated:YES completion:nil];
    }
}

#pragma mark - Button Delegate Methods
- (IBAction)clearInfoButtonTap:(id)sender {
    UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to clear all game data?  The game cannot be recovered." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [confirm show];
}

- (IBAction)startGameButtonTap:(id)sender {
    NSString* serverURL = [GameSettingsManager getServerURL];
    NSInteger gameId = [GameSettingsManager getGameId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",serverURL, @"startgame"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:gameId], @"gameId", nil];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(!![JSON valueForKey:@"success"]){
            self.stateLabel.text = @"Starting...";
            [self getGameStatus];
        }
        else{
            [self gameStartFail];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        NSLog(@"%@",error);
        NSLog(@"%@",param);
        [self gameStartFail];
    }];
    [operation start];
}

- (IBAction)startHandButtonTap:(id)sender {
    NSString* serverURL = [GameSettingsManager getServerURL];
    NSInteger gameId = [GameSettingsManager getGameId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",serverURL, @"starthand"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:gameId], @"gameId", nil];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSInteger handId = [[JSON valueForKey:@"handId"] intValue];
        if(handId > 0){
            [GameSettingsManager saveHandId:handId];
            self.stateLabel.text = @"Starting Hand...";
            [self getGameStatus];
        }
        else{
            [self handStartFail];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        NSLog(@"%@",error);
        NSLog(@"%@",param);
        [self handStartFail];
    }];
    [operation start];
}

- (IBAction)endHandButtonTap:(id)sender {
    //TODO - Display end hand information?
}

- (IBAction)dealFlopButtonTap:(id)sender {
    //TODO - Transition from preflop-->flop
}

- (IBAction)dealTurnButtonTap:(id)sender {
    //TODO - Transition from flop-->turn
}

- (IBAction)dealRiverButtonTap:(id)sender {
    //TODO - Transition from turn-->river
}

#pragma mark - UITableView Delegate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    // Acquire the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *playerName = [[playerList objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString *gameLocation = [[playerList objectAtIndex:indexPath.row] valueForKey:@"gamePosition"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:  %@",playerName, gameLocation];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return [playerList count];
    }
    return 0;
}


#pragma mark - State Transitions
-(void)notStartedState{
    [self.startGameButton setHidden:NO];
    [self.gameIdDescriptionLabel  setHidden:NO];
    [self.gameIdLabel setHidden:NO];
    self.gameIdLabel.text = [NSString stringWithFormat:@"%i" ,[GameSettingsManager getGameId]];
    self.stateLabel.text = @"Not Started";
}

-(void) seatingStateWithPlayers:(id)JSON{
    //Transition out of Not Started State
    [self.gameIdLabel setHidden:YES];
    [self.gameIdDescriptionLabel setHidden:YES];
    [self.startGameButton setHidden:YES];
    
    //Set up Seating State
    playerList = [JSON valueForKey:@"players"];
    [self.seatingTableView  setHidden:NO];
    [self.seatingTableView reloadData];
    NSString *smallBlind = [JSON valueForKey:@"smallBlind"];
    NSString *bigBlind = [JSON valueForKey:@"bigBlind"];
    [self updateUIWithSmallBlind:smallBlind bigBlind:bigBlind];
    [self.startHandButton setHidden:NO];
    self.startHandButton.titleLabel.text = @"Start Hand";
    [self.stateLabel setText:@"Seating"];
}

-(void) preflopState:(id)JSON{
    //Hide any non-game fields from the seating state
    [self.seatingTableView  setHidden:YES];
    [self.startHandButton setHidden:YES];
    //Do not show cards
    UIImage *cardBg = [UIImage imageNamed:@"card_bg.png"];
    [self.card1 setHidden:YES];
    self.card1.image = cardBg;
    [self.card2 setHidden:YES];
    self.card2.image = cardBg;
    [self.card3 setHidden:YES];
    self.card3.image = cardBg;
    [self.card4 setHidden:YES];
    self.card4.image = cardBg;
    [self.card5 setHidden:YES];
    self.card5.image = cardBg;
    
    [self setInHandUIState:JSON];
    self.stateLabel.text = @"Preflop";
    [self.dealFlopButton setHidden:NO];
}

-(void) flopState:(id)JSON{
    [self setInHandUIState:JSON];
    self.stateLabel.text = @"Flop";
    NSArray *cardArray = [JSON valueForKey:@"cards"];
    self.card1.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:0]]];
    [self.card1 setHidden:NO];
    self.card2.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:1]]];
    [self.card2 setHidden:NO];
    self.card3.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:2]]];
    [self.card3 setHidden:NO];
    [self.dealTurnButton setHidden:NO];
}

-(void) turnState:(id)JSON{
    [self setInHandUIState:JSON];
    self.stateLabel.text = @"Turn";
    NSArray *cardArray = [JSON valueForKey:@"cards"];
    self.card1.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:0]]];
    [self.card1 setHidden:NO];
    self.card2.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:1]]];
    [self.card2 setHidden:NO];
    self.card3.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:2]]];
    [self.card3 setHidden:NO];
    self.card4.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:3]]];
    [self.card4 setHidden:NO];
    [self.dealRiverButton setHidden:NO];
}

-(void) riverState:(id)JSON{
    [self setInHandUIState:JSON];
    self.stateLabel.text = @"River";
    NSArray *cardArray = [JSON valueForKey:@"cards"];
    self.card1.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:0]]];
    [self.card1 setHidden:NO];
    self.card2.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:1]]];
    [self.card2 setHidden:NO];
    self.card3.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:2]]];
    [self.card3 setHidden:NO];
    self.card4.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:3]]];
    [self.card4 setHidden:NO];
    self.card5.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:[cardArray objectAtIndex:4]]];
    [self.card5 setHidden:NO];
}

-(void) setInHandUIState:(id)JSON{
    NSString *smallBlind = [JSON valueForKey:@"smallBlind"];
    NSString *bigBlind = [JSON valueForKey:@"bigBlind"];
    [self updateUIWithSmallBlind:smallBlind bigBlind:bigBlind];
    NSInteger millis = [[JSON valueForKey:@"blindTime"] intValue];
    [self startBlindTimerCountdown:millis];
    [self.endHandButton setHidden:NO];
    
    //Hide all deal buttons. Individual states will show appropriate button
    [self.dealFlopButton setHidden:YES];
    [self.dealTurnButton setHidden:YES];
    [self.dealRiverButton setHidden:YES];
    
    self.potChips.alpha = 1;
    self.potChipsLabel.alpha = 1;
    self.potChips.text = [JSON valueForKey:@"chips"];
}


#pragma mark - Private Helper Methods

#pragma mark -Network Methods
-(void)getGameStatus{
    NSString* serverURL = [GameSettingsManager getServerURL];
    NSInteger gameId = [GameSettingsManager getGameId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",serverURL, @"gamestatus"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:gameId], @"gameId", nil];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString* gameStatus = [JSON valueForKey:@"gameStatus"];
        if([gameStatus isEqualToString:@"NOT_STARTED"]){
            [self notStartedState];
        }
        else if([gameStatus isEqualToString:@"SEATING"]){
            [self seatingStateWithPlayers:JSON];
        }
        else if([gameStatus isEqualToString:@"PREFLOP"]){
            [self preflopState:JSON];
        }
        else if([gameStatus isEqualToString:@"FLOP"]){
            [self flopState:JSON];
        }
        else if([gameStatus isEqualToString:@"TURN"]){
            [self turnState:JSON];
        }
        else if([gameStatus isEqualToString:@"RIVER"]){
            [self riverState:JSON];
        }
        else{
            NSLog(@"ERROR STATE: %@", gameStatus );
        }
        //TODO - end hand
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        NSLog(@"%@",error);
        NSLog(@"%@",param);
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cound not retrieve game status" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
    }];
    [operation start];
}

#pragma mark -UI Methods
-(void) updateUIWithSmallBlind:(NSString *)smallBlind bigBlind:(NSString *)bigBlind{
    self.blindsLabel.text = [NSString stringWithFormat:@"%@/%@",smallBlind,bigBlind];
}

-(void) gameStartFail{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Game could not be started" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];
}

-(void) handStartFail{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Hand could not be started" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];
}

#pragma mark -Timer Methods
-(void) startBlindTimerCountdown:(NSInteger)timeInMillis{
    [blindTimer invalidate];
    blindTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(blindTimerTriggered:) userInfo:[NSNumber numberWithInt:timeInMillis] repeats:YES];
}

-(void) blindTimerTriggered:(NSTimer *)timer{
    NSNumber *millis = timer.userInfo;
    NSInteger millisLeft = [millis intValue];
    if(millisLeft <= 0){
        [blindTimer invalidate];
        self.blindTimerLabel.text = @"0:00";
        return;
    }
    NSInteger secondsTotal = millisLeft / 1000;
    NSInteger minutesTotal = secondsTotal / 60;
    NSInteger seconds = secondsTotal % 60;
    self.blindTimerLabel.text = [NSString stringWithFormat:@"%i:%i",minutesTotal,seconds];
}

@end
