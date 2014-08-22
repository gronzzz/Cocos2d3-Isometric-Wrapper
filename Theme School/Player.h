//
//  Player.h
//  Theme School
//
//  Created by Vitaliy Zarubin on 07.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "GameSprite.h"

@interface Player : GameSprite

@property (nonatomic) CGPoint lastPosition;
@property (nonatomic) BOOL speedUpActive, tripleShotsActive;
@property (nonatomic) float velocitySpeedUp, velocityOrdinary;


@end