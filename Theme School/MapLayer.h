//
//  MapLayer.h
//  Theme School
//
//  Created by Vitaliy Zarubin on 14.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "cocos2d.h"

typedef enum
{
	BounceDirectionGoingUp = 1,
	BounceDirectionStayingStill = 0,
	BounceDirectionGoingDown = -1,
	BounceDirectionGoingLeft = 2,
	BounceDirectionGoingRight = 3
} BounceDirection;


@interface MapLayer : CCNode

/**
 *  Setting center of screen inside position in screen coordinates
 *  @param position - Position from user
 */
- (void)setViewPointCenterInsideMap:(CGPoint) position;

@end
