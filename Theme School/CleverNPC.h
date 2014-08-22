//
//  CleverNPC.h
//  Theme School
//
//  Created by Vitaliy Zarubin on 22.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "GameSprite.h"

@interface CleverNPC : GameSprite

- (void)chasePlayer:(GameSprite *)player;
- (void)createPathToGameObject:(GameSprite *)object;

@end
