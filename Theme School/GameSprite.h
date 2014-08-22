//
//  GameSprite.h
//  Theme School
//
//  Created by Vitaliy Zarubin on 07.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "TileMap.h"

@interface GameSprite : CCSprite

@property (nonatomic) BOOL isMoving;
@property (nonatomic) BOOL alive;
@property (nonatomic) int deathTurns;
@property (nonatomic, retain) CCAnimation *animation;
@property (nonatomic, retain) CCActionSequence *spriteRunAction;
@property (nonatomic) int zOrderOffset;
@property (nonatomic) float velocity;
//@property (nonatomic, retain) CCSpriteSheet *spriteSheet;
@property (nonatomic, retain) NSString *spritesheetBaseFilename;

/// -----------------------------------------------------------------------
/// @name Initiating object
/// -----------------------------------------------------------------------
 
- (id)initWithWorldPosition:(CGPoint)worldPosition;
- (id)initWithTilePosition:(CGPoint)tile;

- (void)spriteMoveFinished;

- (CGPoint)getLocation;
- (void)changeSpriteAnimation:(NSString *)direction;
- (void)moveSpritePosition:(CGPoint)targetPosition sender:(id)sender;
- (void)updateVertexZ:(CGPoint)tilePos;
- (BOOL)checkIfPointIsInSight:(CGPoint)playerPos enemySprite:(GameSprite *)enemy;
- (void)deathSequence;
- (void)cacheFrames;

@end
