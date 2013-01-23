//
//  FTCFrameInfo.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCFrameInfo : NSObject

@property NSInteger   index;
@property CGFloat a;
@property CGFloat b;
@property CGFloat c;
@property CGFloat d;
@property CGFloat tx;
@property CGFloat ty;
@property CGFloat alpha;
@property BOOL    leftMargined;
@property BOOL    bottomMargined;
@property BOOL    topMargined;
@property BOOL    rightMargined;

- (BOOL)isMargined;


@end
