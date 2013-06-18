//
//  CreateGameViewController.m
//  PokerGameClient
//
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import "CreateGameViewController.h"
#import "GameSettingsManager.h"
#import "AFNetworking.h"

@interface CreateGameViewController (){
    NSMutableArray *tableData;
}

@end

@implementation CreateGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Default to loading text
        tableData = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObject:@"Loading..." forKey:@"text"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set table view delegate
    [self.structureTable setDelegate:self];
    [self.structureTable setDataSource:self];
    
    //Make a request for the game structures
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[GameSettingsManager getServerURL], @"structures"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //Load table data with info from successful request.  Reload table.
        [tableData removeAllObjects];
        for(id entry in JSON){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
            [dict setValue:[entry valueForKey:@"description"] forKey:@"text"];
            [dict setValue:[entry valueForKey:@"name"] forKey:@"id"];
            [tableData addObject:dict];
        }
        [self.structureTable reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cound not retrieve tournament structures from server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
    }];
    [operation start];
}

- (void)viewDidUnload {
    [self setGameNameField:nil];
    [self setStructureField:nil];
    [self setStructureTable:nil];
    [self setCreateGameButton:nil];
    [super viewDidUnload];
}

#pragma mark - Button Delegate
- (IBAction)createButtonTap:(id)sender {
    NSString *gameName = self.gameNameField.text;
    NSString *structure = self.structureField.text;
    if([gameName isEqualToString:@""] || [structure isEqualToString:@""]){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You must enter a game name and select a game structure before creating the game." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        return;
    }

    //Create game request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[GameSettingsManager getServerURL], @"create"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:gameName, @"gameName", structure, @"gameStructure", nil];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //create success
        NSInteger gameId = [[JSON valueForKey:@"gameId"] intValue];
        if(gameId > 0){
            [GameSettingsManager saveGameId:gameId];
            [self dismissModalViewControllerAnimated:YES];
        }
        else{
            [self createRequestFail];
        }
        
    
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id param){
        NSLog(@"%@",error);
        NSLog(@"%@",param);
        [self createRequestFail];
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
    
    cell.textLabel.text = [[tableData objectAtIndex:indexPath.row] objectForKey:@"text"];
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.structureField.text = [[tableData objectAtIndex:indexPath.row] objectForKey:@"id"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return [tableData count];
    }
    NSLog(@"Entered wrong section");
    return 0;
}

#pragma mark -private helper methods
-(void) createRequestFail{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cound not create the game" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];
}


@end
