//
//  Block.h
//  FancyBlocks
//
//  Created by Hooman Ahmadi on 7/30/12.
//  Copyright (c) 2012 Hooman Ahmadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameModel.h"

@interface Block : UIView
{
    int number;
    UILabel *numberLabel;
    GameModel *gameModel;
}
@property (readonly) int number;
- (id)initWithFrame:(CGRect)frame withNumber:(int)num andBlockLength:(int)bl;
@end
