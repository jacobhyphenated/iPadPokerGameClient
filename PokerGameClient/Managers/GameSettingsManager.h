//
//  GameSettingsManager.h
//  PokerGameClient
//
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSettingsManager : NSObject

+(NSString*)getServerURL;
+(void)saveServerUrl:(NSString*)serverURL;
+(NSInteger)getGameId;
+(void)saveGameId:(NSInteger)gameId;
+(NSInteger)getHandId;
+(void)saveHandId:(NSInteger)handId;

@end
