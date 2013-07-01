//
//  HelloWorldLayer.m
//  F2Cexamle
//
//  Created by Danila Kolesnikov on 6/29/13.
//  Copyright dandandan 2013. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "FTCAnimatedNode.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
	if( (self=[super init]) ) {
        FTCAnimatedNode *dog = [FTCAnimatedNode animatedNodeFromXMLFile:@"dog"];
        [dog playAnimation:@"bark" loop:YES wait:NO];
        [dog setPosition:ccp(200, 200)];
        [self addChild:dog];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
