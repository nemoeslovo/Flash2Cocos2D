//
//  AnimationsSet.m
//  adventurepark
//
//  Created by Danila Kolesnikov on 1/10/13.
//
//

#import "FTCAnimationsSet.h"

@implementation FTCAnimationsSet

@synthesize frameRate = _frameRate;
@synthesize animations = _animations;

- (id)init {
    self = [super init];
    if (self) {
        _animations = [NSMutableArray array];
    }
    return self;
}

@end
