//
//  FancyBlocksViewController.h
//  FancyBlocks
//
//  Created by Hooman Ahmadi on 7/30/12.
//  Copyright (c) 2012 Hooman Ahmadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameModel.h"
#import "Block.h"
@interface FancyBlocksViewController : UIViewController
{
    GameModel *gameModel;
    int blockMoved;
    IBOutlet UIButton *newGame;
    IBOutlet UILabel *timeLabel;
    NSTimer *gameTimer;
}

- (IBAction)newThreeByThreeGame:(id)sender;
- (IBAction)newFourByFourGame:(id)sender;
@end
