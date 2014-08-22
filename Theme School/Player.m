//
//  Player.m
//  Theme School
//
//  Created by Vitaliy Zarubin on 07.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "Player.h"

@implementation Player

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
    // TEST
    self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"Player.png"];
    // TEST
    
    self.zOrderOffset = 0;
    self.velocitySpeedUp = 270/1;
    self.velocityOrdinary = 180/1;
    self.velocity = _velocityOrdinary;
    self.alive = YES;
    self.isMoving = NO;
    self.speedUpActive = NO;
    self.tripleShotsActive = NO;
    self.spritesheetBaseFilename = @"walking";
    [self cacheFrames];
}

- (void)spriteMoveFinished {
    [super spriteMoveFinished];
}
    

@end
