//
//  GameModel.m
//  FancyBlocks
//
//  Created by Hooman Ahmadi on 7/30/12.
//  Copyright (c) 2012 Hooman Ahmadi. All rights reserved.
//

#import "GameModel.h"
#include <stdlib.h>
#include <time.h>


@implementation GameModel

@synthesize rows, columns, blocks, timeTick;

//Initialize our grid to keep track of where the numbers are.
- (id)initWithRows:(int)r andColumns:(int)c
{
    self = [super init];
    
    if (self) {
        rows = r;
        columns = c;
        
        blocks = [[NSMutableArray alloc] initWithCapacity:rows];
        
        //Seed the random numbers and pull the first one.
        srandom(time(NULL));
        int randomNum = random() % (rows * columns);
        
        //Loop through and create the data structre as a 2-D array.
        //randomly add the numbers in there and use the set to store
        //numbers that you don't want to repeat. We ensure that with the while loop.
        //The empty block is stored as the number zero.
        NSMutableSet *usedNumbers = [[NSMutableSet alloc] init];
        for (int i = 0; i < rows; i++) {
            NSMutableArray *column = [[NSMutableArray alloc] initWithCapacity:columns];
            
            for (int j = 0; j < columns; j++) {
                
                while ([usedNumbers containsObject:[NSNumber numberWithInt:randomNum]]) {
                    randomNum = random() % (rows * columns);
                }
                [usedNumbers addObject:[NSNumber numberWithInt:randomNum]];
                [column insertObject:[NSNumber numberWithInt:randomNum] atIndex:j];
            }
            [blocks insertObject:column atIndex:i];
        }
        
        //Initialize timer.
        timeTick = 0;
    }
    
    return self;
}

//When this function is called, it checks if the number is able to move into the
//empty block and returns which direction the block needs to go if allowed.
- (NSString *)directionToMoveWithNumber:(int)number
{
    //Initialize the grid coordinates to a large number.
    CGPoint currentBlockLocation = CGPointMake(-1000,-1000);
    CGPoint emptyBlockLocation = CGPointMake(-1000,-1000);
    
    //We iterate through the grid to find the empty blocks coordinates and the block that
    //wants to switch with it
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            NSNumber *tileNumber = [[blocks objectAtIndex:i] objectAtIndex:j];
            
            if ([tileNumber integerValue] == number) {
                currentBlockLocation = CGPointMake(j, i);
            }
            if ([tileNumber integerValue] == 0) {
                emptyBlockLocation = CGPointMake(j, i);
            }
        }
    }
    
    //When we find the two blocks we subtract the coordinates.
    //Any blcck surrounding the empty square will only have a one coordinate
    //difference while the other coordinate is the same. Depending
    //on what the coordinate difference is, we determine which direction
    //the numbered block can move. All other coordinates are not allowed.
    int deltaX = currentBlockLocation.x - emptyBlockLocation.x;
    int deltaY = currentBlockLocation.y - emptyBlockLocation.y;

    if (deltaX == 0 && deltaY == -1)
        return @"down";
    else if (deltaX == 1 && deltaY == 0)
        return @"left";
    else if (deltaX == 0 && deltaY == 1)
        return @"up";
    else if (deltaX == -1 && deltaY == 0)
        return @"right";
    else
        return @"none";
}

//Swaps the coordinates in the grid data structure.
- (void)swapEmptyBlockWithBlockNumber:(int)number
{
    //Iterate through and find the empty block and numbered block we want to switch.
    //When they are found we change the value of each.
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            NSNumber *tileNumber = [[blocks objectAtIndex:i] objectAtIndex:j];
            
            if ([tileNumber integerValue] == number) {
                NSMutableArray *column = [blocks objectAtIndex:i];
                [column removeObjectAtIndex:j];
                [column insertObject:[NSNumber numberWithInt:0] atIndex:j];
            }
            if ([tileNumber integerValue] == 0) {
                NSMutableArray *column = [blocks objectAtIndex:i];
                [column removeObjectAtIndex:j];
                [column insertObject:[NSNumber numberWithInt:number] atIndex:j];
            }
        }
    }
}

//Checks to see if the user has reached the end. I do this by iterating through and checking
//that each number is less than its proceeding number. This can only happen if all the blocks are
//in order. I also do an additional check to make sure the empty block is at the end.
- (bool)checkForCompletion
{
    //Store -1 to initialize the previous block. We initialize the completion flag to true.
    NSNumber *tileNumberPrevious = [NSNumber numberWithInt:-1];
    bool completed = true;
    
    //Iterate through the grid and compare each block with the previous block to ensure it is greater.
    //If this check fails, we set the completion flag to true. I ignore the last grid block so that the
    //empty black (set to 0) does not fail the condition.
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            NSNumber *tileNumberNext = [[blocks objectAtIndex:i] objectAtIndex:j];
            
            if ([tileNumberPrevious integerValue] > [tileNumberNext integerValue]) {
                if (!(i == rows - 1 && j == columns - 1)) {
                    completed = false;
                }
            }
            tileNumberPrevious = tileNumberNext;
        }
    }
    
    //If the last block is not the empty zero block, we set completion to false.
    if ([[[blocks objectAtIndex:rows - 1] objectAtIndex:columns - 1] integerValue] != 0) {
        completed = false;
    }
    
    //We return the result to the caller.
    if (completed) {
        return true;
    }
    return false;
}

//Increase the timer of the clock. An NSTimer in the ViewController triggers this function.
- (void)increaseTime
{
    timeTick++;
}
@end
