//
//  Area.m
//  Theme School
//
//  Created by Vitaliy Zarubin on 20.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import "Area.h"
#import "TileMap.h"

@interface Area()
@property (nonatomic, assign, readwrite) CGPoint lb;
@property (nonatomic, assign, readwrite) CGPoint rt;
@end

@implementation Area

- (void)setupAreaWithMinPoint:(CGPoint)min maxPoint:(CGPoint)max {
    self.lb = [[TileMap shared] worldFromTile:ccp(min.x, min.y)];
    self.rt = [[TileMap shared] worldFromTile:ccp(max.x, max.y)];
}

@end
