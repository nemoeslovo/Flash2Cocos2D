//
// Created by Danila Kolesnikov on 5/6/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


/*
* class assignment is to contain the name of the animation
* and the number of repetitions of the animation with that name.
* using in method
*
* - (void)addAnimationPresetWithKey:(NSString *)_key
*   andPresetParts:(FTCPresetPart *)_presetPart, ... NS_REQUIRES_NIL_TERMINATION
*
*   in FTCAnimatedNode
* */

@interface FTCPresetPart : NSObject

@property NSString  *animationName;
@property NSInteger  numberOfRepetitions;

@end