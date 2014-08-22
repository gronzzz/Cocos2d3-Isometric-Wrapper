//
//  NPC.m
//  Theme School
//
//  Created by Vitaliy Zarubin on 20.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "NPC.h"

@implementation NPC


- (instancetype)initWithWorldPosition:(CGPoint)worldPosition {
    self = [super initWithWorldPosition:worldPosition];
    if (self) {
        [self params];
    }
    
    return self;
}


- (instancetype)initWithTilePosition:(CGPoint)tilePosition {
    self = [super initWithTilePosition:tilePosition];
    if (self) {
        [self params];
    }
    
    return self;
}

- (void)params {
    /* TEST */
    self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"Player.png"];
    /* TEST */
    
    self.alive = YES;
    self.zOrderOffset = 0;
    self.velocity = 40/1;
    self.spritesheetBaseFilename = @"knight";
    [self cacheFrames];
}


- (void)spriteMoveFinished {
	[self stopAllActions];
	NSLog(@"NPC reached target");
	[self moveInRandomDirection];
}

- (void)moveInRandomDirection {
	CGPoint attackerTilePos = [[TileMap shared] tileFromWorld:self.position];
	int randomDirection = arc4random() % 8;
	int randomDistance = arc4random() % 14;
	CGPoint targetTilePos = attackerTilePos;
	NSLog(@"Random direction = %d", randomDirection);
	switch (randomDirection) {
		case 0:
			targetTilePos.x -= randomDistance;
			break;
		case 1:
			targetTilePos.y -= randomDistance;
			break;
		case 2:
			targetTilePos.x += randomDistance;
			break;
		case 3:
			targetTilePos.y += randomDistance;
			break;
		case 4:
			targetTilePos.x -= randomDistance;
			targetTilePos.y += randomDistance;
			break;
		case 5:
			targetTilePos.x -= randomDistance;
			targetTilePos.y -= randomDistance;
			break;
		case 6:
			targetTilePos.x += randomDistance;
			targetTilePos.y -= randomDistance;
			break;
		case 7:
			targetTilePos.x += randomDistance;
			targetTilePos.y += randomDistance;
			break;
	}
	NSLog(@"Trying to move knight to %f %f, which is %d squares away", targetTilePos.x, targetTilePos.y, randomDistance);
    
    if (![[TileMap shared] isTileInsidePlayableArea:targetTilePos]) {
		NSLog(@"Off the map, trying again...");
		[self moveInRandomDirection];
	} else {
        CGPoint targetLocation = [[TileMap shared] worldFromTile:targetTilePos];
		if ([self checkIfPointIsInSight:targetLocation enemySprite:self]) {
			NSLog(@"Ok, nothing is in the way");
			[self moveSpritePosition:targetLocation sender:self];
		} else {
			NSLog(@"There is an obstacle in the way. Recalculating...");
			[self moveInRandomDirection];
		}
	}
}

@end
