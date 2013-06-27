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
    NSInteger timerMillis;
}

@end

@implementation PokerGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
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
    self.blindTimerLabel.text = @"";
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
        if([[JSON valueForKey:@"success"] boolValue]){
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
    //TODO need spinner
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
    NSString* serverURL = [GameSettingsManager getServerURL];
    NSInteger gameId = [GameSettingsManager getGameId];
    NSInteger handId = [GameSettingsManager getHandId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",serverURL, @"endhand"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:gameId], @"gameId", [NSNumber numberWithInt:handId], @"handId",  nil];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if([[JSON valueForKey:@"success"] boolValue]){
            [self getGameStatus];
        }else{
            [self endHandFail];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        NSLog(@"%@",error);
        NSLog(@"%@",param);
        [self endHandFail];
    }];
    [operation start];
}

- (IBAction)dealFlopButtonTap:(id)sender {
    NSString* serverURL = [GameSettingsManager getServerURL];
    NSInteger gameId = [GameSettingsManager getGameId];
    NSInteger handId = [GameSettingsManager getHandId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",serverURL, @"flop"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:gameId], @"gameId", [NSNumber numberWithInt:handId], @"handId",  nil];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //Animate each flop card into view
        NSString *card1ID = [JSON valueForKey:@"card1"];
        NSString *card2ID = [JSON valueForKey:@"card2"];
        NSString *card3ID = [JSON valueForKey:@"card3"];
        [self animateDealCard:self.card1 identifier:card1ID withDelay:0];
        [self animateDealCard:self.card2 identifier:card2ID withDelay:.2];
        [self animateDealCard:self.card3 identifier:card3ID withDelay:.4];
        
        //Wait until new cards are animated in, then update game status with new info for the flop.
        double delayInSeconds = .7;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self getGameStatus];
        });
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        NSLog(@"%@",error);
        NSLog(@"%@",param);
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not deal the flop" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
    }];
    [operation start];}

- (IBAction)dealTurnButtonTap:(id)sender {
    NSString* serverURL = [GameSettingsManager getServerURL];
    NSInteger gameId = [GameSettingsManager getGameId];
    NSInteger handId = [GameSettingsManager getHandId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",serverURL, @"turn"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:gameId], @"gameId", [NSNumber numberWithInt:handId], @"handId",  nil];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //Animate each flop card into view
        NSString *card4ID = [JSON valueForKey:@"card4"];
        [self animateDealCard:self.card4 identifier:card4ID withDelay:0];
        
        //Wait until new cards are animated in, then update game status with new info for the flop.
        double delayInSeconds = .3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self getGameStatus];
        });
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        NSLog(@"%@",error);
        NSLog(@"%@",param);
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not deal the turn" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
    }];
    [operation start];
}

- (IBAction)dealRiverButtonTap:(id)sender {
    NSString* serverURL = [GameSettingsManager getServerURL];
    NSInteger gameId = [GameSettingsManager getGameId];
    NSInteger handId = [GameSettingsManager getHandId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",serverURL, @"river"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:gameId], @"gameId", [NSNumber numberWithInt:handId], @"handId",  nil];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //Animate each flop card into view
        NSString *card5ID = [JSON valueForKey:@"card5"];
        [self animateDealCard:self.card5 identifier:card5ID withDelay:0];
        
        //Wait until new cards are animated in, then update game status with new info for the flop.
        double delayInSeconds = .3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self getGameStatus];
        });
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        NSLog(@"%@",error);
        NSLog(@"%@",param);
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not deal the river" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
    }];
    [operation start];
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

-(void) endHandState: (id)JSON{
    [self riverState:JSON];
    
    [self.endHandButton setHidden:YES];
    [self.startHandButton setHidden:NO];
    self.stateLabel.text = @"End Hand";
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
    self.potChips.text = [NSString stringWithFormat:@"%i", [[JSON valueForKey:@"pot"] intValue]];
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
        else if([gameStatus isEqualToString:@"END_HAND"]){
            [self endHandState:JSON];
        }
        else{
            NSLog(@"ERROR STATE: %@", gameStatus );
        }
        
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

-(void) endHandFail{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not end hand" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];
}

-(void) animateDealCard:(UIImageView *)cardView identifier:(NSString *) cardIdentifier withDelay:(NSTimeInterval)delay{
    //Copy the card view's frame to modify postions. Use __block to allow modifying the CGRect in the block
    
    __block CGRect cardFrame = cardView.frame;
    
    //Move card off the view port to the top
    int cardY = cardFrame.origin.y;
    int cardX = cardFrame.origin.x;
    cardFrame.origin.y = - 150;
    cardFrame.origin.x = - 250;
    cardView.frame = cardFrame;
    
    //Reveal card and set appropriate card image
    [cardView setHidden:NO];
    cardView.image = [UIImage imageNamed:[CardImageManager imageIdentifierFromKey:cardIdentifier]];
    [UIView animateWithDuration:.3 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //Animate card back to original location
        cardFrame.origin.y = cardY;
        cardFrame.origin.x = cardX;
        cardView.frame = cardFrame;
    }completion:nil];
}

#pragma mark -Timer Methods
-(void) startBlindTimerCountdown:(NSInteger)timeInMillis{
    [blindTimer invalidate];
    timerMillis = timeInMillis;
    blindTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(blindTimerTriggered:) userInfo:nil repeats:YES];
}

-(void) blindTimerTriggered:(NSTimer *)timer{
    if(timerMillis <= 0){
        [blindTimer invalidate];
        self.blindTimerLabel.text = @"0:00";
        return;
    }
    NSInteger secondsTotal = timerMillis / 1000;
    NSInteger minutesTotal = secondsTotal / 60;
    NSInteger seconds = secondsTotal % 60;
    self.blindTimerLabel.text = [NSString stringWithFormat:@"%d:%02d",minutesTotal,seconds];
    timerMillis = timerMillis - 1000;
}

@end
