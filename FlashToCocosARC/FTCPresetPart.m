//
// Created by Danila Kolesnikov on 5/6/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FTCPresetPart.h"


@implementation FTCPresetPart {
@private
    NSString *_animationName;
    NSInteger _numberOfRepetitions;
}

@synthesize animationName = _animationName;
@synthesize numberOfRepetitions = _numberOfRepetitions;


+ (id)partNamed:(NSString *)_name repeated:(NSInteger)_count {
    return [[self alloc] initWithAnimationName:_name andCount:_count];
}

- (id)initWithAnimationName:(NSString *)_name andCount:(NSInteger)_count {
    self = [super init];
    if (self) {
        _animationName       = _name;
        _numberOfRepetitions = _count;
    }
    return self;
}

@end