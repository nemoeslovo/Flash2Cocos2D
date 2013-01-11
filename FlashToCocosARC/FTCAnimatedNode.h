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
    NSString                    *nextAnimationId;
    
    BOOL                        _doesLoop;
    BOOL                        nextAnimationDoesLoop;
    BOOL                        _isPaused;
}

typedef struct _ftcAnimationFlags {
    BOOL       ignoreRotation;
    BOOL       ignorePosition;
    BOOL       ignoreScale;
    BOOL       ignoreAlpha;
} animationFlags;

@property (unsafe_unretained) id<FTCCharacterDelegate> delegate;
@property (strong) NSMutableDictionary *childrenTable;
@property (strong) NSMutableDictionary *animationEventsTable;
@property float frameRate;

/*
    use this method to load complite exported from flash file with prefixes
    {_xmlfile}_sheets.xml and {_xmlfile}_animation.xml
 */
+(FTCAnimatedNode *) characterFromXMLFile:(NSString *)_xmlfile;

/*
    use this method to get node with before loaded animation (for 
    purpose of loading animation use FTCParser
 */
+(FTCAnimatedNode *) characterFromNode:(CCNode *)node andPartAnimation:(FTCPartInfo *)partAnimation;
/*
    use this method to get enclosed animation.
    E.g. before using this method you create animated robot, and now you want to
         rotate whole robot(with all his parts) at the same time as robot make
         only arms animation
 */
+(FTCAnimatedNode *) characterFromAnimationNode:(FTCAnimatedNode *)node andPartAnimation:(FTCPartInfo *)partAnimation;



-(void) playAnimation:(NSString *)_animId loop:(BOOL)_isLoopable wait:(BOOL)_wait;
-(void) stopAnimation;
-(void) pauseAnimation;
-(void) resumeAnimation;


-(void) playFrame:(int)_frameIndex fromAnimation:(NSString *)_animationId;
-(void) playFrame;


-(id) initFromXMLFile:(NSString *)_xmlfile;
-(NSString *) getCurrentAnimation;
-(int) getDurationForAnimation:(NSString *)_animationId;
-(FTCAnimatedNode *) getChildByName:(NSString *)_childName;
-(int) getCurrentFrame;
-(void) addElement:(FTCAnimatedNode *)_element withName:(NSString *)_name atIndex:(int)_index;
-(void) reorderChildren;

// private
-(void) setFirstPose;
-(void) createCharacterFromXML:(NSString *)_xmlfile;
-(void) scheduleAnimation;

@end


@protocol FTCAnimationNodeDelegate <NSObject>

@optional
-(void) onCharacterCreated:(FTCAnimatedNode *)_character;
-(void) onCharacter:(FTCAnimatedNode *)_character event:(NSString *)_event atFrame:(int)_frameIndex;
-(void) onCharacter:(FTCAnimatedNode *)_character endsAnimation:(NSString *)_animationId;
-(void) onCharacter:(FTCAnimatedNode *)_character startsAnimation:(NSString *)_animationId;
-(void) onCharacter:(FTCAnimatedNode *)_character updateToFrame:(int)_frameIndex;
-(void) onCharacter:(FTCAnimatedNode *)_character loopedAnimation:(NSString *)_animationId;

@end