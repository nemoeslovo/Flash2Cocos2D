//
//  FTCFrameInfo.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCFrameInfo.h"

@implementation FTCFrameInfo {
@private
    CGFloat _a;
    CGFloat _b;
    CGFloat _c;
    CGFloat _d;
    CGFloat _tx;
    CGFloat _ty;
    BOOL _topMargined;
    BOOL _rightMargined;
}


@synthesize index;
@synthesize alpha;
@synthesize a = _a;
@synthesize b = _b;
@synthesize c = _c;
@synthesize d = _d;
@synthesize tx = _tx;
@synthesize ty = _ty;

//TODO make manual setters that set opposite properties to NO
@synthesize leftMargined;
@synthesize bottomMargined;
@synthesize topMargined = _topMargined;
@synthesize rightMargined = _rightMargined;


- (id)init {
    self = [super init];
    if (self) {
        leftMargined   = NO;
        bottomMargined = NO;
        _topMargined   = NO;
        _rightMargined = NO;
    }
    return self;
}

- (BOOL)isMargined {
    return leftMargined || _rightMargined || _topMargined || bottomMargined;
}

@end
