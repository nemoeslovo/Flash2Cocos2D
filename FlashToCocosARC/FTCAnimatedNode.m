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
#import "FTCPresetPart.h"

//convert va_args to NSArray
#define vaToArray(item, array)  \
id eachObject; \
va_list argumentList; \
if (item) { \
    [array addObject:item]; \
    va_start(argumentList, item); \
    while (eachObject = va_arg(argumentList, id)) { \
        [array addObject: eachObject];  \
    } \
    va_end(argumentList); \
}


@interface FTCAnimatedNode() {
    NSArray         *currentAnimationInfo;
}

typedef struct _ftcIgnoreAnimationFlags {
    BOOL       ignoreRotation;
    BOOL       ignorePosition;
    BOOL       ignoreScale;
    BOOL       ignoreAlpha;
} ignoreAnimationFlags;

typedef struct _ftcCurrentPreset {
    NSInteger index;
    NSInteger repeatNumber;
    BOOL      isPlayed;
} currentPreset;

@property(nonatomic) BOOL isAnimatedNodeTransform;
@property(retain) FTCAnimationsSet *animationSet;

//table for objects, that can response to applyFrame:(int) selector
@property (strong) NSMutableDictionary *childrenTable;
//table for events of whole animation
@property (strong) NSMutableDictionary *animationEventsTable;
@property (strong) NSString            *name;

//table of name -> animation that this AnimatedNode able response
@property (nonatomic, strong) NSMutableDictionary   *frameInfoArray;

@property (nonatomic, strong) NSMutableDictionary   *animationPresets;

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

- (void)addAnimationPresetWithKey:(NSString *)_key andAnimationPresets:(NSArray *)_presetParts;
@end

@implementation FTCAnimatedNode {
@private
    BOOL           _isAnimatedNodeTransform;
    NSArray       *_currentPresetParts;
    currentPreset  _currentPreset;
}

@synthesize childrenTable;
@synthesize animationEventsTable;
@synthesize delegate;
@synthesize frameRate;
@synthesize animationSet;
@synthesize name;
@synthesize frameInfoArray          = _frameInfoArray;
@synthesize isAnimatedNodeTransform = _isAnimatedNodeTransform;


+ (FTCAnimatedNode *)animatedNodeFromXMLFile:(NSString *)_xmlfile {
    id node = [[self alloc] initFromXMLFile:_xmlfile];
    return node;
}

+ (FTCAnimatedNode *)animatedNodeWithSprite:(CCSprite *)sprite andPartAnimation:(FTCPartInfo *)partAnimation andAnimationNode:(NSString *)name {
    id node = [[self alloc] initWithSprite:sprite andPartAnimation:partAnimation andAnimationName:name];
    return node;
}

+ (FTCAnimatedNode *)animatedNodeWithAnimationNode:(FTCAnimatedNode *)node andPartAnimation:(FTCPartInfo *)partAnimation andAnimationName:(NSString *)name {
    id node_ = [[self alloc] initWithAnimationNode:node andPartAnimation:partAnimation andAnimationName:name];
    return node_;
}

+ (FTCAnimatedNode *)animatedNodeWithObjectsArray:(NSArray *)_objects
                                  andAnimationSet:(FTCAnimationsSet *)_animationSet {
    id node = [[self alloc] initWithObjectsArray:_objects
                                 andAnimationSet:_animationSet];
    return node;
}

- (id)initFromXMLFile:(NSString *)_xmlfile {
    return [self initWithObjectsArray:[FTCParser parseSheetXML:_xmlfile]
                      andAnimationSet:[FTCParser parseAnimationXML:_xmlfile]];
}

- (id)initWithSprite:(CCSprite *)sprite
                andPartAnimation:(FTCPartInfo *)partAnimation
                andAnimationName:(NSString *)animationName {

    FTCAnimatedNode *node = [[FTCAnimatedNode alloc] init];
    [node addChild:sprite];
    return [self initWithAnimationNode:node
                      andPartAnimation:partAnimation
                      andAnimationName:animationName];
}

- (id)init {
    return [self initWithObjectsArray:nil
                      andAnimationSet:nil];
}

- (id)initWithObjectsArray:(NSArray *)_objects
           andAnimationSet:(FTCAnimationsSet *)_animationsSet {
    self = [super init];
    if (self) {
        [self setChildrenTable:       [NSMutableDictionary dictionary]];
        [self setAnimationEventsTable:[NSMutableDictionary dictionary]];
        [self setFrameInfoArray      :[NSMutableDictionary dictionary]];
        self->currentAnimationId    = [NSString string];

        if (_objects) {
            [self fillWithObjects:_objects];
        }
        if (_animationsSet) {
            [self fillSpritesWithAnimationSet:_animationsSet];
        }
        [self setFirstPose];
        [self scheduleAnimation];
        _currentPreset.isPlayed = NO;
    }

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

- (void)pauseAnimation {
    _isPaused = YES;
}

- (void)resumeAnimation {
    _isPaused = NO;
}

- (void)stopAnimation {
    currentAnimationLength = 0;
    currentAnimationId     = [NSString string];
    if (_currentPreset.isPlayed) {
        if (_currentPreset.repeatNumber == [_currentPresetParts[_currentPreset.index] numberOfRepetitions]) {
            _currentPreset.index++;
            _currentPreset.repeatNumber = 0;
            if (_currentPreset.index >= [_currentPresetParts count]) {
                _currentPreset.isPlayed = NO;
            }
        } else {
            _currentPreset.repeatNumber++;
        }

        if (_currentPreset.isPlayed) {
            [self playNeededPresetPart];
        } else {
            [delegate onAnimationEnded:self];
        }
    }
}

- (void)playNeededPresetPart {
    [self playAnimation:[_currentPresetParts[_currentPreset.index] animationName]];
    _currentPreset.isPlayed = YES;
}

- (void)playAnimation:(NSString *)_animId {
    [self playAnimation:_animId loop:NO wait:YES];
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
        [newNode setContentSize:[_sprite contentSize]];
        [newNode setName:[info name]];
        
        [self addElement:newNode withName:[info name] atIndex:[info zIndex]];
    }
}

- (void)fillSpritesWithAnimationSet:(FTCAnimationsSet *)_animationSet {
    [self setFrameRate:[_animationSet frameRate]];
    NSInteger maxX = 0;
    NSInteger minX = 0;
    NSInteger maxY = 0;
    NSInteger minY = 0;
    for (FTCAnimationInfo *animation in [_animationSet animations]) {
        for(FTCPartInfo *part in [animation parts]) {
            FTCAnimatedNode *node = [self getChildByName:[part name]];
            [node addAnimation:part withName:[animation name]];
            FTCFrameInfo *info = [[part framesInfo] objectAtIndex:0];
            [node applyFrameInfo:info];

            if (info.tx + [node contentSize].width/2 > maxX) {
                maxX = info.tx + [node contentSize].width/2;
            } else if (info.tx - [node contentSize].width/2 <minX) {
                minX = info.tx - [node contentSize].width/2;
            }

            if (info.ty + [node contentSize].height/2 > maxY) {
                maxY = info.ty + [node contentSize].height/2;
            } else if (info.ty - [node contentSize].height/2 < minY) {
                minY = info.ty - [node contentSize].height/2;
            }

        }
    }
    [self setContentSize:CGSizeMake((maxX - minX)/2, (maxY - minY)/2)];
    [self setAnchorPoint:ccp(0.5, 0.5)];

    [self setAnimationSet:_animationSet];
}

- (void)addAnimation:(FTCPartInfo *)partAnimation 
            withName:(NSString *)animationName {

    [[self frameInfoArray] setObject:[partAnimation framesInfo] 
                              forKey:animationName];
}

- (void)setFirstPose {
    //TODO add delegate
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

- (void)applyFrameInfo:(FTCFrameInfo *)_frameInfo {
    [self applyFrameInfo:_frameInfo isDirty:NO];
}

- (void)applyFrameInfo:(FTCFrameInfo *)_frameInfo isDirty:(BOOL)isDirty {
    transform_ = CGAffineTransformMake(   _frameInfo.a
                                      , - _frameInfo.b
                                      , - _frameInfo.c
                                      ,   _frameInfo.d
                                      ,   _frameInfo.tx / 2
                                      , - _frameInfo.ty / 2);

    [self setOpacity:_frameInfo.alpha * 255];
    self->isTransformDirty_ = isDirty;
}

- (void)playAnimationPreset:(NSString *)_key {
    NSArray *presetParts = [_animationPresets objectForKey:_key];
    if (presetParts) {

        //reset params
        _currentPresetParts         = presetParts;
        _currentPreset.index        = 0;
        _currentPreset.repeatNumber = 0;

        /*
         * start playing first animation in purpose to handle
         * it's end in stopAnimation when it's finished
         * and start next animation or repeat current
         */
        [self playNeededPresetPart];
    }
}

- (void)addAnimationPresetWithKey:(NSString *)_key
                   andPresetParts:(FTCPresetPart *)_presetPart, ... NS_REQUIRES_NIL_TERMINATION {

    NSMutableArray *presetParts = [NSMutableArray array];
    vaToArray(_presetPart, presetParts)
    [self addAnimationPresetWithKey:_key
                andAnimationPresets:presetParts];
}

- (void)addAnimationPresetWithKey:(NSString *)_key andAnimationPresets:(NSArray *)_presetParts {
    if (![self animationPresets]) {
        _animationPresets = [NSMutableDictionary dictionary];
    }

    [[self animationPresets] setObject:_presetParts forKey:_key];
}


@end