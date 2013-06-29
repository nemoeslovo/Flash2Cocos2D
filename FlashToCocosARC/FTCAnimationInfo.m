//
//  FTCAnimationInfo.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCAnimationInfo.h"

@implementation FTCAnimationInfo

@synthesize name;
@synthesize parts = _parts;
@synthesize frameCount;

- (id)init {
    self = [super init];
    if (self) {
        _parts = [NSMutableArray array];
    }
    return self;
}

@end