//
//  Block.m
//  FancyBlocks
//
//  Created by Hooman Ahmadi on 7/30/12.
//  Copyright (c) 2012 Hooman Ahmadi. All rights reserved.
//

#import "Block.h"

@implementation Block

@synthesize number;

//Initialize the blocks that are used to populate the view. These blocks associate to the
//grid of numbers stored in the Game Model.
- (id)initWithFrame:(CGRect)frame withNumber:(int)num andBlockLength:(int)bl
{
    self = [super initWithFrame:frame];
    if (self) {
        number = num;
        
        //Store the block image and initialize the frame with respect to the size passed in and the
        //coordinates within THIS view class.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"block.jpg"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setFrame:CGRectMake(0,0,bl,bl)];
        
        //We add all blocks to the subview except the empty block (for obvious reasons)
        if (number != 0) {
            [self addSubview:imageView];
        }

        //Initialize and center the label with the number of this block.
        CGRect labelFrame = CGRectMake(0, bl / 2 - 25, bl, 50);
        numberLabel = [[UILabel alloc] initWithFrame: labelFrame];
        numberLabel.text = [NSString stringWithFormat:@"%i", number];
        [numberLabel setTextColor: [UIColor whiteColor]];
        [numberLabel setBackgroundColor:[UIColor clearColor]];
        numberLabel.textAlignment = UITextAlignmentCenter;
        numberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:45];
        
        //We add all labels to the subview except the empty block
        if (number != 0) {
            [self addSubview: numberLabel];
        }
        
        //want to make the padded area clear
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
@end
