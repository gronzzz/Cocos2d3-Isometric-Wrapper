//
//  Pathfinding.h
//  Theme School
//
//  Created by Vitaliy Zarubin on 07.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//


#import "cocos2d.h"
#import "PathfindingNode.h"

@interface Pathfinding : CCNode

@property (nonatomic, retain) NSMutableArray *openList;
@property (nonatomic, retain) NSMutableArray *closedList;

- (NSMutableArray *)search:(CGPoint)startTile targetTile:(CGPoint)targetTile;

@end