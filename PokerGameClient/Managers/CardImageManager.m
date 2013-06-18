//
//  CardImageManager.m
//  PokerGameClient
//
//  Copyright (c) 2013 jacobhyphenated. All rights reserved.
//

#import "CardImageManager.h"

@implementation CardImageManager

+(NSString *)imageIdentifierFromKey:(NSString *)imageKey{
    NSString * suitString = [imageKey substringFromIndex:1];
    NSString * valueString = [imageKey substringToIndex:1];
    
    NSString *imageSuit;
    if([suitString isEqualToString:@"h"]){
        imageSuit = @"hearts";
    }
    else if([suitString isEqualToString:@"c"]){
        imageSuit = @"clubs";
    }
    else if([suitString isEqualToString:@"d"]){
        imageSuit = @"diamonds";
    }
    else if([suitString isEqualToString:@"s"]){
        imageSuit = @"spades";
    }
    
    NSString *imageValue;
    if([valueString isEqualToString:@"2"]){
        imageValue = @"two";
    }
    else if([valueString isEqualToString:@"3"]){
        imageValue = @"three";
    }
    else if([valueString isEqualToString:@"4"]){
        imageValue = @"four";
    }
    else if([valueString isEqualToString:@"5"]){
        imageValue = @"five";
    }
    else if([valueString isEqualToString:@"6"]){
        imageValue = @"six";
    }
    else if([valueString isEqualToString:@"7"]){
        imageValue = @"seven";
    }
    else if([valueString isEqualToString:@"8"]){
        imageValue = @"eight";
    }
    else if([valueString isEqualToString:@"9"]){
        imageValue = @"nine";
    }
    else if([valueString isEqualToString:@"T"]){
        imageValue = @"ten";
    }
    else if([valueString isEqualToString:@"J"]){
        imageValue = @"jack";
    }
    else if([valueString isEqualToString:@"Q"]){
        imageValue = @"queen";
    }
    else if([valueString isEqualToString:@"K"]){
        imageValue = @"king";
    }
    else if([valueString isEqualToString:@"A"]){
        imageValue = @"ace";
    }
    
    return [NSString stringWithFormat:@"%@_%@.png",imageValue, imageSuit];
}

@end
