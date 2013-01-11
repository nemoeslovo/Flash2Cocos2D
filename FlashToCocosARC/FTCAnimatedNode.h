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
@protocol FTCCharacterDelegate;

@interface FTCAnimatedNode : CCNode
{
    NSArray                     *currentAnimEvent;
    
    int                         intFrame;
    int                         currentAnimationLength;
    NSString                    *currentAnimationId;
    
    BOOL                        _isPaused;
}

@property (unsafe_unretained) id<FTCCharacterDelegate> delegate;
@property float frameRate;

/*
    use this method to load complite exported from flash file with prefixes
    {_xmlfile}_sheets.xml and {_xmlfile}_animation.xml
 */
+(FTCAnimatedNode *) animatedNodeFromXMLFile:(NSString *)_xmlfile;

/*
    use this method to get node with before loaded animation (for 
    purpose of loading animation use FTCParser
 */
+(FTCAnimatedNode *) animatedNodeWithSprite:(CCSprite *)sprite andPartAnimation:(FTCPartInfo *)partAnimation;
/*
    use this method to get enclosed animation.
    E.g. before using this method you create animated robot, and now you want to
         rotate whole robot(with all his parts) at the same time as robot make
         only arms animation
 */
+(FTCAnimatedNode *) animatedNodeWithAnimationNode:(FTCAnimatedNode *)node andPartAnimation:(FTCPartInfo *)partAnimation;


-(id) initFromXMLFile:(NSString *)_xmlfile;
-(id) initWithSprite:(CCSprite *)sprite andPartAnimation:(FTCPartInfo *) partAnimation;
-(id) initWithAnimationNode:(FTCAnimatedNode *)node andPartAnimation:(FTCPartInfo *)partAnimation;

-(void) addAnimation:(FTCPartInfo *)partAnimation;
-(void) playAnimation:(NSString *)_animId loop:(BOOL)_isLoopable wait:(BOOL)_wait;
-(void) stopAnimation;
-(void) pauseAnimation;
-(void) resumeAnimation;


@end