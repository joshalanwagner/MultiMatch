//
//  HelloWorldLayer.m
//  JellyMania
//
//  Created by Chris on 13-7-13.
//  Copyright AppyPocket 2013. All rights reserved.
//


// Import the interfaces
#import "GameMain.h"
#import "ALInterstitialAd.h"
#import "Chartboost.h"
#import <RevMobAds/RevMobAds.h>
#import "SimpleAudioEngine.h"
#import "InAppManager.h"
// Needed to obtain the Navigation Controller
#import "AppController.h"
#import "Gem.h"
#pragma mark - GameMain


#define kFontColor      ccc3(255,255,255);     // Red, Green, Blue



//// font name
#define FONT_NAME @ "Illuminate"



// GameMain implementation
CGSize ws;
@implementation GameMain

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameMain *layer = [GameMain node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:ccc4(0,0, 0, 1)]) ) {
        
        // Show a Chartboost Ad
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"removeAd"])
        {
            [[Chartboost sharedChartboost] showInterstitial];
            [[Chartboost sharedChartboost] cacheInterstitial];
        }
        
        // Start Music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu.mp3" loop:YES];
        float ip5OffSet;
        
        sd = [SharedData getSharedInstance];
		ws=[[CCDirector sharedDirector]winSize];
        
        // One minute of gameplay
        gameTime=1800;
        
        // number of rows and columns
        if (ws.height==568) {
            hNum=7;
            vNum=10;
            ip5OffSet = 50.0;
        }
        
        else{
            hNum=7;
            vNum=8;
            ip5OffSet = 0.0;
        }
        
        // size of jellies
        gemWid=45*sd.scaleFactorX;
        
        gem2DArr=[[NSMutableArray alloc]init];
        
        for (int j=0; j<vNum; j++) {
            NSMutableArray *hArr=[[NSMutableArray alloc]init];
            for (int i=0; i<hNum; i++) {
                [hArr addObject:@"em"];
            }
            [gem2DArr addObject:hArr];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBtnHandler) name:@"start_multi_game" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multiplayerUnlocked) name:@"multiPlayerUnlocked" object:nil];
        
        
        mainMenuSprite=[[CCSprite alloc]init];
        [self addChild:mainMenuSprite];
        
        // Main Menu
        if ( ws.height == 1024 && [UIScreen mainScreen].scale == 1)
        {
           mainMengBG=[[CCSprite alloc]initWithFile:@"mainMenuBG-hd.png"];
            mainMengBG.scaleX = 1.2; // why scale this?
            mainMengBG.scaleY = sd.imgScaleFactorY;
        }
        else
        {
            mainMengBG=[[CCSprite alloc]initWithFile:@"mainMenuBG.png"];
        }
        
		
        mainMengBG.anchorPoint=ccp(0,1);
        mainMengBG.position=ccp(0,ws.height);
        [mainMenuSprite addChild:mainMengBG];
        
        
        // Main Menu Buttons
        
        // Play button
        startBtn=[self createButtonWithFile:@"buttonPlay_up.png" sel:@selector(startBtnHandler)];
        startBtn.position=ccp(ws.width/2,ws.height-(270+ip5OffSet)*sd.scaleFactorY);
        [mainMenuSprite addChild:startBtn];
      
        /* kill the locking
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"multiplayerUnlocked"])
        {
            multiPlayerBtn = [self createButtonWithFile:@"multiBtnlock.png" sel:@selector(multiPlayerBtnHandler)];
        }
        else */
            
        multiPlayerBtn = [self createButtonWithFile:@"multiBtn.png" sel:@selector(multiPlayerBtnHandler)];
        
        multiPlayerBtn.position = ccp (ws.width/2,ws.height-(317+ip5OffSet)*sd.scaleFactorY);
        [mainMenuSprite addChild:multiPlayerBtn];
        
        // Game Center Leaderboards
        leaderBtn = [self createButtonWithFile:@"leaderBtn.png" sel:@selector(leaderBtnHandler)];
        leaderBtn.position = ccp(ws.width/2,ws.height-(375+ip5OffSet)*sd.scaleFactorY);
        [mainMenuSprite addChild:leaderBtn];
        
        removAdBtn = [self createButtonWithFile:@"buttonNoAds_up.png" sel:@selector(removAdBtnHandler)];
        removAdBtn.position = ccp(ws.width/2-ws.width/3.5,ws.height-25*sd.scaleFactorY);
        [mainMenuSprite addChild:removAdBtn];
        
        restoreBtn = [self createButtonWithFile:@"buttonRestore_up.png" sel:@selector(restorBtnHandler)];
        restoreBtn.position = ccp(ws.width/2+ws.width/3.5,ws.height-25*sd.scaleFactorY);
        [mainMenuSprite addChild:restoreBtn];

        // IN GAME
        inGame=[[CCSprite alloc]init];
        inGame.position=ccp(0,ws.height);
        CCSprite *IGBG=[[CCSprite alloc]initWithFile:@"inGameBG2.png"];
        IGBG.anchorPoint=ccp(0,1);
        
        if ( ws.height == 1024 && [UIScreen mainScreen].scale == 1)
        {
            IGBG.scaleX = 1.2;
            IGBG.scaleY = sd.imgScaleFactorY;
        }
        
         
        gemsCMC=[[CCSprite alloc]init];
        gemsCMC.position=ccp(gemWid/2+2+1,-70*sd.scaleFactorY);
        [inGame addChild:gemsCMC];
        [inGame addChild:IGBG z:-1];
        

        inGame.visible=NO;
        [self addChild:inGame];
        
        // QUIT GAME
        backBtn=[self createButtonWithFile:@"backBtn.png" sel:@selector(backHandler)];
         backBtn.position=ccp(ws.width-40*sd.scaleFactorX,-20*sd.scaleFactorY); //// 74
        [inGame addChild:backBtn];
        
        // Current Score
        scoreTextTTF = [CCLabelTTF labelWithString:@"99999999999" fontName:FONT_NAME fontSize:25.0*sd.scaleFactorY];
        scoreTextTTF.anchorPoint=ccp(0,0.5);
        [scoreTextTTF setString:[NSString stringWithFormat:@"0"]];
        scoreTextTTF.position=ccp(90*sd.scaleFactorX,-18*sd.scaleFactorY);  /// 74
        scoreTextTTF.color = kFontColor;
        
        if(ws.height == 1024 && [UIScreen mainScreen].scale == 2)
        {
            scoreTextTTF.position=ccp(90*sd.scaleFactorX,-18*sd.scaleFactorY+15.0);
            backBtn.position=ccp(ws.width-40*sd.scaleFactorX,-20*sd.scaleFactorY+15.0);
        }
        
        
        // TIMER BAR
        timeBar=[CCSprite spriteWithFile:@"timeBar.png"];
        timeBar.anchorPoint=ccp(0,1);
        if(ws.height == 1024 && [UIScreen mainScreen].scale == 1)
        {
            timeBar.position=ccp(0,-40*(sd.scaleFactorY-sd.imgScaleFactorY/2.9));  // 90
            timeBar.scaleX= sd.scaleFactorX*640/10;
        }
        else if(ws.height == 1024 && [UIScreen mainScreen].scale == 2)
        {
            timeBar.position=ccp(0,-40*(sd.scaleFactorY-sd.imgScaleFactorY/1.4));
            timeBar.scaleX= sd.scaleFactorX* 640/10;
        }
        else
        {
            timeBar.position=ccp(0,-40);  // 90
            timeBar.scaleX=640/10;
        }
        
        
        [inGame addChild:timeBar];
        
        [inGame addChild:scoreTextTTF];
        
        
        [self addSingleTouch];
        
        // GAME OVER
        gameOver=[[CCSprite alloc]init];
        
        CCSprite *gameOverBG=[CCSprite spriteWithFile:@"gameOver.png"];
        gameOverBG.anchorPoint=ccp(0,1);
        
        if(ws.height == 1024 && [UIScreen mainScreen].scale == 1)
        {
            gameOverBG.scaleX = 1.2;
            gameOverBG.scaleY  =sd.imgScaleFactorY;
        }
        
        [gameOver addChild:gameOverBG];
        
        gameOver.position=ccp(0,ws.height);
        
        [self addChild:gameOver];
        
        // FINAL SCORE
        scoreTextTTF2 = [CCLabelTTF labelWithString:@"99999999999" fontName:FONT_NAME fontSize:35.0*sd.scaleFactorY];
        scoreTextTTF2.anchorPoint=ccp(0.5,0.5);
        scoreTextTTF2.scale=1.5;
        scoreTextTTF2.color = kFontColor;
        [scoreTextTTF2 setString:[NSString stringWithFormat:@"000000000"]];
        
        if(ws.height == 1024 && [UIScreen mainScreen].scale == 1)
        {
            scoreTextTTF2.position=ccp(ws.width/2 ,-185*sd.scaleFactorY+60.0);
        }
        else if(ws.height == 1024 && [UIScreen mainScreen].scale == 2)
        {
            scoreTextTTF2.position=ccp(ws.width/2 ,-185*sd.scaleFactorY);
        }
        else
        {
            scoreTextTTF2.position=ccp(ws.width/2 ,-185);
        }

        
        [gameOver addChild:scoreTextTTF2];
        gameOver.visible=NO;
        
        // Revmob FREE GAME ad button
        freeBtn = [self createButtonWithFile:@"freeBtn.png" sel:@selector(freeBtnHandler)];
        freeBtn.position = ccp(ws.width/2,-340*sd.scaleFactorY);
        [gameOver addChild:freeBtn];

        // Done or Next or exit Button
        okBtn=[self createButtonWithFile:@"okBtn.png" sel:@selector(okHandler)];
        okBtn.position=ccp(ws.width/2,-400*sd.scaleFactorY);
        [gameOver addChild:okBtn];
        
        // Chartboost More Games
        moreGamesBtnGameOver  = [self createButtonWithFile:@"moreAppsBtn.png" sel:@selector(moreAppsBtnHandler)];
        moreGamesBtnGameOver.position=ccp(ws.width/2,-280*sd.scaleFactorY);
        [gameOver addChild:moreGamesBtnGameOver];
        
    
	}
	return self;
}

-(void) backHandler{
// Show a chartboost ad
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"removeAd"])
    {
        [[Chartboost sharedChartboost] showInterstitial];
        [[Chartboost sharedChartboost] cacheInterstitial];
    }
    
    // [self hideBanner];
    [self unschedule:@selector(loop)];
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu.mp3" loop:YES];

    
    if (gameOver.visible==NO) {
        inGame.visible=NO;
        mainMenuSprite.visible=YES;
    }
}

-(void) okHandler{
    // This is where I want to hook up Mopub
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"removeAd"])
    {
        [[Chartboost sharedChartboost] showInterstitial];
        [[Chartboost sharedChartboost] cacheInterstitial];
    }
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu.mp3" loop:YES];

    
    gameOver.visible=NO;
    [self removeGame];
    inGame.visible=NO;
    mainMenuSprite.visible=YES;
}

-(void) removeGame{
    if (!gameIsOver) {
        [self unschedule:@selector(loop)];
    }
    [gemsCMC removeAllChildrenWithCleanup:YES];
    gem2DArr = [[NSMutableArray alloc]init];
    for (int j=0; j<vNum; j++) {
        NSMutableArray *hArr=[[NSMutableArray alloc]init];
        for (int i=0; i<hNum; i++) {
            [hArr addObject:@"em"];
        }
        [gem2DArr addObject:hArr];
    }
}

// Game Logic ?
-(Gem*) getAGemAvoidComboWithHID:(int)_hID vID:(int)_vID{
    Gem *gem;
   //NSMutableArray *allArr=[[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil];
    NSMutableArray *debarArr=[[NSMutableArray alloc]init];
    //left 
    
    int count=0;
    int toCheckID=_hID-1;
    
    
    NSString *memoryType;
    if(toCheckID>=0){
        memoryType=((Gem*)[[gem2DArr objectAtIndex:_vID] objectAtIndex:toCheckID])->type;

    }
    else{
        memoryType=@"no";
        
    }
    
    
    BOOL hasCombo=YES;
    while (count!=2&&toCheckID>=0) {
        
    
    if(memoryType!=((Gem*)[[gem2DArr objectAtIndex:_vID] objectAtIndex:toCheckID])->type){
         hasCombo=NO;
    }
        toCheckID--;
        count++;
    }
    
    if(hasCombo&&![memoryType isEqualToString:@"no"]){
        [debarArr addObject:memoryType];
    }
   
    
    //top
    
    count=0;
    toCheckID=_vID-1;
    if(toCheckID>=0){
        memoryType=((Gem*)[[gem2DArr objectAtIndex:toCheckID] objectAtIndex:_hID])->type;
    }
    else{
        memoryType=@"no";
    }
    hasCombo=YES;
    while (count!=2&&toCheckID>=0) {
        
        if(memoryType!=((Gem*)[[gem2DArr objectAtIndex:toCheckID] objectAtIndex:_hID])->type){
            hasCombo=NO;
        }
        toCheckID--;
        count++;
    }
    
    if(hasCombo&&![memoryType isEqualToString:@"no"]){
        if (debarArr.count&&[debarArr objectAtIndex:0]!=memoryType) {
             [debarArr addObject:memoryType];
        }
        else{
            [debarArr addObject:memoryType];
        }
    
    }
    
    
    gem=[self createGemDifferentFromArray:debarArr];
    

    return gem;
}

-(CCMenu*) createButtonWithFile:(NSString*)fileName sel:(SEL)_sel{
    CCSprite *selectedBtn=[CCSprite spriteWithFile:fileName];
    selectedBtn.position=ccp(1,-1);
    return [CCMenu menuWithItems:[CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:fileName] selectedSprite:selectedBtn target:self selector:_sel], nil];
}

-(Gem*)getGemAtStagePointWithPoint:(CGPoint)p{

    for (int j=0; j<gem2DArr.count; j++) {
        NSMutableArray *arr=[gem2DArr objectAtIndex:j];
        
        for (int i=0; i<arr.count; i++) {
            Gem *gem=[arr objectAtIndex:i];
            
            
            float gw=gemWid/2;
            float gh=gemWid/2;
            
            float _x=gem.position.x+gem.parent.position.x+gem.parent.parent.position.x;
            float _y=gem.position.y+gem.parent.position.y+gem.parent.parent.position.y-gw*2;
            
            gem->gx=_x;
            gem->gy=_y;
            CGRect rect=CGRectMake(_x-gw, _y+gh, gemWid, gemWid);
            if (CGRectContainsPoint(rect, p)){
                return gem;
            }
        }
    }
    
    return nil;
}

-(NSMutableArray*) tryRemove{
    if(gameIsOver){
        return [[NSMutableArray alloc]init];
    }
    //reset
    for (int _j=0; _j<gem2DArr.count; _j++) {
        NSMutableArray *_lineArr=[gem2DArr objectAtIndex:_j];
        for (int _i=0; _i<_lineArr.count; _i++) {
            Gem *_gem=((Gem*)[_lineArr objectAtIndex:_i]);
            _gem->checked=NO;
            _gem->addedToTheRemoveList=NO;
            _gem->hasToMove=NO;
            _gem->memoryIndexV=_gem->indexV;
        }
    }
    
    // then  check
    
    NSMutableArray *toRemoveArr=[[NSMutableArray alloc]init];
    
    for (int j=0; j<gem2DArr.count; j++) {
        NSMutableArray *lineArr=[gem2DArr objectAtIndex:j];
        
        for (int i=0; i<lineArr.count; i++) {
            Gem *gem=[lineArr objectAtIndex:i];
            
            if(gem->checked){
                continue;
            }
            
            //left
            NSString *theType = gem->type;
            int toCheckID=i-1;
            BOOL same = YES;
            NSMutableArray *listArr=[[NSMutableArray alloc]init];
            
            [listArr addObject:gem];
            
            while (toCheckID>=0&&same) {
                if ([theType isEqualToString:((Gem*)[lineArr objectAtIndex:toCheckID])->type]) {
                    [listArr addObject:gem];
                    
                }
                else{
                    same = NO;
                }
                toCheckID--;
            }
            //right
            same = YES;
            toCheckID=i+1;
            while (toCheckID<lineArr.count&&same) {
                if ([theType isEqualToString:((Gem*)[lineArr objectAtIndex:toCheckID])->type]) {
                    [listArr addObject:gem];
                    
                }
                else{
                    same = NO;
                }
                toCheckID++;
            }
            
            if (listArr.count>=3) {
                for (int k=0; k<listArr.count; k++) {
                    Gem *theGem=((Gem*)[listArr objectAtIndex:k]);
                    if (theGem->addedToTheRemoveList==NO) {
                        [toRemoveArr addObject:theGem];
                        theGem->addedToTheRemoveList=YES;
                    }
                }
            }
            else{
                [listArr removeAllObjects];
                [listArr addObject:gem];
            }
            
            int listArrMemoryCount=listArr.count;
            
            
            //top
            int sameNum=0;
            same = YES;
            toCheckID=j-1;
            
            while (toCheckID>=0&&same) {
                if ([theType isEqualToString:((Gem*)[[gem2DArr objectAtIndex:toCheckID]objectAtIndex:i])->type]) {
                    [listArr addObject:gem];
                    sameNum++;
                    
                }
                else{
                    same = NO;
                }
                
                toCheckID--;
            }
            
            //bottom
    
            same = YES;
            toCheckID=j+1;
            while (toCheckID<gem2DArr.count&&same) {
                if ([theType isEqualToString:((Gem*)[[gem2DArr objectAtIndex:toCheckID]objectAtIndex:i])->type]) {
                    [listArr addObject:gem];
                    sameNum++;
                }
                else{
                    same = NO;
                }
                toCheckID++;
            }
            
            
            if (listArr.count>=3&&sameNum>=2) {
                for (int k=listArrMemoryCount; k<listArr.count; k++) {
                    Gem *theGem=((Gem*)[listArr objectAtIndex:k]);
                    if (theGem->addedToTheRemoveList==NO) {
                        [toRemoveArr addObject:theGem];
                        theGem->addedToTheRemoveList=YES;
                    }
                }
            }
            
        }
    }
    
    return toRemoveArr;
}

-(void) addNewGemsToTheTop{
    if(gameIsOver){
        return;
    }
    for (int j=0; j<gem2DArr.count; j++) {
        NSMutableArray *lineArr=[gem2DArr objectAtIndex:j];
        
        for (int i=0; i<lineArr.count; i++) {
            
            if (![[lineArr objectAtIndex:i] isKindOfClass:[Gem class]]) {
                
                int currentH=i;
                int currentV=j;
                
                for (int k=currentV-1; k>=0; k--)
                {
                    if([[[gem2DArr objectAtIndex:k]objectAtIndex:currentH]isKindOfClass:[Gem class]])
                    {
                        Gem *gemTop=[[gem2DArr objectAtIndex:k]objectAtIndex:currentH];
                        gemTop->indexV++;
                        gemTop->hasToMove=YES;
                        
                    }
                }
                
            }
            
        }
    }
    
    NSMutableArray *positionChangedGemsArr=[[NSMutableArray alloc]init];
    for (int _j=0; _j<gem2DArr.count; _j++) {
        NSMutableArray *lineArr=[gem2DArr objectAtIndex:_j];
        
        for (int _i=0; _i<lineArr.count; _i++) {
        
            if ([[lineArr objectAtIndex:_i] isKindOfClass:[Gem class]]) {
                
                Gem *gem=[lineArr objectAtIndex:_i];
                if (gem->hasToMove) {
                    CCCallFunc *cccf;
                    CCSequence *seq;
                    id move=[CCMoveTo actionWithDuration:0.6 position:ccp(gem.position.x,-gem->indexV*gemWid)];
                    id moveXEase=[CCEaseBounceOut actionWithAction:move];
                    cccf=[CCCallFunc actionWithTarget:self selector:@selector(moveDownGemsFinishedHandler)];
                    seq=[CCSequence actions:moveXEase,cccf,nil];
                    [gem runAction:seq];
                    [positionChangedGemsArr addObject:gem];
                    //[[gem2DArr objectAtIndex:gem->indexV] setObject:gem atIndexedSubscript:gem->indexH];
                }
            }
            
            else{
                
            }
        }
    }
    
    
    //Resetting the whereabouts of the gems to make the array corresponds to
    for (int _k=0; _k<positionChangedGemsArr.count; _k++) {
        Gem *__gem=[positionChangedGemsArr objectAtIndex:_k];
                 
        [[gem2DArr objectAtIndex:__gem->memoryIndexV] setObject:@"empty" atIndexedSubscript:__gem->indexH];
    }
    
    for (int _k=0; _k<positionChangedGemsArr.count; _k++) {
        Gem *__gem=[positionChangedGemsArr objectAtIndex:_k];
        [[gem2DArr objectAtIndex:__gem->indexV] setObject:__gem atIndexedSubscript:__gem->indexH];
        
        
    }
    
    
    BOOL handlerAdded=NO;
    
    
    //Create a new gem
    
    NSMutableArray *newGemsCreatedArr=[[NSMutableArray alloc]init];
    
    for (int __j=0; __j<gem2DArr.count; __j++) {
        
        
        NSMutableArray *lineArr=[gem2DArr objectAtIndex:__j];
        
        for (int __i=0; __i<lineArr.count; __i++) {
            if (![[lineArr objectAtIndex:__i] isKindOfClass:[Gem class]]) {
                CCCallFunc *cccfNew;
                CCSequence *seqNew;
                Gem *newGem=[self createGemDifferentFromArray:[[NSMutableArray alloc]init]];
                newGem->indexH=__i;
                newGem->indexV=__j;
                newGem.position=ccp(newGem->indexH*gemWid,-newGem->indexV*gemWid+gemWid*4);
                [gemsCMC addChild:newGem];
                
                id moveNew=[CCMoveTo actionWithDuration:0.6 position:ccp(newGem.position.x,-newGem->indexV*gemWid)];
                id moveXEaseNew=[CCEaseBounceOut actionWithAction:moveNew];
                
                if(!handlerAdded){
                    cccfNew=[CCCallFunc actionWithTarget:self selector:@selector(newCreatedGemsMoveDownFinishedHandler)];
                    seqNew=[CCSequence actions:moveXEaseNew,cccfNew,nil];
                    handlerAdded=YES;
                }
                else{
                    seqNew=[CCSequence actions:moveXEaseNew,nil];
                }
                
                [newGem runAction:seqNew];
                
                [newGemsCreatedArr addObject:newGem];
            }
            
            
        }
    }
    
    //Resetting the whereabouts of the gems to make the array corresponds to
    for (int _k=0; _k<newGemsCreatedArr.count; _k++) {
        Gem *__gem=[newGemsCreatedArr objectAtIndex:_k];
        [[gem2DArr objectAtIndex:__gem->indexV] setObject:__gem atIndexedSubscript:__gem->indexH];
        
        
    }
    
    gemToBeExchanged=nil;
    gemMoved=nil;
    
    
}

-(void) moveDownGemsFinishedHandler{
    
}

-(void) newCreatedGemsMoveDownFinishedHandler{
    
    gemToBeExchanged=nil;
    gemMoved=nil;
    moveAble = YES;
    return;
    if(gameIsOver){
        return;
    }
    ___toRemoveArr=[self tryRemove];
    if (___toRemoveArr.count>0) {
        score+=___toRemoveArr.count*10;
        [scoreTextTTF setString:[NSString stringWithFormat:@"%i",score]];
        
            for (int i=0; i<___toRemoveArr.count; i++) {
                Gem *gem=[___toRemoveArr objectAtIndex:i];
                
                // Points gained text
                CCLabelTTF * scoreVisual = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",10] fontName:FONT_NAME fontSize:30*sd.scaleFactorY];
                [scoreVisual setPosition:gem.position];
                scoreVisual.color = kFontColor;
                [gemsCMC addChild:scoreVisual z:10];
                id fadein = [CCFadeOut actionWithDuration:.5];
                
                id actionRemove =  [CCCallFuncND  actionWithTarget: self
                                                         selector : @selector(removeVisualLabel : data:)
                                                              data:scoreVisual];
                [scoreVisual runAction:[CCSequence actions:fadein,actionRemove, nil]];
                
                
                id scaleXY=[CCScaleTo actionWithDuration:0.2 scale:0];
                id moveXEase=[CCEaseExponentialOut actionWithAction:scaleXY];
                CCCallFunc *cccf;
                CCSequence *seq;
                if (i==0)
                {
                    cccf=[CCCallFunc actionWithTarget:self selector:@selector(removeGemFinishedHandler)];
                    seq=[CCSequence actions:moveXEase,cccf,nil];
                }
                else{
                    seq=[CCSequence actions:moveXEase,nil];
                }
                [((NSMutableArray*)[gem2DArr objectAtIndex:gem->indexV]) setObject:@"empty" atIndexedSubscript:gem->indexH];
                [gem runAction:seq];
            }
        
    }
    else{
        [self addSingleTouch];
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
   
    if(gameIsOver){
        return YES;
    }
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint point = CGPointMake(location.x, location.y);
    if(moveAble&&!gameIsOver){
        memoryTouchedGem=[self getGemAtStagePointWithPoint:point];
        NSString * selectedState = [NSString stringWithFormat:@"gem%@b.png",memoryTouchedGem->type];
        CCSprite * newImg = [CCSprite spriteWithFile:selectedState];
        [memoryTouchedGem->img setTexture:[newImg texture]];
        arrayOfGemsToRemove = [[NSMutableArray alloc] init];
        arrayOfLines = [[NSMutableArray alloc] init];
//        NSLog(@"touch pos =  %f %f     gem pos   %f %f ",point.x,point.y,memoryTouchedGem.position.x,memoryTouchedGem.position.y);
        positionOfLastGemInLine = memoryTouchedGem.position;
    }
        
  
    return YES;
  
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if(gameIsOver){
        return;
    }
    if (memoryTouchedGem!=nil)
    {
        NSString * selectedState = [NSString stringWithFormat:@"gem%@.png",memoryTouchedGem->type];
        CCSprite * newImg = [CCSprite spriteWithFile:selectedState];
        [memoryTouchedGem->img setTexture:[newImg texture]];
        memoryTouchedGem=nil;
    }
    
    if(arrayOfGemsToRemove)
    {
        //reset
        for (int _j=0; _j<gem2DArr.count; _j++) {
            NSMutableArray *_lineArr=[gem2DArr objectAtIndex:_j];
            for (int _i=0; _i<_lineArr.count; _i++) {
                Gem *_gem=((Gem*)[_lineArr objectAtIndex:_i]);
                _gem->checked=NO;
                _gem->addedToTheRemoveList=NO;
                _gem->hasToMove=NO;
                _gem->checkedInLine = NO;
                _gem->memoryIndexV=_gem->indexV;
            }
        }

        if (arrayOfGemsToRemove.count>2) {
            score+=arrayOfGemsToRemove.count*10;
            
            // Points text again???
            [scoreTextTTF setString:[NSString stringWithFormat:@"%i",score]];
            for (int i=0; i<arrayOfGemsToRemove.count; i++) {
                Gem *gem=[arrayOfGemsToRemove objectAtIndex:i];
                
                CCLabelTTF * scoreVisual = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",10] fontName:FONT_NAME fontSize:25*sd.scaleFactorY];
                [scoreVisual setPosition:gem.position];
                scoreVisual.color = kFontColor;
                [gemsCMC addChild:scoreVisual z:10];
                id fadein = [CCFadeOut actionWithDuration:.5];
                
                id actionRemove =  [CCCallFuncND  actionWithTarget: self
                                                         selector : @selector(removeVisualLabel : data:)
                                                              data:scoreVisual];
                [scoreVisual runAction:[CCSequence actions:fadein,actionRemove, nil]];

                
                id scaleXY=[CCScaleTo actionWithDuration:0.2 scale:0];
                id moveXEase=[CCEaseExponentialOut actionWithAction:scaleXY];
                CCCallFunc *cccf;
                CCSequence *seq;
                if (i == arrayOfGemsToRemove.count-1)
                {
                    cccf=[CCCallFunc actionWithTarget:self selector:@selector(removeGemFinishedHandler)];
                    seq=[CCSequence actions:moveXEase,cccf,nil];
                }
                else{
                    seq=[CCSequence actions:moveXEase,nil];
                }
                
                [((NSMutableArray*)[gem2DArr objectAtIndex:gem->indexV]) setObject:@"empty" atIndexedSubscript:gem->indexH];
                
                [gem runAction:seq];
            }
            
            
            
        }
        else
        {
            for (int i=0; i<arrayOfGemsToRemove.count; i++)
            {
                Gem *gem=[arrayOfGemsToRemove objectAtIndex:i];
                NSString * selectedState = [NSString stringWithFormat:@"gem%@.png",gem->type];
                CCSprite * newImg = [CCSprite spriteWithFile:selectedState];
                [gem->img setTexture:[newImg texture]];
                if(i<arrayOfGemsToRemove.count-1)
                {
                    CCSprite * line = [arrayOfLines objectAtIndex:i];
                    [gemsCMC removeChild:line cleanup:YES];
                }
            }
            [arrayOfLines release];
            [arrayOfGemsToRemove release];
            arrayOfGemsToRemove = nil;
            arrayOfLines  =nil;
            moveAble=YES;
        }

        
    }
    
}




-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    if(gameIsOver){
        return;
    }
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint point = CGPointMake(location.x, location.y);
    
    if(memoryTouchedGem)
    {
        {
            Gem *gem;
            {
                gem=[self getGemAtStagePointWithPoint:CGPointMake(point.x, point.y)];
            }
            
            if (gem!=nil) {
                           
            
            gemMoved=memoryTouchedGem;
            gemToBeExchanged=gem;
                
            if(gemMoved->type == gemToBeExchanged->type)
            {
                if (arrayOfGemsToRemove.count == 0)
                {
                    [arrayOfGemsToRemove addObject:gemMoved];
                    gemMoved->checkedInLine = YES;
                }
                
                    if(((int)(gemToBeExchanged.position.x) == (int)(positionOfLastGemInLine.x+gemWid) && (int)(gemToBeExchanged.position.y) == (int)(positionOfLastGemInLine.y)) ||
                       ((int)(gemToBeExchanged.position.x) == (int)(positionOfLastGemInLine.x-gemWid) && (int)(gemToBeExchanged.position.y) == (int)(positionOfLastGemInLine.y)) ||
                       ((int)(gemToBeExchanged.position.x) == (int)(positionOfLastGemInLine.x) && (int)(gemToBeExchanged.position.y) == (int)(positionOfLastGemInLine.y+gemWid)) ||
                       ((int)(gemToBeExchanged.position.x) == (int)(positionOfLastGemInLine.x) && (int)(gemToBeExchanged.position.y) == (int)(positionOfLastGemInLine.y-gemWid)) ||
                       ((int)(gemToBeExchanged.position.x) == (int)(positionOfLastGemInLine.x+gemWid) && (int)(gemToBeExchanged.position.y) == (int)(positionOfLastGemInLine.y+gemWid)) ||
                       ((int)(gemToBeExchanged.position.x) == (int)(positionOfLastGemInLine.x+gemWid) && (int)(gemToBeExchanged.position.y) == (int)(positionOfLastGemInLine.y-gemWid))||
                       ((int)(gemToBeExchanged.position.x) == (int)(positionOfLastGemInLine.x-gemWid) && (int)(gemToBeExchanged.position.y) == (int)(positionOfLastGemInLine.y+gemWid)) ||
                       (((int)gemToBeExchanged.position.x) == (int)(positionOfLastGemInLine.x-gemWid) && (int)(gemToBeExchanged.position.y) == (int)(positionOfLastGemInLine.y-gemWid))
                       
                       )
                    {
                        if(! gemToBeExchanged->checkedInLine)
                        {
                            NSString * selectedState = [NSString stringWithFormat:@"gem%@b.png",gemToBeExchanged->type];
                            CCSprite * newImg = [CCSprite spriteWithFile:selectedState];
                            [gemToBeExchanged->img setTexture:[newImg texture]];
                            
                            if(![arrayOfGemsToRemove containsObject:gemToBeExchanged])
                            {
                                [arrayOfGemsToRemove addObject:gemToBeExchanged];
                                Gem * previousGem = (Gem*)[arrayOfGemsToRemove objectAtIndex:arrayOfGemsToRemove.count-2];
                                CGPoint a = gemToBeExchanged.position;
                                CGPoint b = previousGem.position;
                                CGPoint diff = ccpSub(a, b);
                                float rads = atan2f( diff.y, diff.x);
                                float degs = -CC_RADIANS_TO_DEGREES(rads);
                                CGRect lineRect;
                                
                                if(diff.x !=0 && diff.y!=0)
                                {
                                    lineRect = CGRectMake(0, 0, gemWid+abs(diff.x/2), 10.0*sd.scaleFactorY);
                                }
                                else
                                {
                                    lineRect = CGRectMake(0, 0, gemWid, 10.0*sd.scaleFactorY);
                                }
                                
                                CCSprite *line = [CCSprite spriteWithFile:@"line.png" rect:lineRect];
                                [line setAnchorPoint:ccp(0.0f, 0.5f)];
                                [line setPosition:b];
                                [line setRotation: degs];
                                [gemsCMC addChild:line z:-1];
                                [arrayOfLines addObject:line];
                            }
                            positionOfLastGemInLine = gemToBeExchanged.position;
                            gemToBeExchanged->checkedInLine = YES;
                        }
                        
                    }
                    
                
                
                
                if(arrayOfGemsToRemove.count > 2)
                {
                    CGPoint positionofSecondLastGem = ((Gem*)[arrayOfGemsToRemove objectAtIndex:arrayOfGemsToRemove.count-2]).position;
                    if(gemToBeExchanged.position.x == positionofSecondLastGem.x && gemToBeExchanged.position.y == positionofSecondLastGem.y)
                    {
                        Gem * gem = (Gem*)[arrayOfGemsToRemove objectAtIndex:arrayOfGemsToRemove.count-1];
                        NSString * selectedState = [NSString stringWithFormat:@"gem%@.png",gem->type];
                        CCSprite * newImg = [CCSprite spriteWithFile:selectedState];
                        [gem->img setTexture:[newImg texture]];
                        gem->checkedInLine = NO;
                        [arrayOfGemsToRemove removeObjectAtIndex:arrayOfGemsToRemove.count-1];
                        positionOfLastGemInLine = gemToBeExchanged.position;
                        CCSprite * line = [arrayOfLines objectAtIndex:arrayOfLines.count-1];
                        [gemsCMC removeChild:line cleanup:YES];
                        [arrayOfLines removeObjectAtIndex:arrayOfLines.count-1];
                    }
                }
            }
    

            [self removeSingleTouch];
                
                
            }
    
        }
    }
    
   

}

-(void) addSingleTouch{
    moveAble=YES;
    closeAble=YES;
    //[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}
-(void) removeSingleTouch{
    closeAble=NO;
    moveAble=NO;
    //[[[CCDirector sharedDirector] touchDispatcher] removeAllDelegates];
}

-(void) exChangeFinishedHandler{
    if(gameIsOver){
        return;
    }
    ___toRemoveArr=[self tryRemove];
    if (___toRemoveArr.count>0) {
        score+=___toRemoveArr.count*10;
        
        // Points Code again???
        [scoreTextTTF setString:[NSString stringWithFormat:@"%i",score]];
        for (int i=0; i<___toRemoveArr.count; i++) {
            Gem *gem=[___toRemoveArr objectAtIndex:i];
            
            CCLabelTTF * scoreVisual = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",10] fontName:FONT_NAME fontSize:25*sd.scaleFactorY];
            [scoreVisual setPosition:gem.position];
            scoreVisual.color = kFontColor;
            [gemsCMC addChild:scoreVisual z:10];
            id fadein = [CCFadeOut actionWithDuration:.5];
            
            id actionRemove =  [CCCallFuncND  actionWithTarget: self
                                                       selector : @selector(removeVisualLabel : data:)
                                                            data:scoreVisual];
            [scoreVisual runAction:[CCSequence actions:fadein,actionRemove, nil]];

            
            id scaleXY=[CCScaleTo actionWithDuration:0.2 scale:0];
            id moveXEase=[CCEaseExponentialOut actionWithAction:scaleXY];
            CCCallFunc *cccf;
            CCSequence *seq;
            if (i==0) {
                cccf=[CCCallFunc actionWithTarget:self selector:@selector(removeGemFinishedHandler)];
                seq=[CCSequence actions:moveXEase,cccf,nil];
            }
            else{
                seq=[CCSequence actions:moveXEase,nil];
            }
            
            [((NSMutableArray*)[gem2DArr objectAtIndex:gem->indexV]) setObject:@"empty" atIndexedSubscript:gem->indexH];
            
            [gem runAction:seq];
        }
        
        
       
    }
    else{
        //Reset the gems
        id moveX=[CCMoveTo actionWithDuration:0.4 position:ccp(gemToBeExchanged.position.x,gemToBeExchanged.position.y)];
        id moveXEase=[CCEaseExponentialOut actionWithAction:moveX];
        CCCallFunc *cccf=[CCCallFunc actionWithTarget:self selector:@selector(fw_exChangeFinishedHandler)];
        CCSequence *seq=[CCSequence actions:moveXEase,cccf,nil];
        
        
        id moveX2=[CCMoveTo actionWithDuration:0.4 position:ccp(gemMoved.position.x,gemMoved.position.y)];
        id moveXEase2=[CCEaseExponentialOut actionWithAction:moveX2];
        CCCallFunc *cccf2=[CCCallFunc actionWithTarget:self selector:@selector(fw_exChangeFinishedHandler2)];
        CCSequence *seq2=[CCSequence actions:moveXEase2,cccf2,nil];
        [[SimpleAudioEngine sharedEngine] playEffect:@"error.mp3"];
        [gemMoved runAction:seq];
        [gemToBeExchanged runAction:seq2];
        
    }
}

-(void) removeGemFinishedHandler{
    if(gameIsOver){
        return;
    }
    for (int i=0; i<arrayOfGemsToRemove.count; i++)
    {
        Gem *gem=[arrayOfGemsToRemove objectAtIndex:i];
        if(i<arrayOfGemsToRemove.count-1)
        {
            CCSprite * line = [arrayOfLines objectAtIndex:i];
            [gemsCMC removeChild:line cleanup:YES];
        }
        [gem.parent removeChild:gem cleanup:YES];
    }
    [arrayOfGemsToRemove release];
    arrayOfGemsToRemove = nil;
    [arrayOfLines release];
    arrayOfLines = nil;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"clear.mp3"];
    [self addNewGemsToTheTop];
}

//Reset is complete
-(void) fw_exChangeFinishedHandler{
    if(gameIsOver){
        return;
    }
    NSMutableArray *hArr=[gem2DArr objectAtIndex:gemToBeExchanged->indexV];
    
    [hArr setObject:gemMoved atIndexedSubscript:gemToBeExchanged->indexH];
    
    NSMutableArray *hArr2=[gem2DArr objectAtIndex:gemMoved->indexV];
    
    [hArr2 setObject:gemToBeExchanged atIndexedSubscript:gemMoved->indexH];
    
    int tempGemMovedIndexH=gemMoved->indexH;
    int tempGemMovedIndexV=gemMoved->indexV;
    
    int tempGemToBeExchangedIndexH=gemToBeExchanged->indexH;
    int tempGemToBeExchangedIndexV=gemToBeExchanged->indexV;
    
    gemMoved->indexH=tempGemToBeExchangedIndexH;
    gemMoved->indexV=tempGemToBeExchangedIndexV;
    
    gemToBeExchanged->indexH=tempGemMovedIndexH;
    gemToBeExchanged->indexV=tempGemMovedIndexV;
    
    
    gemToBeExchanged=nil;
    gemMoved=nil;
    
    [self addSingleTouch];
}


-(void) fw_exChangeFinishedHandler2{}
-(void) exChangeFinishedHandler2{}


// TIME REMAINING PROGRESS BAR
-(void)loop{
    time-=1;
    
   if(ws.height == 1024 && [UIScreen mainScreen].scale == 2)
    {
    timeBar.scaleX= sd.scaleFactorX* 64.0f*(time/gameTime);
    }
   else if(ws.height == 1024 && [UIScreen mainScreen].scale == 1)
   {
       timeBar.scaleX= sd.scaleFactorX/2* 64.0f*(time/gameTime);
   }
    else
    {
        timeBar.scaleX= 64.0f*(time/gameTime);
    }
    
    if (time<=0) {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.mp3"];
        NSString *category =[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".leaderboard"];
        GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
        scoreReporter.value = score;
        
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
                NSLog(@"Submitting score error: %@", [error description]);
            }
            else {
                NSLog(@"Submitting score success");
            }
            
        }];
        if ([Nextpeer isCurrentlyInTournament]) {
            
            [Nextpeer reportControlledTournamentOverWithScore:score];
        }

        
        
        gameIsOver=YES;
        
        gameOver.visible=YES;
        
        [scoreTextTTF2 setString:[NSString stringWithFormat:@"%i",score]];
        
        [self unschedule:_cmd];
    }
    
}



-(void) createGameWithHNum:(int)_hNum _vNum:(int)_vNum{
    
    [self removeGame];
    
    gameIsOver=NO;
    moveAble=YES;
    time=gameTime;
    
    score=0;
    
    [scoreTextTTF setString:[NSString stringWithFormat:@"%i",score]];
    
    [self schedule:@selector(loop) interval:1/60.0];
    
    for (int j=0; j<_vNum; j++) {
        for (int i=0; i<_hNum; i++) {
            Gem *gem=[self getAGemAvoidComboWithHID:i vID:j];
            gem.position=ccp(i*gemWid,-j*gemWid);
            
            gem->indexH=i;
            gem->indexV=j;
            
            [gemsCMC addChild:gem];
            
            NSMutableArray *arr=[gem2DArr objectAtIndex:j];
            

            [arr setObject:gem atIndexedSubscript:i];
            
        }
        
    }
    
}

-(Gem*) createGemDifferentFromArray:(NSMutableArray *)diffArr{
    NSMutableArray *allArr=[[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
    for (int i=0; i<diffArr.count; i++) {
        [allArr removeObject:[diffArr objectAtIndex:i]];
    }
    
    int rn=arc4random()%allArr.count;
    NSString *str=[allArr objectAtIndex:rn];
    CCSprite *gemSprite= [[CCSprite alloc]initWithFile:[NSString stringWithFormat:@"gem%@.png",str]];
    Gem *gem=[[Gem alloc]init];
    gem->type=str;
    gem->img=gemSprite;
    [gem addChild:gemSprite];
    return gem;
}
    
 
-(void)startBtnHandler{
    /* Hide this applovin banner ad for now
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"removeAd"])
    {
        [self showBanner];
    }
*/
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"gameplay.mp3" loop:YES];
    
    [self createGameWithHNum:hNum _vNum:vNum];
    mainMenuSprite.visible=NO;
    inGame.visible=YES;
    gameOver.visible=NO;
    self.isTouchEnabled=YES;
    
    if(!touchTargetAdded){
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
        touchTargetAdded=YES;
    }
}

-(void) moreAppsBtnHandler{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    [[Chartboost sharedChartboost] showMoreApps];

}

-(void) multiplayerUnlocked{
    
    CCArray * a = [multiPlayerBtn children];
    CCMenuItemSprite * b = [a objectAtIndex:0];
    
    [b setNormalImage:[CCSprite spriteWithFile:@"multiBtn.png"]];
    [b setSelectedImage:[CCSprite spriteWithFile:@"multiBtn.png"]];
    
    
}
// Nextpeer multiplayer
-(void) multiPlayerBtnHandler{
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    // Kill the locking
    /*
    if(! [[NSUserDefaults standardUserDefaults] boolForKey:@"multiplayerUnlocked"])
    {
        [AdColony playVideoAdForZone:ADCOLONY_ZONE_ID withDelegate:(AppController*)[[UIApplication sharedApplication] delegate] withV4VCPrePopup:YES andV4VCPostPopup:YES];
    }
    else
    { */
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"gameplay.mp3" loop:YES];
        [Nextpeer launchDashboard];
        isMultiPlayer = true;
   // }
    

}

-(void) leaderBtnHandler{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    AppController* app = (AppController*)[[UIApplication sharedApplication] delegate];
    [app showLeaderboard];
}
-(void) removAdBtnHandler{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    [[InAppManager sharedManager] addPaymentToPaymentQueueForProductKey:REMOVE_AD_ID];
}
-(void) restorBtnHandler{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    [[InAppManager sharedManager] restorePurchases];
}
-(void)  freeBtnHandler{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
    [[RevMobAds session] openAdLinkWithDelegate:nil];
}
-(void) showBanner{
    
    CGRect tempRect = [[(AppController *)[[UIApplication sharedApplication] delegate] window] bounds];
    appLovinBanner =  [[ALAdView alloc] initBannerAd];
    appLovinBanner.frame = CGRectMake( 0,  tempRect.size.height - appLovinBanner.frame.size.height,
                                      appLovinBanner.frame.size.width,
                                      appLovinBanner.frame.size.height );
    
    [[(AppController *)[[UIApplication sharedApplication] delegate] window] addSubview:appLovinBanner];
    
    [appLovinBanner loadNextAd];
}
-(void) hideBanner{
    [appLovinBanner removeFromSuperview];
    appLovinBanner = nil;
}

 -(void)removeVisualLabel : (id) sender data:(void*)aObject
{
    CCLabelTTF * toRemove = (CCLabelTTF *) aObject;
    [gemsCMC removeChild:toRemove cleanup:YES];
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}


@end