//
//  TileMap.m
//  Theme School
//
//  Created by Vitaliy Zarubin on 06.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "TileMap.h"
#import "GameSprite.h"


@interface TileMap()
@property (nonatomic, strong, readwrite) CCTiledMap *map;
@property (nonatomic, strong, readwrite) CCTiledMapLayer *earth;
@property (nonatomic, assign, readwrite) CGPoint spawnPoint;
@property (nonatomic, strong, readwrite) Area *playableArea;
@end


@implementation TileMap

+ (instancetype)shared {
	static TileMap *globalInstance;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
        globalInstance = [[self alloc] init];
    });
	return globalInstance;
}

- (void)loadMapWithFile:(NSString *)mapFile {
    self.map = [CCTiledMap tiledMapWithFile:mapFile];
    self.earth = [self.map layerNamed:@"Background"];
    NSDictionary *spawn = [[self.map objectGroupNamed:@"objects"] objectNamed:@"spawn"];
    // On tiled map Y became invertical, so Y position is "mapHeight - currentY"
    double height = self.map.mapSize.height * self.map.tileSize.height;
    double y = height - [spawn[@"y"] doubleValue];
    self.spawnPoint = [self worldFromTiledMapCoords:ccp([spawn[@"x"] doubleValue], y)];
}


#pragma mark - Playable Area
- (void)setupPlayableAreaWithMinPoint:(CGPoint)min maxPoint:(CGPoint)max {
    if (!self.playableArea) {
        self.playableArea = [[Area alloc] init];
    }
    [self.playableArea setupAreaWithMinPoint:min maxPoint:max];
}

#pragma mark - Outter methods
#pragma mark - System coordinates conversation
- (CGPoint)worldFromTiledMapCoords:(CGPoint)coords {
    return [self worldFromTile:[self tileFromTiledMapCoords:coords]];
}
- (CGPoint)tileFromTiledMapCoords:(CGPoint)coords {
    return ccp((int)coords.x/[TileMap shared].map.tileSize.width,
               (int)coords.y/[TileMap shared].map.tileSize.height);
}

- (CGPoint)tileFromWorld:(CGPoint)world {
    
    CGPoint pos = ccpSub(world, [TileMap shared].map.position);
    float halfMapWidth = [TileMap shared].map.mapSize.width * 0.5;
    float mapHeight = [TileMap shared].map.mapSize.height;
    float tileWidth = [TileMap shared].map.tileSize.width;
    float tileHeight = [TileMap shared].map.tileSize.height;
    
    CGPoint tilePosDiv = CGPointMake(pos.x/tileWidth, pos.y/tileHeight);
    float invereseTileY = mapHeight - tilePosDiv.y;
    
    float posX = (int)(invereseTileY + tilePosDiv.x - halfMapWidth);
    float posY = (int)(invereseTileY - tilePosDiv.x + halfMapWidth);
    
    CGPoint position = ccp(posX, posY);
    if (![[TileMap shared] isTileInsideMap:position]) {
        NSLog(@"Tile %f %f is Off the map!", position.x, position.y);
    }
    
    return position;
}

- (CGPoint)worldFromTile:(CGPoint)tile {
    
    float halfMapWidth = [TileMap shared].map.mapSize.width * 0.5;
    float mapHeight = [TileMap shared].map.mapSize.height;
    
    float tileWidth = [TileMap shared].map.tileSize.width;
    float tileHeight = [TileMap shared].map.tileSize.height;
    
    int x = halfMapWidth * tileWidth + (tileWidth * tile.x/2) - (tileWidth * tile.y/2);
    int y = (tile.y + (mapHeight * tileWidth/2) - (tileHeight/2)) - ((tile.y + tile.x) * tileHeight/2) + tileHeight;
    
    return ccp(x, y);
}

#pragma mark - Tile check
- (BOOL)isTileInsidePlayableArea:(CGPoint)tile {

    CGPoint worldTile = [self worldFromTile:tile];
    return [self isTile:worldTile insideCustomAreaMin:ccp(self.playableArea.lb.x, self.playableArea.lb.y)
                    max:ccp(self.playableArea.rt.x, self.playableArea.rt.y)];
}

- (BOOL)isTile:(CGPoint)tile insideCustomAreaMin:(CGPoint)min max:(CGPoint)max {
    if ((tile.x < min.x) ||
        (tile.x > max.x) ||
        (tile.y < min.y) ||
        (tile.y > max.y)) {
        NSLog(@" Object is out of custom area! ");
        return NO;
    }
    return YES;
}

- (BOOL)isTileInsideMap:(CGPoint)tile {
    return [self isTile:tile insideCustomAreaMin:ccp(0,0)
                    max:ccp(self.map.mapSize.width -1, self.map.mapSize.height -1)];
}

- (BOOL)isTilePosBlocked:(CGPoint)tile {
    if (![self isTileInsidePlayableArea:tile]) {
		NSLog(@"Off the map! Tile pos %f %f is not within bounds", tile.x, tile.y);
		return YES;
	}
    
	CCTiledMapLayer *metaLayer = [[TileMap shared].map layerNamed:@"Meta"];
	unsigned int metaTileGID = [metaLayer tileGIDAt:tile];
	if (metaTileGID > 0) {
		NSDictionary *properties = [self.map propertiesForGID:metaTileGID];
		if (properties) {
			NSString *collision = [properties valueForKey:@"Collidable"];
			if ([collision isEqualToString:@"True"]) {
				return YES;
			}
		}
	}
    
	return NO;
}





#pragma mark - Between tiles calculations
static float arctan2(float y, float x) {
	const float ONEQTR_PI = 0.78539816339f;
	const float THRQTR_PI = 2.35619449019f;
	float r, angle;
	float abs_y = fabs(y) + 1e-10f;
	if (x < 0.0f) {
		r = (x + abs_y) / (abs_y - x);
		angle = THRQTR_PI;
	} else {
		r = (x - abs_y) / (x + abs_y);
		angle = ONEQTR_PI;
	}
	angle += (0.1963f * r * r - 0.9817f) * r;
	return (y < 0.0f) ? -angle : angle;
}

- (float)getAngleBetweenPoints:(CGPoint)point1 pt2:(CGPoint)point2 {
	float dx, dy;
	dx = point1.x - point2.x;
	dy = point1.y - point2.y;
	float radians = arctan2(dy, dx);
	float angle = CC_RADIANS_TO_DEGREES(radians);
	if (angle < 0) {
		angle = (360.0f + angle);
	}
	return angle;
}


#pragma mark - Debugging
- (void)debugTile:(CGPoint)tilePos {
	[[TileMap shared].earth setTileGID:230 at:tilePos];
}





#pragma mark - Collisions
- (BOOL)isSpritesCollided:(GameSprite *)sprite1 sprite2:(GameSprite *)sprite2 {
	NSString *spriteClass1 = [NSString stringWithFormat:@"%@",[sprite1 class]];
	NSString *spriteClass2 = [NSString stringWithFormat:@"%@",[sprite2 class]];
    
	CGRect spriteRect1;
	CGRect spriteRect2;
	// Do normal collision detection for bullet.
	// Make allowances for huge transparent border for everything else.
	if ([spriteClass1 isEqual:@"Bullet"]) {
		spriteRect1 = CGRectMake(
                                 sprite1.position.x - (sprite1.contentSize.width/2),
                                 sprite1.position.y - (sprite1.contentSize.height/2),
                                 sprite1.contentSize.width,
                                 sprite1.contentSize.height);
	} else {
		spriteRect1 = CGRectMake(
                                 sprite1.position.x - (sprite1.contentSize.width/4),
                                 sprite1.position.y - (sprite1.contentSize.height/4),
                                 sprite1.contentSize.width / 2,
                                 sprite1.contentSize.height / 2);
	}
	if ([spriteClass2 isEqual:@"Bullet"]) {
		spriteRect2 = CGRectMake(
								 sprite2.position.x - (sprite2.contentSize.width/2),
								 sprite2.position.y - (sprite2.contentSize.height/2),
								 sprite2.contentSize.width,
								 sprite2.contentSize.height);
	} else {
		spriteRect2 = CGRectMake(
								 sprite2.position.x - (sprite2.contentSize.width/4),
								 sprite2.position.y - (sprite2.contentSize.height/4),
								 sprite2.contentSize.width / 2,
								 sprite2.contentSize.height / 2);
	}
	return CGRectIntersectsRect(spriteRect1, spriteRect2);
}




//- (CGPoint)pointRelativeToCentreFromLocation:(CGPoint)location {
//	return ccpSub([TileMap shared].map.position, location);
//}





@end
