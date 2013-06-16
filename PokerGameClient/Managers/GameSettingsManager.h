//
//  GameSettingsManager.h
//  PokerGameClient
//
//  Created by Jacob Kanipe-Illig on 6/14/13.
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSettingsManager : NSObject

+(NSString*)getServerURL;
+(void)saveServerUrl:(NSString*)serverURL;
+(NSInteger)getGameId;
+(void)saveGameId:(NSInteger)gameId;

@end
