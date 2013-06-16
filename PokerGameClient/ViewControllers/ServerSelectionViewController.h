//
//  ServerSelectionViewController.h
//  PokerGameClient
//
//  Created by Jacob Kanipe-Illig on 6/14/13.
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerSelectionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *serverURLTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIImageView *correctServerIcon;

- (IBAction)serverTextFieldChanged:(id)sender;
- (IBAction)saveButtonTap:(id)sender;


@end
