//
//  CleverNPC.m
//  Theme School
//
//  Created by Vitaliy Zarubin on 22.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "CleverNPC.h"

#import "TileMap.h"
#import "Pathfinding.h"

#import "Player.h"

@interface CleverNPC()
@property (nonatomic) BOOL chasingPlayer;
@property (nonatomic) BOOL followingPath;
@property (nonatomic, retain) NSMutableArray *path;
@property (nonatomic, retain) NSThread *thread;
@property (nonatomic, retain) GameSprite *target;

- (void)getPath:(NSArray *)tilePositions;
@end

@implementation CleverNPC

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
    self.velocity = 60/1;
    self.chasingPlayer = NO;
    self.followingPath = NO;  // TEST: CHANGE PARAM
    self.thread = nil;
    self.spritesheetBaseFilename = @"ghost";
    self.path = [[NSMutableArray alloc] init];
    [self cacheFrames];
}

-(void)spriteMoveFinished {
	if (self.followingPath) {
		if ([_path count]>1) {
			NSLog(@"Continuing along path, %lu tiles left on path", (unsigned long)[_path count]);
			[self followPath];
		} else {
			NSLog(@"Reached end of path");
			[self stopAllActions];
            
			// create another path
			[self createPathToTarget];
		}
	} else {
		[self stopAllActions];
		self.isMoving = NO;
		self.chasingPlayer = NO;
	}
}

- (void)followPath {
	int numberOfSquares = (int)[_path count];
	if (numberOfSquares) {
		// snake along the squares
		int pathIndex = (int)[_path count]-2; // ignore the last position, it's the attacker's current square
		PathfindingNode *node = [_path objectAtIndex:pathIndex];
		[_path removeLastObject];
        
		NSLog(@"Moving sprite to tile pos %f %f", node.tilePos.x, node.tilePos.y);
        
		CGPoint nextPos = [[TileMap shared] worldFromTile:node.tilePos];
//		nextPos = [UIAppDelegate.coordinateFunctions pointRelativeToCentreFromLocation:nextPos];
		NSLog(@"Moving sprite to %f %f", nextPos.x, nextPos.y);
		[self moveSpritePosition:nextPos sender:self];
	}
}

- (void)setPathToAttacker:(NSMutableArray *)attackerPath {
	self.path = attackerPath;
	[self followPath];
	self.thread = nil;
}


- (void)getPath:(NSArray *)tilePositions {
	NSLog(@"in thread - getPath");
	
	CGPoint playerTilePos = [[tilePositions objectAtIndex:0] CGPointValue];
	CGPoint attackerTilePos = [[tilePositions objectAtIndex:1] CGPointValue];
	Pathfinding *pathfinding = [[Pathfinding alloc] init];
	NSLog(@"about to get path");
	NSMutableArray *returnedPath = [pathfinding search:attackerTilePos targetTile:playerTilePos];
	NSLog(@"got path back, with %lu nodes",(unsigned long)[returnedPath count]);
	
	[self performSelectorOnMainThread:@selector(setPathToAttacker:) withObject:returnedPath waitUntilDone:NO];
	NSLog(@"End of thread - pool drained");
}


- (void)createPathToGameObject:(GameSprite *)object {
    self.target = object;
    [self createPathToTarget];
}

- (void)createPathToTarget {
    
	if ((self.alive) && (self.followingPath)) {
        
		CGPoint attackerTilePos = [[TileMap shared] tileFromWorld:self.position];
		CGPoint playerTilePos = [[TileMap shared] tileFromWorld:_target.position];
		NSLog(@"Creating path to object");
		NSLog(@"Attacker at %f %f", attackerTilePos.x, attackerTilePos.y);
		NSLog(@"Player at %f %f", playerTilePos.x, playerTilePos.y);
        
        
		NSArray *tilePositions = [NSArray arrayWithObjects:
                                  [NSValue valueWithCGPoint:playerTilePos],
                                  [NSValue valueWithCGPoint:attackerTilePos],
                                  nil];
        
		self.thread = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(getPath:)
                                                object:tilePositions];
		[self.thread setThreadPriority:0.0];
		[self.thread start];
		
		//[self performSelectorInBackground:@selector(getPath:) withObject:tilePositions];
		
		NSLog(@"Following new path");
	} else {
		NSLog(@"Not creating path to player, because the attacker is dead or not following the player");
	}
}


- (void)chasePlayer:(GameSprite *)player {
//	if ((!self.chasingPlayer) && (!self.followingPath) && (UIAppDelegate.soundOn)) {
//		[[SimpleAudioEngine sharedEngine]playEffect:@"ghostbirth.wav"];
//	}
	if (self.alive) {
		NSLog(@"Chasing player");
		NSLog(@"Player at %f %f",player.position.x, player.position.y);
		NSLog(@"Attacker at %f %f",self.position.x, self.position.y);
		[self moveSpritePosition:player.position sender:self];
		self.chasingPlayer = YES;
	}
}

- (void)updateAStarPath:(CCTime)delta {
	[self stopAllActions];
	[self createPathToTarget];
}
@end
