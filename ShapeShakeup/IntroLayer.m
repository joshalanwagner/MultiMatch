//
//  IntroLayer.m
//  JellyMania
//
//  Created by Chris on 13-7-13.
//  Copyright AppyPocket 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "GameMain.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//
-(void) onEnter
{
	[super onEnter];

	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background;
	
    sd = [SharedData getSharedInstance];
	
    background=[[CCSprite alloc]initWithFile:@"menuBG.pvr.ccz"];
    background.anchorPoint=ccp(0.5,0.5);
    background.scaleY = 1.11;
    background.position=ccp(size.width/2 , size.height/2);

	// add the label as a child to this Layer
	[self addChild: background];
	
	// In one second transition to the new scene: Why wait here?
	[self scheduleOnce:@selector(makeTransition:) delay:0];
}

-(void) makeTransition:(ccTime)dt
{
    [[CCDirector sharedDirector] pushScene: [GameMain scene]];
//	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameMain scene] withColor:ccBLACK]];
}
@end
