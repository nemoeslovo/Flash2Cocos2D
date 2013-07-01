//
//  FTCAnimatedNode.h
//
//  Created by Danila Kolesnikov on 1/9/13.
//  Copyright 2013 Flexymind. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class    FTCAnimEvent;
@class    FTCPartInfo;
@class    FTCAnimationsSet;
@protocol FTCAnimatedNodeDelegate;
@class FTCPresetPart;

@interface FTCAnimatedNode : CCMenuItem {
    NSArray     *_currentAnimEvent;
    NSInteger   _intFrame;
    NSInteger   _currentAnimationLength;
    NSString    *_currentAnimationId;
    BOOL        _isPaused;
    BOOL        _doesLoop;
}

@property (unsafe_unretained) id<FTCAnimatedNodeDelegate>  delegate;
@property (strong)            NSString                     *name;

@property (assign)            NSNumber                    *frameRate;

/*
* preset - a sequence of small animations, each of which can
* be repeated several times. it is not recommended to work with the dictionary directly
* , it is better to use a methods
*    - (void)addAnimationPresetWithKey:(NSString *)_key andPresetParts:(FTCPresetPart *)_presetPart, ...;
*    and
*    - (void)playAnimationPreset:(NSString *)_key;
*/
@property (nonatomic, strong) NSMutableDictionary         *animationPresets;

/**
* doesLoop - loop animation or not
*/
@property (nonatomic) BOOL doesLoop;

/*
    use this method to load complite exported from flash file with prefixes
    {_xmlfile}_sheets.xml and {_xmlfile}_animation.xml
 */
+ (FTCAnimatedNode *)animatedNodeFromXMLFile:(NSString *)_xmlfile;

/*
    use this method to get node with before loaded animation (for 
    purpose of loading animation use FTCParser
 */
+ (FTCAnimatedNode *)animatedNodeWithSprite:(CCSprite *)sprite 
                           andPartAnimation:(FTCPartInfo *)partAnimation;
/*
    use this method to get enclosed animation.
    E.g. before using this method you create animated robot, and now you want to
         rotate whole robot(with all his parts) at the same time as robot make
         only arms animation
 */
+ (FTCAnimatedNode *)animatedNodeWithAnimationNode:(FTCAnimatedNode *)node 
                                  andPartAnimation:(FTCPartInfo *)partAnimation;


+ (FTCAnimatedNode *)animatedNodeWithObjectsArray:(NSArray *)_objects andAnimationSet:(FTCAnimationsSet *)_animationSet;

- (id)initFromXMLFile:(NSString *)_xmlfile;

- (id)initWithSprite:(CCSprite *)sprite 
                andPartAnimation:(FTCPartInfo *)partAnimation 
                andAnimationName:(NSString *)animationName;

- (id)initWithObjectsArray:(NSArray *)_objects andAnimationSet:(FTCAnimationsSet *)_animationsSet;

- (id)initWithAnimationNode:(FTCAnimatedNode *)node
           andPartAnimation:(FTCPartInfo *)partAnimation 
           andAnimationName:(NSString *)animationName;

- (void)addAnimation:(FTCPartInfo *)partAnimation 
            withName:(NSString *)animationName;

- (void)playAnimationPreset:(NSString *)_key;

- (void)addAnimationPresetWithKey:(NSString *)_key andPresetParts:(FTCPresetPart *)_presetPart, ...;

- (void)addAnimationPresetWithKey:(NSString *)_key andAnimationPresets:(NSArray *)_presetParts;

- (NSInteger)animationPresetsCount;

- (void)playAnimation:(NSString *)_animId;

- (void)playAnimation:(NSString *)_animId 
                 loop:(BOOL)_isLoopable 
                 wait:(BOOL)_wait;

- (void)stopAnimation;
- (void)pauseAnimation;
- (void)resumeAnimation;

@end

@protocol FTCAnimatedNodeDelegate
@optional
- (void)onAnimationEnded:(id)object;
@end