//
//  FTCPartInfo.m
//  adventurepark
//
//  Created by Danila Kolesnikov on 1/10/13.
//
//

#import "FTCPartInfo.h"

@implementation FTCPartInfo

@synthesize name;
@synthesize framesInfo = _framesInfo;

- (id)init {
    self = [super init];
    if (self) {
        _framesInfo = [NSMutableArray array];
    }
    return self;
}

@end
