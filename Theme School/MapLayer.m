//
//  MapLayer.m
//  Theme School
//
//  Created by Vitaliy Zarubin on 14.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "MapLayer.h"

#import "TileMap.h"
#import "Define.h"


@interface MapLayer(){
    BOOL _isDragging;
    BOOL _isScaleBounce;
    BOOL _isTouchBegin;
    
    // Scale with bounce
    CGPoint _lastPos;
    CGPoint _velocity;
    CGPoint _touchLoc;
    CGRect _scrollArea;
    
    // Moving with bounce
    BounceDirection _xDirection;
    BounceDirection _yDirection;
    float minX;
    float minY;
    float maxX;
    float maxY;
}

@end


@implementation MapLayer

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.scale = CURRENT_SCALE;
        
        // tilemap
        [[TileMap shared] loadMapWithFile:@"TileMap.tmx"];
        [self addChild:[TileMap shared].map z:-1];
        
        [self setParams];
        [self setScrollArea];
    }
    
    return self;
}

- (void)setParams {
    _isDragging = NO;
    _isScaleBounce = NO;
    _isTouchBegin = NO;
    
    _xDirection = BounceDirectionStayingStill;
    _yDirection = BounceDirectionStayingStill;
    
    CGPoint min = ccp([TileMap shared].map.mapSize.width/2, [TileMap shared].map.mapSize.height);
    CGPoint max = ccp([TileMap shared].map.mapSize.width/2, 0);
    [[TileMap shared] setupPlayableAreaWithMinPoint:min maxPoint:max];
}

/*
 *  We set area in which scale will be,
 *  area = side/2, so it'll rectangle, like our screen.
 *  Dots are moved on 2 tiles from all sides to set a little place
 *  for bounce.
 *
 *  Задаём область в которой будет происходить скейл,
 *  область равна серединным точкам ромба, образующим прямоугольник.
 *  Точки сдвинуты таким образом, чтобы оставалось с каждой стороны немного
 *  свободного места. Этот прямоугольник даёт свободное перемещение, а
 *  границы его означают начало области баунса.
 */
- (void)setScrollArea {
    
    int scrollZone = BOUNCE_AREA * self.scale;

    CGPoint leftBottom = [TileMap shared].playableArea.lb;
    CGPoint rightTop = [TileMap shared].playableArea.rt;
    
    /** Scroll area need to be little less, for bouncing to edges */
    _scrollArea = CGRectMake(-leftBottom.x * self.scale - scrollZone,
                             -leftBottom.y * self.scale - scrollZone,
                             -(rightTop.x - leftBottom.x) * self.scale + scrollZone,
                             -(rightTop.y - leftBottom.y) * self.scale + scrollZone);
    
    minX = _scrollArea.origin.x * self.scale;
    maxX = _scrollArea.origin.x + _scrollArea.size.width + (SCREEN_WIDTH * self.scale);
    
   
//    minY = _scrollArea.origin.y;
    /** TEST **/
    minY = -320 * self.scale;
    /** TEST **/
    maxY = _scrollArea.origin.y + _scrollArea.size.height + (SCREEN_HEIGHT * self.scale);
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    _isTouchBegin = YES;
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    NSArray *allTouches = [[event allTouches] allObjects];
    UITouch *touchOne = [allTouches objectAtIndex:0];
    CGPoint touchLocationOne = [touchOne locationInView: [touchOne view]];
    CGPoint previousLocationOne = [touchOne previousLocationInView: [touchOne view]];
    
    // Scaling
    if ([allTouches count] == 2) {
        
        _isDragging = NO;
        
        UITouch *touchTwo = [allTouches objectAtIndex:1];
        CGPoint touchLocationTwo = [touchTwo locationInView: [touchTwo view]];
        CGPoint previousLocationTwo = [touchTwo previousLocationInView: [touchTwo view]];
        
        CGFloat currentDistance = sqrt(
                                       pow(touchLocationOne.x - touchLocationTwo.x, 2.0f) +
                                       pow(touchLocationOne.y - touchLocationTwo.y, 2.0f));
        
        CGFloat previousDistance = sqrt(
                                        pow(previousLocationOne.x - previousLocationTwo.x, 2.0f) +
                                        pow(previousLocationOne.y - previousLocationTwo.y, 2.0f));
        
        CGFloat distanceDelta = currentDistance - previousDistance;
        CGPoint pinchCenter = ccpMidpoint(touchLocationOne, touchLocationTwo);
        pinchCenter = [self convertToNodeSpace:pinchCenter];
        CGFloat predictionScale = self.scale + (distanceDelta * PINCH_ZOOM_MULTIPLIER);
        
        if([self predictionScaleInBounds:predictionScale]) {
            [self scale:predictionScale scaleCenter:pinchCenter];
            [self setScrollArea];
        }
    } else {
        // Dragging
        _isDragging = YES;
        CGPoint previous = [[CCDirector sharedDirector] convertToGL:previousLocationOne];
        CGPoint current = [[CCDirector sharedDirector] convertToGL:touchLocationOne];
        CGPoint delta = ccpSub(current, previous);

        /** Endless screen while moving */
        [self dragLimitWithDelta:delta];
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    _isDragging = NO;
    _isTouchBegin = NO;
    // Check if i need to bounce
    _touchLoc = [touch locationInNode:self];
}

#pragma mark - Dragging 
/**
 *  Method Limits camera moving, with ban of moving in the end
 *
 *  Метод ограничивает передвижение камеры, в конце концов запрещая движение 
 */
//- (void)dragLimitWithDelta:(CGPoint)delta {
//    int scrollZone = (BOUNCE_AREA * self.scale)/2;
//    CGPoint position = self.position;
//    
//    if ((position.x > maxX - scrollZone && position.x < minX + scrollZone) &&
//        (position.y > maxY - scrollZone && position.y < minY + scrollZone)) {
//        self.position = ccpAdd(self.position, delta);
//    }
//}

/**
 *  Method limits camera moving with decreasing velocity
 *  in the end.
 *  distance = maximum area + bounce - current position
 *  ScrollZone points to the area, that user can scroll until bounce.
 *  Velocity in bounce area = delta / i;
 *
 *  Метод ограничивает передвижение камеры, в конце концов
 *  уменьшая движение до минимума. Дистанция определяется по формуле:
 *  максиммальная величина + баунс - нынешняя позиция;
 *  scrollZone указывает область на которую можно оттянуть экран для баунса.
 *  При достижении зоны баунса движение камеры начинает замедляться на
 *  delta/i .
 */
- (void)dragLimitWithDelta:(CGPoint)delta {
    int scrollZone = (BOUNCE_AREA * 2) * self.scale;
    CGPoint position = self.position;
    
    float distanceX = MAXFLOAT;
    if (position.x < maxX) {
        distanceX = (maxX - scrollZone) - position.x;
    } else if (position.x > minX) {
        distanceX = - ((minX + scrollZone) - position.x);
    }
    
    float distanceY = MAXFLOAT;
    if (position.y < maxY) {
        distanceY = (maxY - scrollZone) - position.y;
    } else if (position.y > minY) {
        distanceY = - ((minY + scrollZone) - position.y);
    }
    
    double iX = [self getMultiplierForDistance:distanceX withFullDistance:-scrollZone];
    double iY = [self getMultiplierForDistance:distanceY withFullDistance:-scrollZone];
    self.position = ccpAdd(self.position, ccp(delta.x/iX, delta.y/iY));
}

/**
 *  Method returns divider for distance.
 *  Bounce distance always recuded, so, if bounce not in the end, then
 *  returns 1 and adding distance, that was pass. Otherwise 
 *  returns reduces distance, that creates effect of decreasing velocity;
 *
 *  Метод возвращает делитель для дистанции.
 *  Дистанция баунса всегда сокращается, если баунс не достигнут, тогда
 *  возвращается 1 и прибавляется просто пройденное расстояние. В противном
 *  случае возвращается уменьшенная дистанция, что создаёт эффект уменьшения скорост
 */
- (float)getMultiplierForDistance:(float)distance withFullDistance:(float)fullDistance {

    double max = fabsf(fullDistance);
    double min = fabsf(distance);
    if (min > max) {
        return 1;
    }
    return fullDistance/distance;
}

#pragma mark - Scaling
/**
 *  Need to check in which side scale: zoom in / zoom out.
 *  In bounce zone user have to zoom in opposite side;
 *  Bounce working when scale in bounce area.
 *  YES When locating in open bounce area else NO;
 *  For scale changing confige in define.h MIN SCALE / MAX SCALE
 *
 *  Происходит проверка в какую сторону скейл: приближения/отдаления.
 *  В случае приближении пользователь может отдалить,
 *  но больше не может приблизить. Также баунс работает всегда если пользователь
 *  сам не вышел из зоны баунса. Если вернулся в нормальные пределы, возвращается
 *  YES, иначе NO.  
 *  Для ограничения скейла стоит изменять значение MIN SCALE / MAX SCALE;
 */
- (BOOL)predictionScaleInBounds:(CGFloat)predictionScale {
    
    _xDirection = BounceDirectionStayingStill;
    _yDirection = BounceDirectionStayingStill;
    
    float min = fabsf(self.scale - MIN_SCALE);
    float max = fabsf(self.scale - MAX_SCALE);
    
    /** When locating in bounce area */
    if ((min > max && predictionScale > MAX_SCALE - SCALE_BOUNCE_AREA && predictionScale < MAX_SCALE)||
        (min < max && predictionScale < MIN_SCALE + SCALE_BOUNCE_AREA && predictionScale > MIN_SCALE)) {
        _isScaleBounce = YES;
        return YES;
    }
    /** Zoom in when maximum zoomed out or 
        Zoom out when maximum zoomed in */
    if ((min > max && predictionScale < self.scale) ||
        (min < max && predictionScale > self.scale) ||
        (!_isScaleBounce)) {
        _isScaleBounce = NO;
        return YES;
    }
    return NO;
}

/**
 *  scaleCenter is the point to zoom to..
 *  If you are doing a pinch zoom, this should be the center of your pinch.
 */
- (void)scale:(CGFloat)newScale scaleCenter:(CGPoint)scaleCenter {
    CGPoint oldCenterPoint = ccp(scaleCenter.x * self.scale, scaleCenter.y * self.scale);
    self.scale = newScale;
    CGPoint newCenterPoint = ccp(scaleCenter.x * self.scale, scaleCenter.y * self.scale);
    CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);
    self.position = ccpAdd(self.position, centerPointDelta);
}


#pragma mark - Update
static float friction = 0.92f; //0.96f;

- (void)update:(CCTime)delta {
    
    [self calculateMoving];
    [self calculateScaleBouncing:delta];
}



- (void)calculateMoving {
    CGPoint position = self.position;

    if(_isDragging && !_isScaleBounce) {
        
        _xDirection = BounceDirectionStayingStill;
        _yDirection = BounceDirectionStayingStill;
        _velocity = ccp((position.x - _lastPos.x)/2, (position.y - _lastPos.y)/2);
        _lastPos = position;
        
    } else if(!_isDragging && !_isScaleBounce && !_isTouchBegin) {
        
        /* Check position */
        if (position.x > minX && _xDirection != BounceDirectionGoingLeft) {
            _velocity = ccp(0, _velocity.y);
            _xDirection = BounceDirectionGoingLeft;
        } else if (position.x < maxX && _xDirection != BounceDirectionGoingRight) {
            _velocity = ccp(0, _velocity.y);
            _xDirection = BounceDirectionGoingRight;
        }
        
        if (position.y > minY && _yDirection != BounceDirectionGoingDown) {
            _velocity = ccp(_velocity.x, 0);
            _yDirection = BounceDirectionGoingDown;
        } else if (self.position.y < maxY && _yDirection != BounceDirectionGoingUp) {
            _velocity = ccp(_velocity.x, 0);
            _yDirection = BounceDirectionGoingUp;
        }
        
        /* Calculating velocity */
        /* X */
        if (_xDirection == BounceDirectionGoingLeft || _xDirection == BounceDirectionGoingRight) {
            float delta = 0;
            if (_xDirection == BounceDirectionGoingLeft) {
                if (_velocity.x <= 0) {
                    delta = (minX - position.x);
                }
            }
            if (_xDirection == BounceDirectionGoingRight) {
                if (_velocity.x >= 0) {
                    delta = ((maxX) - position.x);
                }
            }
            float yDeltaPerFrame = (delta / (BOUNCE_TIME * FRAME_RATE));
            _velocity = ccp(yDeltaPerFrame, _velocity.y);
        } else {
            _velocity = ccp(_velocity.x * friction, _velocity.y *friction);
        }
        
        /* Y */
        if (_yDirection == BounceDirectionGoingDown || _yDirection == BounceDirectionGoingUp) {
            float delta = 0;
            if (_yDirection == BounceDirectionGoingDown) {
                if (_velocity.y <= 0) {
                    delta = (minY - position.y);
                }
            }
            if (_yDirection == BounceDirectionGoingUp) {
                if (_velocity.y >= 0) {
                    delta = ((maxY) - position.y);
                }
            }
            float yDeltaPerFrame = (delta / (BOUNCE_TIME * FRAME_RATE));
            _velocity = ccp(_velocity.x, yDeltaPerFrame);
        } else {
            _velocity = ccp(_velocity.x * friction, _velocity.y *friction);
        }
        
        
        position = ccpAdd(position, _velocity);
        self.position = position;
    }
}
- (void)calculateScaleBouncing:(CCTime)delta {
    float scale = self.scale;
    /**
     *  Need to check current scale, according of that multiply by + / - and scale
     *
     *  Необходимо проверить нынешний скейл является в минимальную или
     *  максимальную сторону, в зависимости от этого выставляем множитель
     *  и скейлим.
     */
    if (_isScaleBounce && !_isTouchBegin) {
        float min = fabsf(self.scale - MIN_SCALE);
        float max = fabsf(self.scale - MAX_SCALE);
        int dif = max > min ? 1 : -1;
        
        if ((scale > MAX_SCALE - SCALE_BOUNCE_AREA) ||
            (scale < MIN_SCALE + SCALE_BOUNCE_AREA)) {
            CGFloat newSscale = scale + dif * (delta * friction);
            [self scale:newSscale scaleCenter:_touchLoc];
        } else {
            _isScaleBounce = NO;
        }
    }
}

#pragma mark - Outer methods
#pragma mark - Centering screen
/**
 *  On tap move world center without animation in that point
 *
 *  По нажатию на экран передвигает его центр в данную точку 
 */
- (void)setViewPointCenter:(CGPoint) position {
    CGPoint centerOfView = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    CGPoint viewPoint = ccpSub(centerOfView, position);
    self.position = ccpAdd(self.position, viewPoint);
}

- (void)setViewPointCenterInsideMap:(CGPoint) position {
    
    int k = (([TileMap shared].map.mapSize.width * [TileMap shared].map.tileSize.width) - SCREEN_WIDTH / 2) * self.scale;
    int x = MAX(position.x, SCREEN_WIDTH/2);
    int y = MAX(position.y, SCREEN_HEIGHT/2);
    x = MIN(x, k);
    y = MIN(y, k);
    CGPoint actualPosition = ccp(x * self.scale, y * self.scale);
    
    CGPoint centerOfView = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    
    self.position = viewPoint;
}

@end

/* LERP
 //    CCTime _allTime;
 double scale = [self lerpA:MAX_SCALE - SCALE_BOUNCE_AREA b:MAX_SCALE dt:(double)delta * 2.5];
 - (double)lerpA:(double)a b:(double)b dt:(double)dt {
 const int distance = 1;
 _allTime += dt;
 if (_allTime > distance) {
 _allTime = 0;
 _isScaleBounce = NO;
 _bannedScale = 0;
 return a;
 }
 return a + (b - a) * (distance - _allTime);
 }
 */


/*
 - (void)calculateMoving {
 CGPoint position = self.position;
 
 float minX = _scrollArea.origin.x;
 float maxX = _scrollArea.origin.x/2 + _scrollArea.origin.x;
 
 //    float minY = _scrollArea.origin.y;
 float minY = -320;
 float maxY = _scrollArea.origin.y/2 + _scrollArea.origin.y;
 
 if(_isDragging && !_isScaleBounce) {
 
 _xDirection = BounceDirectionStayingStill;
 _yDirection = BounceDirectionStayingStill;
 _velocity = ccp((position.x - _lastPos.x)/2, (position.y - _lastPos.y)/2);
 _lastPos = position;
 
 } else if(!_isDragging && !_isScaleBounce) {
 
 if (position.x > minX && _xDirection != BounceDirectionGoingLeft) {
 _velocity = ccp(0, _velocity.y);
 _xDirection = BounceDirectionGoingLeft;
 } else if (self.position.x < maxX && _xDirection != BounceDirectionGoingRight) {
 _velocity = ccp(0, _velocity.y);
 _xDirection = BounceDirectionGoingRight;
 }
 
 if (position.y > minY && _yDirection != BounceDirectionGoingDown) {
 _velocity = ccp(_velocity.x, 0);
 _yDirection = BounceDirectionGoingDown;
 } else if (self.position.y < maxY && _yDirection != BounceDirectionGoingUp) {
 _velocity = ccp(_velocity.x, 0);
 _yDirection = BounceDirectionGoingUp;
 }
 
 if (_xDirection == BounceDirectionGoingLeft) {
 if (_velocity.x <= 0) {
 float delta = (minX - position.x);
 float yDeltaPerFrame = (delta / (BOUNCE_TIME * FRAME_RATE));
 _velocity = ccp(yDeltaPerFrame, _velocity.y);
 }
 if((position.x - 0.5f) <= minX) {
 _velocity = ccp(0, _velocity.y);
 _xDirection = BounceDirectionStayingStill;
 }
 
 } else if (_xDirection == BounceDirectionGoingRight) {
 if (_velocity.x >= 0) {
 float delta = ((maxX) - position.x);
 float yDeltaPerFrame = (delta / (BOUNCE_TIME * FRAME_RATE));
 _velocity = ccp(yDeltaPerFrame, _velocity.y);
 }
 if((position.x + 0.5f) >= maxX) {
 _velocity = ccp(0, _velocity.y);
 _xDirection = BounceDirectionStayingStill;
 }
 
 } else {
 _velocity = ccp(_velocity.x * friction, _velocity.y *friction);
 }
 
 if (_yDirection == BounceDirectionGoingDown) {
 if (_velocity.y <= 0) {
 float delta = (minY - position.y);
 float yDeltaPerFrame = (delta / (BOUNCE_TIME * FRAME_RATE));
 _velocity = ccp(_velocity.x, yDeltaPerFrame);
 }
 if((position.y - 0.5f) <= minY) {
 _velocity = ccp(_velocity.x, 0);
 _yDirection = BounceDirectionStayingStill;
 }
 } else if (_yDirection == BounceDirectionGoingUp) {
 if (_velocity.y >= 0) {
 float delta = ((maxY) - position.y);
 float yDeltaPerFrame = (delta / (BOUNCE_TIME * FRAME_RATE));
 _velocity = ccp(_velocity.x, yDeltaPerFrame);
 }
 if((position.y + 0.5f) >= maxY) {
 _velocity = ccp(_velocity.x, 0);
 _yDirection = BounceDirectionStayingStill;
 }
 } else {
 _velocity = ccp(_velocity.x * friction, _velocity.y *friction);
 }
 
 position = ccpAdd(position, _velocity);
 self.position = position;
 }
 }
 */

