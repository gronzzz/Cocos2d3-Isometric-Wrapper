//
//  HelloWorldLayer.m
//  LevelScrollDemo
//
//  Created by SuperSu on 11-3-2.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// Import the interfaces
#import "HelloWorldScene.h"

@interface HelloWorldScene()
{
	BounceDirection direction;
	CCNode *scrollLayer;
	BOOL isDragging;
	float lasty;
	float xvel;
	float contentHeight;
}
@end

@implementation HelloWorldScene

+ (HelloWorldScene *)scene {
	return [[self alloc] init];
}

- (instancetype)init {
	if((self = [super init])) {
		
		self.userInteractionEnabled = YES;
		isDragging = NO;
		lasty = 0.0f;
		xvel = 0.0f;
		contentHeight = 10000.0f;
		direction = BounceDirectionStayingStill;
		
		scrollLayer = [[CCNode alloc] init];
        scrollLayer.color = [CCColor colorWithRed:221/255.f green:255/255.f blue:250];
		scrollLayer.contentSize = CGSizeMake(contentHeight, 320.f);
		scrollLayer.anchorPoint = ccp(0, 0);
		scrollLayer.position = ccp(0, 0);
		[self addChild: scrollLayer];
		
		// TEST items!
		for(int i = 0; i < contentHeight; i += 100) {
			
			CCLabelTTF *label = [CCLabelTTF labelWithString:[[NSString alloc] initWithFormat:@"Item%d", (i/100) + 1]
												   fontName:@"Arial"
												   fontSize:24];
			label.position = ccp(i + label.contentSize.width/2, 100 + (label.contentSize.height/2));
			
			[scrollLayer addChild:label];
		}
	}
	return self;
}


- (void)update:(CCTime)delta {
	CGPoint pos = scrollLayer.position;
	// positions for scrollLayer
	
	float right = pos.x + [self boundingBox].origin.x + scrollLayer.contentSize.width;
	float left = pos.x + [self boundingBox].origin.x;
	// Bounding area of scrollview
	float minX = [self boundingBox].origin.x;
	float maxX = [self boundingBox].origin.x + [self boundingBox].size.width;	
	
	if(!isDragging) {
		static float friction = 0.96f;
		
		if(left > minX && direction != BounceDirectionGoingLeft) {
			
			xvel = 0;
			direction = BounceDirectionGoingLeft;
			
		}
		else if(right < maxX && direction != BounceDirectionGoingRight)	{
			
			xvel = 0;
			direction = BounceDirectionGoingRight;
		}
		
		if(direction == BounceDirectionGoingRight)
		{
			
			if(xvel >= 0)
			{
				float delta = (maxX - right);
				float yDeltaPerFrame = (delta / (BOUNCE_TIME * FRAME_RATE));
				xvel = yDeltaPerFrame;
			}
			
			if((right + 0.5f) == maxX)
			{
				
				pos.x = right -  scrollLayer.contentSize.width;
				xvel = 0;
				direction = BounceDirectionStayingStill;
			}
		}
		else if(direction == BounceDirectionGoingLeft)
		{
			
			if(xvel <= 0)
			{
				float delta = (minX - left);
				float yDeltaPerFrame = (delta / (BOUNCE_TIME * FRAME_RATE));
				xvel = yDeltaPerFrame;
			}
			
			if((left + 0.5f) == minX) {
				
				pos.x = left - [self boundingBox].origin.x;
				xvel = 0;
				direction = BounceDirectionStayingStill;
			}
		}
		else
		{
			xvel *= friction;
		}
		
		pos.x += xvel;
		scrollLayer.position = pos;
	}
	else
	{
		if(left <= minX || right >= maxX) {
			direction = BounceDirectionStayingStill;
		}
		
		if(direction == BounceDirectionStayingStill) {
			xvel = (pos.x - lasty)/2;
			lasty = pos.x;
		}
	}
    NSLog(@"%f",xvel);
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    isDragging = YES;
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint preLocation = [touch previousLocationInView:[touch view]];
	CGPoint curLocation = [touch locationInView:[touch view]];
	
	CGPoint a = [[CCDirector sharedDirector] convertToGL:preLocation];
	CGPoint b = [[CCDirector sharedDirector] convertToGL:curLocation];
	
	CGPoint nowPosition = scrollLayer.position;
	nowPosition.x += ( b.x - a.x );
	scrollLayer.position = nowPosition;
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    isDragging = NO;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{

}
@end
