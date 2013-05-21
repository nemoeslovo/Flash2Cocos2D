//
//  FTCParser.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@class FTCAnimatedNode;
@class FTCAnimationsSet;
@class FTCFrameInfo;

@interface FTCParser : NSObject

/**
 send only xml preficses to this methods, not real file names!
 E.g. string @"robot". It will be converted to @"robot_sheet.xml" and @"robot_animation.xml" automatically.
**/
+(NSArray *) parseSheetXML:(NSString *)_xmlfile;
+(FTCAnimationsSet *) parseAnimationXML:(NSString *)_xmlfile;

/**
* if images bigger then needed use this method for scale down transformation matrix
*/
+ (void)scaleSheet:(NSArray *)_objects withAnimationSet:(FTCAnimationsSet *)_animationsSet byScale:(CGFloat)scale;

@end