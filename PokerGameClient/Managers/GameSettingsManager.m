//
//  GameSettingsManager.m
//  PokerGameClient
//
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import "GameSettingsManager.h"

@implementation GameSettingsManager

+(NSString*)getServerURL {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"ServerURL"];
}

+(void)saveServerUrl:(NSString*)serverURL{
    [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:@"ServerURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)getGameId {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"GameID"];
}

+(void)saveGameId:(NSInteger)gameId{
    [[NSUserDefaults standardUserDefaults] setInteger:gameId forKey:@"GameID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)getHandId{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"HandID"];
}

+(void)saveHandId:(NSInteger)handId{
    [[NSUserDefaults standardUserDefaults] setInteger:handId forKey:@"HandID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


