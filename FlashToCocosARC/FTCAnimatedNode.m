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

@interface FTCAnimatedNode()
{
    ////from FTCSprite
    CCNode          *debugDrawingNode;
    NSArray         *currentAnimationInfo;
    FTCAnimatedNode    *currentCharacter;
    /////
}


@property(retain) FTCAnimationsSet *animationSet;

///from ftc sprite////

@property (strong)            NSString              *name;
@property (nonatomic, strong) NSMutableDictionary   *frameInfoArray;

-(id)initWithFile:(NSString *)filename andPartAnimation:(FTCPartInfo *)partInfo;

-(void) setCurrentAnimation:(NSString *)_framesId forCharacter:(FTCAnimatedNode *)_character;
-(void) setCurrentAnimationFramesInfo:(NSArray *)_framesInfoArr forCharacter:(FTCAnimatedNode *)_character;
-(void) applyFrameInfo:(FTCFrameInfo *)_frameInfo;
-(void) playFrame:(int)_frameindex;

/////////////////////
@end

@implementation FTCAnimatedNode
{
    void (^onComplete) ();
}

@synthesize childrenTable;
@synthesize animationEventsTable;
@synthesize delegate;
@synthesize frameRate;
@synthesize animationSet;

/// from FTCSprite
@synthesize name;
@synthesize frameInfoArray = _animationsArr;


+(FTCAnimatedNode *) characterFromXMLFile:(NSString *)_xmlfile
{
    FTCAnimatedNode *_c = [[FTCAnimatedNode alloc] init];
    [_c createCharacterFromXML:_xmlfile];
    return _c;
}

+(FTCAnimatedNode *) characterFromXMLFile:(NSString *)_xmlfile onCharacterComplete:(void(^)())completeHandler
{
    FTCAnimatedNode *_c = [_c initFromXMLFile:_xmlfile onCharacterComplete:completeHandler];
    return _c;
}

-(id) initFromXMLFile:(NSString *)_xmlfile {
    
    self = [self init];
    if (self)
    {
        [self createCharacterFromXML:_xmlfile];
    }
    
    return self;
}

-(id) initFromXMLFile:(NSString *)_xmlfile onCharacterComplete:(void (^)())completeHandler {
    
    self = [self init];
    if (self)
    {
        [self createCharacterFromXML:_xmlfile onCharacterComplete:completeHandler];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initProperties];
    }
    
    return self;
}

- (void) initProperties
{
    self.childrenTable = [[NSMutableDictionary alloc] init];
    
    self.animationEventsTable = [[NSMutableDictionary alloc] init];
    
    currentAnimationId = @"";
}

-(void) handleScheduleUpdate:(ccTime)_dt
{
    if (currentAnimationLength == 0 || _isPaused )
        return;
    
    intFrame ++;
    
    // end of animation
    if (intFrame == currentAnimationLength) {
        
        if (![nextAnimationId isEqualToString:@""]) {
            [self playAnimation:nextAnimationId loop:nextAnimationDoesLoop wait:NO];
            return;
            
        }
        
        if (!_doesLoop) {
            [self stopAnimation];
            return;
        }
        
        intFrame = 0;
        if ([delegate respondsToSelector:@selector(onCharacter:loopedAnimation:)])
            [delegate onCharacter:self loopedAnimation:currentAnimationId];
        
    }
    
    [self playFrame];    
}

-(void) playFrame
{
    // check if theres any event for that frame
    if ([[currentAnimEvent objectAtIndex:intFrame] class]!=[NSNull class]) {
        if ([delegate respondsToSelector:@selector(onCharacter:event:atFrame:)])
            [delegate onCharacter:self event:[(FTCEventInfo *)[currentAnimEvent objectAtIndex:intFrame] eventType] atFrame:intFrame];
    };
    
    if ([delegate respondsToSelector:@selector(onCharacter:updateToFrame:)])
        [delegate onCharacter:self updateToFrame:intFrame];
    
    for (FTCSprite *sprite in self.childrenTable.allValues) {
        [sprite playFrame:intFrame];
    }    
}

-(void) pauseAnimation
{
    _isPaused = YES;
}

-(void) resumeAnimation
{
    _isPaused = NO;
}

-(int) getCurrentFrame
{
    return intFrame;
}

-(void) playFrame:(int)_frameIndex fromAnimation:(NSString *)_animationId
{
    //NSLog(@"PLAYING FRAME %i FROM %@", _frameIndex, _animationId);
    currentAnimationId = _animationId;
    currentAnimEvent = [[self.animationEventsTable objectForKey:_animationId] eventsInfo];
    currentAnimationLength = [[self.animationEventsTable objectForKey:_animationId] frameCount];
    intFrame = _frameIndex;
    _isPaused = YES;
    for (FTCSprite *sprite in self.childrenTable.allValues) {
        [sprite setCurrentAnimation:currentAnimationId forCharacter:self];
    }
    [self playFrame];
}

-(void) stopAnimation
{
    currentAnimationLength = 0;
    NSString *oldAnimId = currentAnimationId;
    currentAnimationId = @"";
    
    if ([delegate respondsToSelector:@selector(onCharacter:endsAnimation:)])
        [delegate onCharacter:self endsAnimation:oldAnimId];
}

-(void) playAnimation:(NSString *)_animId loop:(BOOL)_isLoopable wait:(BOOL)_wait
{
    if (_wait && currentAnimationLength>0) {
        nextAnimationId = _animId;
        nextAnimationDoesLoop = _isLoopable;
        return;
    }
    
    _isPaused = NO;
    
    nextAnimationId = @"";
    nextAnimationDoesLoop = NO;
    
    intFrame = 0;
    _doesLoop = _isLoopable;
    currentAnimationId = _animId;
    
    
    for (FTCSprite *sprite in self.childrenTable.allValues) {
        [sprite setCurrentAnimation:currentAnimationId forCharacter:self];
    }
    
    currentAnimEvent = [[self.animationEventsTable objectForKey:_animId] eventsInfo];
    
    //TODO make dictionary
    for(FTCAnimationInfo *animation in [[self animationSet] animations]) {
        if ([[animation name] isEqualToString:_animId]) {
            currentAnimationLength = [animation frameCount];
        }
    }
    
    //    NSLog(@"PLAY ANIMATION - %@ CurrentAnimLength %i", _animId, currentAnimationLength);
    
    if ([delegate respondsToSelector:@selector(onCharacter:startsAnimation:)])
        [delegate onCharacter:self startsAnimation:_animId];
    
}

-(FTCSprite *) getChildByName:(NSString *)_childname
{
    // build a predicate to look in the table what object has the propery _childname in .name
    return [self.childrenTable objectForKey:_childname];
}

-(NSString *) getCurrentAnimation
{
    return currentAnimationId;
}

-(int) getDurationForAnimation:(NSString *)_animationId
{
    return [[self.animationEventsTable objectForKey:_animationId] frameCount];
}

-(void) addElement:(FTCSprite *)_element withName:(NSString *)_name atIndex:(int)_index
{
    [self addChild:_element z:_index];
    
    
    [_element setName:_name];
    
    [self.childrenTable setValue:_element forKey:_name];
}

-(void) reorderChildren
{
    int totalChildren = self.childrenTable.count;
    [self.childrenTable.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self reorderChild:obj z:totalChildren-idx];
    }];
}

-(void) createCharacterFromXML:(NSString *)_xmlfile
{
    [self fillWithObjects:[FTCParser parseSheetXML:_xmlfile]];
    [self fillSpritesWithAnimationSet:[FTCParser parseAnimationXML:_xmlfile]];
    [self setFirstPose];
    [self scheduleAnimation];
}

-(void) fillSpritesWithAnimationSet:(FTCAnimationsSet *)_animationSet
{
    [self setFrameRate:[_animationSet framerate]];
    for (FTCAnimationInfo *animation in [_animationSet animations]) {
        for(FTCPartInfo *part in [animation parts]) {
            FTCSprite *sprite = [self getChildByName:[part name]];
            [[sprite animationsArr] setValue:[part framesInfo] forKey:[animation name]];
        }
    }
    [self setAnimationSet:_animationSet];
}

-(void) fillWithObjects:(NSArray *)objects
{
    for (FTCObjectInfo *info in objects) {
        
        FTCSprite *_sprite = [FTCSprite spriteWithFile:[info path]];
        
        // SET ANCHOR P
        CGSize eSize = [_sprite boundingBox].size;
        CGPoint aP = CGPointMake( [info registrationPointX] / eSize.width
                                , (eSize.height - (-[info registrationPointY])) / eSize.height);
        
        [_sprite setAnchorPoint:aP];
        [_sprite setName:[info name]];
        
        [self addElement:_sprite withName:[info name] atIndex:[info zIndex]];
    }
}

-(void) scheduleAnimation
{
    [scheduler_ unscheduleAllSelectorsForTarget:self];
    [scheduler_ scheduleSelector:@selector(handleScheduleUpdate:) forTarget:self interval:frameRate/1000 paused:NO];
}

-(void) createCharacterFromXML:(NSString *)_xmlfile onCharacterComplete:(void(^)())completeHandler
{
    onComplete = completeHandler;
    return [self createCharacterFromXML:_xmlfile];
}

-(void) setFirstPose
{
    if ([self.delegate respondsToSelector:@selector(onCharacterCreated:)])
        [self.delegate onCharacterCreated:self];
    
    if (onComplete)
        onComplete();
}

-(void) setCurrentAnimation:(NSString *)_framesId forCharacter:(FTCAnimatedNode *)_character
{
    currentCharacter = _character;
    currentAnimationInfo = [self.frameInfoArray objectForKey:_framesId];
}

-(NSMutableDictionary*) animationsArr
{
    if (_animationsArr == nil)
        _animationsArr = [[NSMutableDictionary alloc] init];
    
    return _animationsArr;
}

-(void) setCurrentAnimationFramesInfo:(NSArray *)_framesInfoArr forCharacter:(FTCAnimatedNode *)_character
{
    currentCharacter = _character;
    currentAnimationInfo = _framesInfoArr;
}


-(void) applyFrameInfo:(FTCFrameInfo *)_frameInfo
{
    if (!_ignorePosition)
        [self setPosition:CGPointMake(_frameInfo.x, _frameInfo.y)];
    
    if (!_ignoreRotation)
        [self setRotation:_frameInfo.rotation];
    
    if (!_ignoreScale) {
        if (_frameInfo.scaleX!=0)   [self setScaleX:_frameInfo.scaleX];
        if (_frameInfo.scaleY!=0)   [self setScaleY:_frameInfo.scaleY];
    }
    
    if (!_ignoreAlpha)
        [self setOpacity:_frameInfo.alpha * 255];
}


-(void) playFrame:(int)_frameindex
{
    if (!currentAnimationInfo) return;
    if (_frameindex < currentAnimationInfo.count)
        [self applyFrameInfo:[currentAnimationInfo objectAtIndex:_frameindex]];
}


@end
