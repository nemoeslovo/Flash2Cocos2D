//
//  FTCAnimatedNode.m
//
//  Created by Danila Kolesnikov on 1/9/13.
//  Copyright 2013 Flexymind. All rights reserved.
//
//

#import "FTCAnimatedNode.h"
#import "FTCParser.h"
#import "FTCEventInfo.h"
#import "FTCObjectInfo.h"
#import "FTCAnimationsSet.h"
#import "FTCAnimationInfo.h"
#import "FTCPartInfo.h"
#import "FTCFrameInfo.h"
#import "cocos2d.h"


@interface FTCAnimatedNode() {
    NSArray         *currentAnimationInfo;
}

typedef struct _ftcIgnoreAnimationFlags {
    BOOL       ignoreRotation;
    BOOL       ignorePosition;
    BOOL       ignoreScale;
    BOOL       ignoreAlpha;
} ignoreAnimationFlags;

@property(nonatomic) BOOL isAnimatedNodeTransform;
@property(retain) FTCAnimationsSet *animationSet;

//table for objects, that can response to applyFrame:(int) selector
@property (strong) NSMutableDictionary *childrenTable;
//table for events of whole animation
@property (strong) NSMutableDictionary *animationEventsTable;
@property (strong) NSString            *name;

//table of name -> animation that this AnimatedNode able response
@property (nonatomic, strong) NSMutableDictionary   *frameInfoArray;

- (void)setFirstPose;
- (void)playFrame:(NSInteger)_frameIndex fromAnimation:(NSString *)_animationId;
- (void)playFrame;
- (void)scheduleAnimation;
- (NSString *)getCurrentAnimation;
- (NSInteger)getDurationForAnimation:(NSString *)_animationId;
- (FTCAnimatedNode *)getChildByName:(NSString *)_childName;

- (void)addElement:(FTCAnimatedNode *)_element 
          withName:(NSString *)_name 
           atIndex:(NSInteger)_index;

- (void)reorderChildren;
- (void)setCurrentAnimation:(NSString *)_framesId;
- (void)setCurrentAnimationFramesInfo:(NSArray *)_framesInfoArr;
- (void)applyFrameWithId:(NSInteger)_frameindex;
- (void)applyFrameInfo:(FTCFrameInfo *)_frameInfo;

@end

@implementation FTCAnimatedNode {
    void (^onComplete) ();

@private
    BOOL _isAnimatedNodeTransform;
}

@synthesize childrenTable;
@synthesize animationEventsTable;
@synthesize delegate;
@synthesize frameRate;
@synthesize animationSet;
/// from FTCSprite
@synthesize name;
@synthesize frameInfoArray = _frameInfoArray;
@synthesize isAnimatedNodeTransform = _isAnimatedNodeTransform;


- (id)initFromXMLFile:(NSString *)_xmlfile {
    self = [self init];
    if (self) {
        [self fillWithObjects:[FTCParser parseSheetXML:_xmlfile]];
        [self fillSpritesWithAnimationSet:[FTCParser parseAnimationXML:_xmlfile]];
        [self setFirstPose];
        [self scheduleAnimation];
    }
    
    return self;
}

- (id)initWithSprite:(CCSprite *)sprite 
                andPartAnimation:(FTCPartInfo *)partAnimation 
                andAnimationName:(NSString *)animationName {
    
    FTCAnimatedNode *node = [[FTCAnimatedNode alloc] init];
    [node addChild:sprite];
    self = [self initWithAnimationNode:node 
                      andPartAnimation:partAnimation 
                      andAnimationName:animationName];
    
    return self;
}

- (id)initWithAnimationNode:(FTCAnimatedNode *)node 
           andPartAnimation:(FTCPartInfo *)partAnimation 
           andAnimationName:(NSString *)animationName {
    
    self = [self init];
    if (self) {
        [node addAnimation:partAnimation 
                  withName:animationName];
        
        [self addElement:node 
                withName:[node name] 
                 atIndex:[node zOrder]];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setChildrenTable:       [NSMutableDictionary dictionary]];
        [self setAnimationEventsTable:[NSMutableDictionary dictionary]];
        [self setFrameInfoArray      :[NSMutableDictionary dictionary]];
        self->currentAnimationId    = [NSString string];
    }
    
    return self;
}

- (void)pauseAnimation {
    _isPaused = YES;
}

- (void)resumeAnimation {
    _isPaused = NO;
}

- (void)stopAnimation {
    currentAnimationLength = 0;
    currentAnimationId     = [NSString string];
}

- (void)playAnimation:(NSString *)_animId 
                 loop:(BOOL)_isLoopable 
                 wait:(BOOL)_wait {
    
    if (_wait && currentAnimationLength > 0) {
        return;
    }
    
    _isPaused          = NO;
    
    intFrame           = 0;
    _doesLoop          = _isLoopable;
    currentAnimationId = _animId;
    
    
    for (FTCAnimatedNode *node in [[self childrenTable] allValues]) {
        [node setCurrentAnimation:currentAnimationId];
    }
    
//    currentAnimEvent = [[self.animationEventsTable objectForKey:_animId] eventsInfo];
    
    //TODO make dictionary
    for(FTCAnimationInfo *animation in [[self animationSet] animations]) {
        if ([[animation name] isEqualToString:_animId]) {
            currentAnimationLength = [animation frameCount];
        }
    }

}

- (void)scheduleAnimation {
    [scheduler_ unscheduleAllSelectorsForTarget:self];
    [scheduler_ scheduleSelector:@selector(handleScheduleUpdate:) 
                       forTarget:self 
                        interval:[frameRate floatValue] / 1000 
                          paused:NO];
}

- (void)handleScheduleUpdate:(ccTime)_dt {
    if (currentAnimationLength == 0 || _isPaused ) {
        return;
    }
    
    intFrame ++;
    
    // end of animation
    if (intFrame == currentAnimationLength) {
        
        //TODO add support of animation que
        
        if (!_doesLoop) {
            [self stopAnimation];
            return;
        }
        
        intFrame = 0;
    }
    
    [self playFrame];
}

- (void)playFrame {
    for (FTCAnimatedNode *animationNode in [[self childrenTable] allValues]) {
        [animationNode applyFrame:intFrame];
    }
}

- (FTCAnimatedNode *)getChildByName:(NSString *)_childname {
    // build a predicate to look in the table what object has the propery _childname in .name
    
    return [[self childrenTable] objectForKey:_childname];
}

- (NSInteger)getDurationForAnimation:(NSString *)_animationId {
    //TODO get duration from dictionary of animations, not from animation events dictionary
    return [[[self animationEventsTable] objectForKey:_animationId] frameCount];
}

- (void)addElement:(FTCAnimatedNode *)_element 
          withName:(NSString *)_name 
           atIndex:(int)_index {
    
    [self addChild:_element z:_index];

    [_element setName:_name];
    
    [[self childrenTable] setValue:_element forKey:_name];
}

- (void)reorderChildren {
    int totalChildren = [[self childrenTable] count];
    
    [[[self childrenTable] allValues]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self reorderChild:obj z:totalChildren-idx];
    }];
}

- (void)fillWithObjects:(NSArray *)objects {
    for (FTCObjectInfo *info in objects) {
        
        CCSprite *_sprite = [CCSprite spriteWithFile:[info path]];
        
        // SET ANCHOR P
        CGSize eSize = [_sprite boundingBox].size;
        CGPoint aP = CGPointMake( [info registrationPointX] / eSize.width
                                , (eSize.height - (-[info registrationPointY])) 
                                                  / eSize.height);
        
        [_sprite setAnchorPoint:aP];
        FTCAnimatedNode *newNode = [[FTCAnimatedNode alloc] init];
        [newNode addChild:_sprite];
        [newNode setName:[info name]];
        
        [self addElement:newNode withName:[info name] atIndex:[info zIndex]];
    }
}

- (void)fillSpritesWithAnimationSet:(FTCAnimationsSet *)_animationSet {
    [self setFrameRate:[_animationSet frameRate]];
    for (FTCAnimationInfo *animation in [_animationSet animations]) {
        for(FTCPartInfo *part in [animation parts]) {
            FTCAnimatedNode *node = [self getChildByName:[part name]];
            [node addAnimation:part withName:[animation name]];
        }
    }
    [self setAnimationSet:_animationSet];
}

- (void)addAnimation:(FTCPartInfo *)partAnimation 
            withName:(NSString *)animationName {
    
    [[self frameInfoArray] setObject:[partAnimation framesInfo] 
                              forKey:animationName];
}

- (void)setFirstPose{
    //TODO add delegate
    if (onComplete)
        onComplete();
}

- (void)setCurrentAnimation:(NSString *)_framesId {
    currentAnimationInfo = [[self frameInfoArray] objectForKey:_framesId];
}

- (void)applyFrame:(NSInteger)_frameindex {
    if (currentAnimationInfo) {
        if (_frameindex < currentAnimationInfo.count) {
            [self applyFrameInfo:[currentAnimationInfo objectAtIndex:_frameindex]];
        }
    }
}

- (BOOL)hasChild {
    return [self children] != nil;
}

- (void)setOpacity:(GLubyte)opacity {
    if([self hasChild]) {
        CCArray *parent = [self children];
        
        for(CCNode<CCRGBAProtocol> *child in parent) {
            if ([child respondsToSelector:@selector(setOpacity:)]) {
                [child setOpacity:opacity];
            }
        }
        
    } else {
        [(id<CCRGBAProtocol>) self setOpacity:opacity];
    }
}

- (void)applyFrameInfo:(FTCFrameInfo *)_frameInfo {
    transform_ = CGAffineTransformMake(   _frameInfo.a
                                      ,  - _frameInfo.b
                                      ,  - _frameInfo.c
                                      ,   _frameInfo.d
                                      ,   _frameInfo.tx / 2
                                      , - _frameInfo.ty / 2);

 //    [self setOpacity:_frameInfo.alpha];

}


@end