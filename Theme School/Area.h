//
//  Area.h
//  Theme School
//
//  Created by Vitaliy Zarubin on 20.08.14.
//  Copyright (c) 2014 Holy Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Area : NSObject

@property (nonatomic, assign, readonly) CGPoint lb;
@property (nonatomic, assign, readonly) CGPoint rt;

/**
 *  Setup Area in global position with points
 *  @param min - Minimum point (x, y)
 *  @param max - Maximum point
 */
- (void)setupAreaWithMinPoint:(CGPoint)min maxPoint:(CGPoint)max;
@end
