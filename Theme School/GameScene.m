//
//  GameScene.m
//  Theme School
//
//  Created by Vitaliy Zarubin on 06.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "GameScene.h"
#import "MapLayer.h"

#import "TileMap.h"

#import "Player.h"
#import "NPC.h"
#import "CleverNPC.h"


@interface GameScene()

@property (nonatomic, strong) Player *hero;
@property (nonatomic, strong) NPC *npc;
@property (nonatomic, strong) MapLayer *gameLayer;

@end

@implementation GameScene

+ (GameScene *)scene {
	return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        
        /* TEST */
        [CCDirector sharedDirector].displayStats = YES;
        /* TEST */
        
        [self buildWorld];
        [_gameLayer setViewPointCenterInsideMap:_hero.position];
    }
    return self;
}

- (void)buildWorld {
    [self setLayers];
    
    /** Simple hero creation */
//    _hero = [[Player alloc] initWithWorldPosition:[TileMap shared].spawnPoint];
    _hero = [[Player alloc] initWithWorldPosition:[[TileMap shared] worldFromTile:ccp(22, 25)]];
    [_gameLayer addChild:_hero z:3];
    
    /** Clever npc that will move throw pathfinding system, need to create one more method */
    CleverNPC *cnpc = [[CleverNPC alloc] initWithWorldPosition:[[TileMap shared] worldFromTile:ccp(30, 35)]];
    [_gameLayer addChild:cnpc];
    [cnpc createPathToGameObject:_hero];
    
    /** Lazy npc, that moving in random direction not tile-to-tile */
//    NPC *npc = [[NPC alloc] initWithTilePosition:ccp(20, 25)];
//    [_gameLayer addChild:npc];
//    [npc moveInRandomDirection];
}


- (void)setLayers {
    _gameLayer = [[MapLayer alloc] init];
    [self addChild:_gameLayer];
}

#pragma mark - Touches
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [_gameLayer touchBegan:touch withEvent:event];

    /* TEST SIMPLE MOVING TOUCH */
    CGPoint point = [touch locationInNode:_gameLayer];
    [_hero moveSpritePosition:point sender:_hero];
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [_gameLayer touchMoved:touch withEvent:event];
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [_gameLayer touchEnded:touch withEvent:event];
}

#pragma mark - Update
- (void)update:(CCTime)delta {
    
}

@end