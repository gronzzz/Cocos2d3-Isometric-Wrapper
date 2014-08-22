//
//  TileMap.h
//  Theme School
//
//  Created by Vitaliy Zarubin on 06.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "cocos2d.h"
#import "Area.h"

@class GameSprite;

@interface TileMap : NSObject

@property (nonatomic, strong, readonly) CCTiledMap *map;
@property (nonatomic, strong, readonly) CCTiledMapLayer *earth;
@property (nonatomic, assign, readonly) CGPoint spawnPoint;

@property (nonatomic, strong, readonly) Area *playableArea;

+ (instancetype)shared;

#pragma mark - Loading object
/// -----------------------------------------------------------------------
/// @name Loading
/// -----------------------------------------------------------------------
- (void)loadMapWithFile:(NSString *)mapFile;


#pragma mark - Playable Area
/// -----------------------------------------------------------------------
/// @name Set playable area
/// -----------------------------------------------------------------------
- (void)setupPlayableAreaWithMinPoint:(CGPoint)min maxPoint:(CGPoint)max;


#pragma mark - Conversion coordinates
/// -----------------------------------------------------------------------
/// @name Conversion
/// -----------------------------------------------------------------------
/**
 *  Calculates screen position from tiled map system coordinates
 *  @param coords - Coordinates of tiled map object
 */
- (CGPoint)worldFromTiledMapCoords:(CGPoint)coords;

/**
 *  Calculates tile from tiled map system coordinates
 *  @param tiledMapCoords - Coordinates of tiled map object
 */
- (CGPoint)tileFromTiledMapCoords:(CGPoint)coords;

/**
 *  Calculate Tiles coordinates from world coordinates
 *  @param screen - Coords of screen
 *  http://clintbellanger.net/articles/isometric_math/
 */
- (CGPoint)tileFromWorld:(CGPoint)world;

/**
 *  Calculate world coordinates from tile coordinates
 *  @param tile - Tile position
 */
- (CGPoint)worldFromTile:(CGPoint)tile;

#pragma mark - Tile checks
/// -----------------------------------------------------------------------
/// @name Tile checking
/// -----------------------------------------------------------------------
/** 
 *  Checks if tile, inside playable without bounce area.
 *  @param tile - Tile;
 */
- (BOOL)isTileInsidePlayableArea:(CGPoint)tile;

/** 
 *  Checks if tile, inside some custom area.
 *  @param tile - Tile;
 *  @param min - Minimum area tile (x,y);
 *  @param max - Maximum area tile (x,y);
 */
- (BOOL)isTile:(CGPoint)tile insideCustomAreaMin:(CGPoint)min max:(CGPoint)max;
    
/**
 *  Say user if tile, that he enter, inside map bounds or not
 *  @param tile - Tile needed to check
 */
- (BOOL)isTileInsideMap:(CGPoint)tile;

/**
 *  Return YES if position of tile is blocked
 *  @param tile - Tile needed to check
 */
- (BOOL)isTilePosBlocked:(CGPoint)tile;




/// -----------------------------------------------------------------------
/// @name Others
/// -----------------------------------------------------------------------
#pragma mark - Between tiles calculations
/**
 *  Calculate angle between two points
 *  @param - point1;
 *  @param - point2;
 */
- (float)getAngleBetweenPoints:(CGPoint)point1 pt2:(CGPoint)point2;


#pragma mark - Debug
/// -----------------------------------------------------------------------
/// @name Debugging
/// -----------------------------------------------------------------------
- (void)debugTile:(CGPoint)tilePos;


/* CHECK ALL THAT METHODS! */
/// -----------------------------------------------------------------------
/// @name Collision checking
/// -----------------------------------------------------------------------
#pragma mark - Collision
/** 
 *  Collision between 2 objects,
 *  need to check useless of func !
 */
- (BOOL)isSpritesCollided:(GameSprite *)sprite1 sprite2:(GameSprite *)sprite2;

- (CGPoint)pointRelativeToCentreFromLocation:(CGPoint)location;

@end
