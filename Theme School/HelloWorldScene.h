//
//  HelloWorldLayer.h
//  LevelScrollDemo
//
//  Created by SuperSu on 11-3-2.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

#define FRAME_RATE 60
#define BOUNCE_TIME 0.2f

/** 
 *  IT'S JUST EXAMPLE SCENE TO TEST SCROLL WITH BOUNCE
 */
typedef enum
{
	BounceDirectionGoingUp = 1,
	BounceDirectionStayingStill = 0,
	BounceDirectionGoingDown = -1,
	BounceDirectionGoingLeft = 2,
	BounceDirectionGoingRight = 3
} BounceDirection;

// HelloWorld Layer
@interface HelloWorldScene : CCScene

// returns a Scene that contains the HelloWorld as the only child
+ (HelloWorldScene *)scene;
- (instancetype)init;

@end
