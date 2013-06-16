//
//  GameSettingsManager.m
//  PokerGameClient
//
//  Created by Jacob Kanipe-Illig on 6/14/13.
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import "GameSettingsManager.h"

@implementation GameSettingsManager

+(NSString*)getServerURL {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"ServerURL"];
}

+(void)saveServerUrl:(NSString*)serverURL{
    [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:@"ServerURL"];
}

+(NSInteger)getGameId {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"GameID"];
}

+(void)saveGameId:(NSInteger)gameId{
    [[NSUserDefaults standardUserDefaults] setInteger:gameId forKey:@"GameID"];
}

@end


