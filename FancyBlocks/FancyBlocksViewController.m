//
//  FancyBlocksViewController.m
//  FancyBlocks
//
//  Created by Hooman Ahmadi on 7/30/12.
//  Copyright (c) 2012 Hooman Ahmadi. All rights reserved.
//

#import "FancyBlocksViewController.h"

//Define how many blocks the game will contain.
//Ideally you can play a 2x2, 3x3, or 4x4 grid without changing
//the block size and positioning defined in ViewController.
#define NUM_ROWS 3
#define NUM_COLS 3

//Define the size of the blocks and how far down the grid is placed.
#define BLOCK_LENGTH 80
#define HEADER_SPACE 110

@interface FancyBlocksViewController ()

@end

@implementation FancyBlocksViewController


//When the alert messages are shown to the user, we halt the gameTimer. Once they click through the alert, we start the timer.
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
}

//Initialize the view by adding a game model, drawing the blocks, and showing the instructions.
- (void)viewDidLoad
{
    [super viewDidLoad];

    gameModel = [[GameModel alloc] initWithRows:NUM_ROWS andColumns:NUM_COLS];
    [self drawBlocks];
    [self showInstructions];
}

//The instructions are shown with a UIAlertView.
- (void)showInstructions {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Instructions" message:@"Shift the tiles to order the numbers from lowest to highest. The empty block should be at the end." delegate:self cancelButtonTitle:@"Start" otherButtonTitles:nil];
    [message show];
}

//When the New Game button is pushed, we want to reset the game and show the instructions again.
- (IBAction)newThreeByThreeGame:(id)sender
{
    [self resetGameWithRows:3 andColumns:3];
    [self showInstructions];
}

//When the New Game button is pushed, we want to reset the game and show the instructions again.
- (IBAction)newFourByFourGame:(id)sender
{
    [self resetGameWithRows:4 andColumns:4];
    [self showInstructions];
}

//We reset the game by invalidating the NSTimer, reseting the clock label,
//recreating a new game model, and redrawing the new blocks into the view.
- (void)resetGameWithRows:(int)rows andColumns:(int)cols
{
    [gameTimer invalidate];
    timeLabel.text = @"0";
    gameModel = [[GameModel alloc] initWithRows:rows andColumns:cols];
    [self redrawBlocks];
}

//First we iterate through and remove all of the block subviews. Then we draw the blocks from scratch again.
- (void)redrawBlocks
{
    for (UIView *subview in [self.view subviews]) {
        if ([subview isMemberOfClass:[Block class]]) {
            [subview removeFromSuperview];
        }
    }
    [self drawBlocks];
}

//We draw the blocks by iterating through the gameModel grid and creating a new block based on the grid positioning and number.
- (void)drawBlocks
{
    //Create a left margin to center all the blocks with respect to the width of the screen.
    int leftMargin = (self.view.frame.size.width - (BLOCK_LENGTH * gameModel.rows)) / 2;
    
    //Iterate through, create the position frame, then create the Block object by passing the number, frame, and size.
    //Afterwards we add the newly created block to the ViewController.
    for (int i = 0; i < gameModel.rows; i++) {
        for (int j = 0; j < gameModel.columns; j++) {
            NSNumber *tileNumber = [[gameModel.blocks objectAtIndex:i] objectAtIndex:j];
            
            CGRect foo = CGRectMake(leftMargin + BLOCK_LENGTH * j, BLOCK_LENGTH * i + HEADER_SPACE, BLOCK_LENGTH, BLOCK_LENGTH);
            Block *newBlock = [[Block alloc] initWithFrame:foo withNumber:[tileNumber integerValue] andBlockLength:BLOCK_LENGTH];
            
            [[self view] addSubview:newBlock];
        }
    }
    //Initialize how far the user has moved the block into the new position (before being swapped).
    blockMoved = 0;
}

//The NSTimer is started after the alert menu and uses the gameModel method to increase the time by 1 second
//and update the UILabel in xib file.
- (void)timerFired:(NSTimer *)theTimer
{
    [gameModel increaseTime];
    timeLabel.text = [NSString stringWithFormat:@"%i", gameModel.timeTick];
}

//Free the variables.
- (void)viewDidUnload
{
    [super viewDidUnload];
    newGame = nil;
    timeLabel = nil;
    gameModel = nil;
    gameTimer = nil;
}

//We monitor which block the user is moving and check to make sure if it's allowed and what direction.
//We then move it into the empty space and allow it to snap into place (making it easier to flick them around).
//If the user is moving a specific block, we disable all other blocks so that he/she can't move multiple blocks
//at the same time. Once the block has been pulled all the way, we update the game model, and redraw all the blocks.
//If the end game conditions are met, we rest the game and display a victory message.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Default end game variable to false.
    bool result = false;
    
    //If a block object has been touched, we find which one it is.
    UITouch* t = [touches anyObject];
    if ([t.view class] == [Block class]) {
        Block *b = (Block *)t.view;
        
        //We check the game model to see if it's allowed to be moved and what direction it can move in.
        //If it's allowed to be moved, we find all the other subview blocks and disable them.
        NSString *directionToMove = [gameModel directionToMoveWithNumber:b.number];
        
        /*if (![directionToMove isEqualToString:@"none"]) {
            for (UIView *subview in [self.view subviews]) {
                if ([subview isMemberOfClass:[Block class]] && subview != b) {
                    [subview setUserInteractionEnabled:NO];
                }
            }
        }*/
        
        //Iterate through the touch positions.
        for (UITouch *t in touches) {
            
            //Store the original frame position of the block.
            CGRect newBlockRect = b.frame;
            
            //Find the difference between the previous and new location of the gesture for both the X and Y coordinates.
            CGFloat deltaX =[t locationInView:b].x - [t previousLocationInView:b].x;
            CGFloat deltaY =[t locationInView:b].y - [t previousLocationInView:b].y;
            
            
            //If the block is allowed to move in that direction and the block has been moved closer to the full length of the empty block,
            //We update the position of the block along that plane and update the amount it has been moved for the next gesture check.
            if ([directionToMove isEqualToString:@"left"] && blockMoved >= -BLOCK_LENGTH && deltaX <= 0) {
                newBlockRect.origin.x += deltaX;
                blockMoved += deltaX;
            } else if ([directionToMove isEqualToString:@"right"] && blockMoved <= BLOCK_LENGTH && deltaX >= 0) {
                newBlockRect.origin.x += deltaX;
                blockMoved += deltaX;
            } else if ([directionToMove isEqualToString:@"up"] && blockMoved >= -BLOCK_LENGTH && deltaY <= 0) {
                newBlockRect.origin.y += deltaY;
                blockMoved += deltaY;
            } else if ([directionToMove isEqualToString:@"down"] && blockMoved <= BLOCK_LENGTH && deltaY >= 0) {
                newBlockRect.origin.y += deltaY;
                blockMoved += deltaY;
            }
            
            //To give it a snappy feel, we automatically redraw if the block has moved more than 2/3rds into the empty block.
            //Afterwards, we update the game model by swapping the the block values in the 2-D grid structure.
            //Once we have changed the structure, we redraw all the tiles from scratch.
            //We also check the game model to see if all the tiles are ordered properly to end the game.
            if (abs(blockMoved) >= (BLOCK_LENGTH - (BLOCK_LENGTH / 3))) {
                [gameModel swapEmptyBlockWithBlockNumber:b.number];
                result = [gameModel checkForCompletion];
                [self redrawBlocks];
            }
            
            //Once the new block coordinate frame is decided above, we update the actual frame to visually move the block to that position.
            b.frame = newBlockRect;
        }
    }
    
    //If the end game results were returned, we display a victory message with the completion time and reset the game.
    if (result) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You completed Fancy Blocks in %i second(s)!", [gameModel timeTick]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        [self resetGameWithRows:gameModel.rows andColumns:gameModel.columns];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (abs(blockMoved) < (BLOCK_LENGTH - (BLOCK_LENGTH / 3))) {
        [self redrawBlocks];
    }
}

@end
