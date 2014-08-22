//
//  PathfindingNode.h
//  Theme School
//
//  Created by Vitaliy Zarubin on 07.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "cocos2d.h"

@interface PathfindingNode : NSObject {
	CGPoint tilePos;
	PathfindingNode *parent;
	int F;
	int G;
	int H;
}

@property (nonatomic) CGPoint tilePos;
@property (nonatomic, retain) PathfindingNode *parent;

/** Score of square: F = G + h */
@property (nonatomic) int F;

/** The movement cost of moving from the starting point to finish */
@property (nonatomic) int G;

/** The estimated movement cost to move from that given square
 *  on the grid to the final destination */
@property (nonatomic) int H;

@end
