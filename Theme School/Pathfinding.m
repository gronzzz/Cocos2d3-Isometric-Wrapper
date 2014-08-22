//
//  Pathfinding.m
//  Theme School
//
//  Created by Vitaliy Zarubin on 07.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "Pathfinding.h"
#import "TileMap.h"


@implementation Pathfinding

static const BOOL pathfindingDebuggingTiles = NO;

@synthesize openList, closedList;

- (BOOL)isReachableSquare:(CGPoint)tilePos {
    if ([[TileMap shared] isTileInsidePlayableArea:tilePos]) {
		if (![[TileMap shared] isTilePosBlocked:tilePos]) {
			return YES;
		}
	}
	return NO;
}

- (int)manhattanDistance:(CGPoint)fromTile toTile:(CGPoint)toTile {
	return 10 * abs (fromTile.y-toTile.y)+ abs(fromTile.x-toTile.x);
}

- (PathfindingNode *)isOnList:(CGPoint)tilePos list:(NSMutableArray *)list {
	for (PathfindingNode *node in list) {
		if ((node.tilePos.x == tilePos.x) && (node.tilePos.y == tilePos.y)) {
			return node;
		}
	}
	return nil;
}

- (NSArray *)reachableTiles:(PathfindingNode *)fromTile targetTile:(CGPoint)targetTilePos {
	NSMutableArray *reachableTiles = [NSMutableArray array];
	
	NSArray *tilesToCheck = [NSArray arrayWithObjects:
							 [NSValue valueWithCGPoint:CGPointMake(fromTile.tilePos.x-1,fromTile.tilePos.y)],
							 [NSValue valueWithCGPoint:CGPointMake(fromTile.tilePos.x+1,fromTile.tilePos.y)],
							 [NSValue valueWithCGPoint:CGPointMake(fromTile.tilePos.x-1,fromTile.tilePos.y+1)],
							 [NSValue valueWithCGPoint:CGPointMake(fromTile.tilePos.x,fromTile.tilePos.y+1)],
							 [NSValue valueWithCGPoint:CGPointMake(fromTile.tilePos.x+1,fromTile.tilePos.y+1)],
							 [NSValue valueWithCGPoint:CGPointMake(fromTile.tilePos.x-1,fromTile.tilePos.y-1)],
							 [NSValue valueWithCGPoint:CGPointMake(fromTile.tilePos.x,fromTile.tilePos.y-1)],
							 [NSValue valueWithCGPoint:CGPointMake(fromTile.tilePos.x+1,fromTile.tilePos.y-1)],
							 nil];
	for (NSValue *tileToCheck in tilesToCheck) {
		CGPoint adjacentTile = [tileToCheck CGPointValue];
		if ([self isReachableSquare:adjacentTile]) {
			if (![self isOnList:adjacentTile list:closedList]) {
				
				int G;
				if ((fromTile.tilePos.x == adjacentTile.x) || (fromTile.tilePos.y == adjacentTile.y)) {
					G = 10;
				} else {
					G = 14;
				} 
				int H = [self manhattanDistance:fromTile.tilePos toTile:targetTilePos];
				int F = G+H;
				
				PathfindingNode *existingNode = [self isOnList:[tileToCheck CGPointValue] list:openList];
				
				if (existingNode) {
					if (F < existingNode.F) {
						existingNode.F = F;
						existingNode.G = G;
						existingNode.H = H;
						existingNode.parent = fromTile;
						[reachableTiles addObject:existingNode];
					} 
				} else {
					PathfindingNode *node = [[PathfindingNode alloc] init];
					node.tilePos = [tileToCheck CGPointValue];
					node.parent = fromTile;
					node.G = G;
					node.H = H;
					node.F = F;
					[reachableTiles addObject:node];
				}
			}
		}
	}
	return reachableTiles;
}

- (void)searchLowestCostNodeInOpenList:(CGPoint)targetTile {
	PathfindingNode *lowestCostNode = [[PathfindingNode alloc] init];
	lowestCostNode = nil;
	for (PathfindingNode *node in openList) {		
		if (lowestCostNode == nil) {
			lowestCostNode = node;
		} else {
			if (node.F < lowestCostNode.F) {
				lowestCostNode = node;
			}
		}
	}
	
	[openList removeObject:lowestCostNode];
	[closedList addObject:lowestCostNode];
		
	NSArray *reachableTiles = [self reachableTiles:lowestCostNode targetTile:targetTile];
	
	for (PathfindingNode *reachableTile in reachableTiles) {
		[openList addObject:reachableTile];
	}
		
	
	if ((targetTile.x == lowestCostNode.tilePos.x) && (targetTile.x == lowestCostNode.tilePos.y)) {
		NSLog(@"Path found!!");
	} else {
		if ([openList count] != 0) {
			[self searchLowestCostNodeInOpenList:targetTile];
		}
	}
}

- (NSMutableArray *)search:(CGPoint)startTile targetTile:(CGPoint)targetTile {
	openList = [[NSMutableArray alloc] init];
	closedList = [[NSMutableArray alloc] init];

	NSLog(@"In search, within thread");
	// Add the first node to the open list
	PathfindingNode *node = [[PathfindingNode alloc] init];
	node.tilePos = startTile;
	node.parent = nil;
	node.G = 0;
	node.H = 0;
	node.F = node.G + node.H;
	[openList addObject:node];
	
	[self searchLowestCostNodeInOpenList:targetTile];
	 	
	// Retrieve path
	NSMutableArray *pathToPlayer = [NSMutableArray array];
	node = [self isOnList:targetTile list:closedList];
	if (node) {
		NSLog(@"Path found...");
		[pathToPlayer addObject:node];
		
		if (pathfindingDebuggingTiles) {
			// Debugging pathfinding
			[[TileMap shared] debugTile:node.tilePos];
		}
		
		PathfindingNode *parentnode = node.parent;
		while (parentnode) {
			NSLog(@"%f %f",node.tilePos.x, node.tilePos.y);
			node = parentnode;
			parentnode = node.parent;
			[pathToPlayer addObject:node];
			
			if (pathfindingDebuggingTiles) {
				//Debugging pathfinding
				[[TileMap shared] debugTile:node.tilePos];
			}
		}
	} else {
		NSLog(@"No path found");
	}
	
	return pathToPlayer;
}


@end
