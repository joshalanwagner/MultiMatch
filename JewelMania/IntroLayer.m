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
	
    if ( size.height == 1024 && [UIScreen mainScreen].scale == 1)
    {
        background = [CCSprite spriteWithFile:@"mainMenuBG.png"];
        background.scaleX = 1.2;
        background.scaleY = sd.imgScaleFactorY;
    }
    else
    {
        background = [CCSprite spriteWithFile:@"mainMenuBG.png"];
    }
    
    
    background.anchorPoint=ccp(0,1);
    
    if(size.height == 568)
    {
        background.scaleY = 1.2;
    }

	
	background.position = ccp(0, size.height);

	// add the label as a child to this Layer
	[self addChild: background];
	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:2];
}

-(void) makeTransition:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameMain scene] withColor:ccBLACK]];
}
@end
