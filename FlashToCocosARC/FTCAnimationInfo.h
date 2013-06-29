//
//  FTCAnimationInfo.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCAnimationInfo : NSObject

@property (strong) NSString       *name;
@property          int            frameCount;
@property (strong) NSMutableArray *parts;

@end