//
//  FTCObjectInfo.m
//
//  Created by Danila Kolesnikov on 1/9/13.
//  Copyright 2013 Flexymind. All rights reserved.
//
//

#import "FTCObjectInfo.h"

@implementation FTCObjectInfo

@synthesize name;
@synthesize path;
@synthesize registrationPointX;
@synthesize registrationPointY;
@synthesize zIndex;

-(id)initWithName:(NSString *)_name andPath:(NSString *)_path andRPX:(float)_rpx andRPY:(float)_rpy andZIndex:(int)_zIndex {
    self = [super init];
    if (self != nil) {
        [self setName:_name];
        [self setPath:_path];
        [self setRegistrationPointX:_rpx];
        [self setRegistrationPointY:_rpy];
        [self setZIndex:_zIndex];
    }
    return self;
}

@end