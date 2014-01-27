//
//  GameModel.h
//  FancyBlocks
//
//  Created by Hooman Ahmadi on 7/30/12.
//  Copyright (c) 2012 Hooman Ahmadi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameModel : NSObject
{
    NSMutableArray *blocks;
    int rows;
    int columns;
    int timeTick;
}

@property (readonly) NSMutableArray *blocks;
@property (readonly) int rows;
@property (readonly) int columns;
@property (readonly) int timeTick;

- (id)initWithRows:(int)r andColumns:(int)c;
- (NSString *) directionToMoveWithNumber:(int)number;
- (void) swapEmptyBlockWithBlockNumber:(int)number;
- (void) increaseTime;
- (bool)checkForCompletion;

@end
