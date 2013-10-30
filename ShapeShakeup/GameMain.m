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
#define blackColor      ccc3(0,0,0);
#define blueColor       ccc3(20,140,255);
#define lightBlueColor  ccc3(98,188,255);

//// font name
#define FONT_NAME @ "Illuminate"
#define highScoreKey @"highScoreKey"


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
        
        
        //  Gameplay duration (one minute blitz)
       gameTime = 60 * 10 ;
        
        // number of rows and columns
        hNum=6;
        if (ws.height==568) {
            vNum=8;
            ip5OffSet = 50.0;
        }
        
        else{
            vNum=7;
            ip5OffSet = 0.0;
        }
        
        // size of grid unit
        gemWid=52*sd.scaleFactorX;
        
        // need to fix actual size of guys: base it off screen width?
        
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
        
        // background grass
        CCSprite *grass=[[CCSprite alloc]initWithFile:@"inGameBG.pvr.ccz"];
        grass.scale = 1.11;
        grass.position=ccp(ws.width/2 , ws.height/2);
        [mainMenuSprite addChild:grass];
        
        // blue menu background
        mainMenuBG=[[CCSprite alloc]initWithFile:@"menuBG.pvr.ccz"];
        mainMenuBG.scaleY = 1.11;
        mainMenuBG.position=ccp(ws.width/2 , ws.height/2);
        [mainMenuSprite addChild:mainMenuBG];
        
        // Lockup
        lockup=[[CCSprite alloc]initWithFile:@"lockup.png"];
        lockup.position=ccp(ws.width/2,ws.height * 0.77);
        [mainMenuSprite addChild:lockup];
        
        hsLabel = [CCLabelTTF labelWithString:@"HIGH\nSCORE"
                              dimensions:CGSizeMake (200,100)
                              hAlignment:kCCTextAlignmentLeft
                              fontName:FONT_NAME
                              fontSize:9.0 * sd.scaleFactorY ];
        hsLabel.anchorPoint = ccp(0,1);
        hsLabel.position = ccp(lockup.contentSize.width * 0.03 , lockup.contentSize.height * 0.22);
        hsLabel.color = lightBlueColor;
        [lockup addChild:hsLabel];
        
        savedHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:highScoreKey];
        
        highScoreText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",savedHighScore]
                                           fontName:FONT_NAME fontSize:32.0 * sd.scaleFactorY];
        highScoreText.anchorPoint=ccp(0.5,0.5);
        highScoreText.position=ccp(lockup.contentSize.width/2 ,lockup.contentSize.height * 0.12);
        highScoreText.color = kFontColor;
        [lockup addChild:highScoreText];
        
        // Main Menu Buttons
        
        // Play button
        startBtn=[self createButtonWithFile:@"buttonPlay_up.png" sel:@selector(startBtnHandler)];
        [mainMenuSprite addChild:startBtn];

        // Nextpeer Multiplayer
        multiPlayerBtn = [self createButtonWithFile:@"buttonMultiplay_up.png" sel:@selector(multiPlayerBtnHandler)];
        [mainMenuSprite addChild:multiPlayerBtn];
        
        // Game Center Leaderboards
        leaderBtn = [self createButtonWithFile:@"buttonLeaderboards_up.png" sel:@selector(leaderBtnHandler)];
        [mainMenuSprite addChild:leaderBtn];
        
        removAdBtn = [self createButtonWithFile:@"buttonNoAds_up.png" sel:@selector(removAdBtnHandler)];
        [mainMenuSprite addChild:removAdBtn];
        
        restoreBtn = [self createButtonWithFile:@"buttonRestore_up.png" sel:@selector(restorBtnHandler)];
        [mainMenuSprite addChild:restoreBtn];

        // position buttons
        startBtn.position=ccp(ws.width/2,ws.height * 0.5);
        multiPlayerBtn.position = ccp (ws.width/2 , startBtn.position.y - (60 * sd.scaleFactorY));
        leaderBtn.position = ccp(ws.width/2 , multiPlayerBtn.position.y - (60 * sd.scaleFactorY));
        
        // Buttons are ignoring anchorpoint >:(
        // button.contentSizes are not behaving as expected >:(
        
        if(ws.width == 768) {
            removAdBtn.position = ccp((ws.width/2) - (startBtn.contentSize.width*0.125) ,
                                       leaderBtn.position.y - (50 * sd.scaleFactorY));
            restoreBtn.position = ccp((ws.width/2) + (startBtn.contentSize.width*0.15) ,
                                       removAdBtn.position.y);
        }
        else {
            removAdBtn.position = ccp((ws.width/2) - (startBtn.contentSize.width*0.145) ,
                                      leaderBtn.position.y - (50 * sd.scaleFactorY));
            restoreBtn.position = ccp((ws.width/2) + (startBtn.contentSize.width*0.175) ,
                                      removAdBtn.position.y);
        }
            
            
        // IN GAME
        inGame=[[CCSprite alloc]init];
        inGame.position=ccp(0,ws.height);
        
        CCSprite *IGBG=[[CCSprite alloc]initWithFile:@"inGameBG.pvr.ccz"];
        IGBG.anchorPoint=ccp(0.5,1);
        IGBG.scale = 1.11;
        IGBG.position=ccp(ws.width/2,0);
        
        // game grid
        gemsCMC=[[CCSprite alloc]init];
        gemsCMC.position=ccp(gemWid/2+2+1 , -100 * sd.scaleFactorY);
        [inGame addChild:gemsCMC];
        [inGame addChild:IGBG z:-1];

        inGame.visible=NO;
        [self addChild:inGame];
        
        topBar=[CCSprite spriteWithFile:@"topBar.png"];
        topBar.anchorPoint=ccp(0,1);
        topBar.position=ccp(0,0);
        [inGame addChild:topBar];
        
        // QUIT GAME
        backBtn=[self createButtonWithFile:@"backBtn.png" sel:@selector(backHandler)];
         backBtn.position=ccp(ws.width-40*sd.scaleFactorX,-20*sd.scaleFactorY); //// 74
        [inGame addChild:backBtn];
        
        // Current Score
        scoreTextTTF = [CCLabelTTF labelWithString:@"99999999999" fontName:FONT_NAME fontSize:25.0*sd.scaleFactorY];
        scoreTextTTF.anchorPoint=ccp(0.5,0.5);
        [scoreTextTTF setString:[NSString stringWithFormat:@"0"]];
        scoreTextTTF.position=ccp(ws.width/2 , -topBar.contentSize.height * .5);
        scoreTextTTF.color = kFontColor;
        
        if(ws.height == 1024 && [UIScreen mainScreen].scale == 2)
        {
            scoreTextTTF.position=ccp(90*sd.scaleFactorX,-18*sd.scaleFactorY+15.0);
            backBtn.position=ccp(ws.width-40*sd.scaleFactorX,-20*sd.scaleFactorY+15.0);
        }
        
        
        // TIMER BAR
        // Tray
        timeBarTray=[CCSprite spriteWithFile:@"timeBarTray.png"];
        timeBarTray.anchorPoint=ccp(0,0);
        timeBarTray.position=ccp(0,-ws.height);
        if(ws.height == 1024)
        {
            timeBarTray.scale = 1.0;
        }
        else
        {
            timeBarTray.scale=1.0/1.2;
        }
        
        // Bar
        timeBar=[CCSprite spriteWithFile:@"timeBar.png"];
        timeBar.anchorPoint=ccp(0,0.5);
        timeBar.position=ccp(timeBarTray.boundingBox.size.height*0.16, -ws.height + (timeBarTray.boundingBox.size.height/2));
        timeBar.scaleX= ws.width/10;

        [inGame addChild:timeBarTray];
        
        [inGame addChild:timeBar];
        
        [inGame addChild:scoreTextTTF];
        
        
        [self addSingleTouch];
        
        // GAME OVER Dialog
        gameOver=[[CCSprite alloc]init];
        [self addChild:gameOver];
        
        // background grass
        CCSprite *grass2=[[CCSprite alloc]initWithFile:@"inGameBG.pvr.ccz"];
        grass2.scale = 1.11;
        grass2.position=ccp(ws.width/2 , ws.height/2);
        [gameOver addChild:grass2];
        
        CCSprite *gameOverBG=[CCSprite spriteWithFile:@"menuBG.pvr.ccz"];
        gameOverBG.anchorPoint=ccp(0.5,0.5);
        gameOverBG.scaleY = 1.11;
        gameOverBG.position=ccp(ws.width/2 , ws.height/2);
        [gameOver addChild:gameOverBG];
        
        
        // Was it a high score?
        newHighText = [CCLabelTTF labelWithString:@"NEW HIGH SCORE!" fontName:FONT_NAME fontSize:15.0 * sd.scaleFactorY];
        newHighText.anchorPoint=ccp(0.5,0.5);
        newHighText.color = kFontColor;
        newHighText.position=ccp(ws.width/2 ,ws.height * 0.84);
        [gameOver addChild:newHighText];
        
        // FINAL SCORE
        scoreTextTTF2 = [CCLabelTTF labelWithString:@"99999999" fontName:FONT_NAME fontSize:60.0 * sd.scaleFactorY];
        scoreTextTTF2.anchorPoint=ccp(0.5,0.5);
        scoreTextTTF2.color = blackColor;
        [scoreTextTTF2 setString:[NSString stringWithFormat:@"000000000"]]; // ? what does this do?
        scoreTextTTF2.position=ccp(ws.width/2 ,ws.height * 0.72);
        
        [gameOver addChild:scoreTextTTF2];
        gameOver.visible=NO;
        
        wellPlayedText = [CCLabelTTF labelWithString:@"Well Played!" fontName:FONT_NAME fontSize:24.0 * sd.scaleFactorY];
        wellPlayedText.anchorPoint=ccp(0.5,0.5);
        wellPlayedText.color = blueColor;
        wellPlayedText.position=ccp(ws.width/2 ,ws.height * 0.6);
        [gameOver addChild:wellPlayedText];
        
        // Start Button
        startOverBtn=[self createButtonWithFile:@"buttonPlay_up.png" sel:@selector(startBtnHandler)];
        startOverBtn.position=ccp(ws.width/2, ws.height * 0.47);
        [gameOver addChild:startOverBtn];

        // Back to Main Menu
        okBtn=[self createButtonWithFile:@"buttonMainMenu_up.png" sel:@selector(okHandler)];
        okBtn.position=ccp(ws.width/2, ws.height * 0.36);
        [gameOver addChild:okBtn];
        
        // Revmob FREE GAME ad button - Hiding for now
        //freeBtn = [self createButtonWithFile:@"freeBtn.png" sel:@selector(freeBtnHandler)];
        //freeBtn.position = ccp(ws.width/2,-340*sd.scaleFactorY);
        //[gameOver addChild:freeBtn];

        // Chartboost More Games - Hiding for now
        //moreGamesBtnGameOver  = [self createButtonWithFile:@"moreAppsBtn.png" sel:@selector(moreAppsBtnHandler)];
        //moreGamesBtnGameOver.position=ccp(ws.width/2,-280*sd.scaleFactorY);
        //[gameOver addChild:moreGamesBtnGameOver];
        

        

        
    
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
                    // existing guys fall down
                    id move=[CCMoveTo actionWithDuration:0.25 position:ccp(gem.position.x,-gem->indexV*gemWid)];
                    id moveXEase=[CCEaseBackOut actionWithAction:move ]; // rate:3.5 1:bad, 3:natural,slow 4:ok, 6:ok.
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
    
    
    // New Gems drop down.
    
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
                
                id moveNew=[CCMoveTo actionWithDuration:0.26 position:ccp(newGem.position.x,-newGem->indexV*gemWid)];
                id moveXEaseNew=[CCEaseBackOut actionWithAction:moveNew ];
                
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

// This is being used
-(void) newCreatedGemsMoveDownFinishedHandler{
    
    gemToBeExchanged=nil;
    gemMoved=nil;
    moveAble = YES;
    return;
    if(gameIsOver){
        return;
    }
    ___toRemoveArr=[self tryRemove];
    

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
        if(memoryTouchedGem)
        {
            NSString * selectedState = [NSString stringWithFormat:@"gem%@b.png",memoryTouchedGem->type];
            CCSprite * newImg = [CCSprite spriteWithFile:selectedState];
            [memoryTouchedGem->img setTexture:[newImg texture]];
            arrayOfGemsToRemove = [[NSMutableArray alloc] init];
            arrayOfLines = [[NSMutableArray alloc] init];
            positionOfLastGemInLine = memoryTouchedGem.position;
        }
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
                // This is the actual Points text
            for (int i=0; i<arrayOfGemsToRemove.count; i++) {
                score+=(i*10)+10;
                [scoreTextTTF setString:[NSString stringWithFormat:@"%i",score]];
                
                Gem *gem=[arrayOfGemsToRemove objectAtIndex:i];
                // add an additional 10 points for each additional match
                CCLabelTTF * scoreVisual = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d",(i*10)+10] fontName:FONT_NAME fontSize: (i*1) + 15 * sd.scaleFactorY];
                [scoreVisual setPosition:gem.position];
                scoreVisual.color = kFontColor;
                [gemsCMC addChild:scoreVisual z:10];
                
                //  guys don't wait for this to finish before dropping down.
                id fadein = [CCFadeOut actionWithDuration:1.5];
                
                id actionRemove =  [CCCallFuncND  actionWithTarget: self
                                                         selector : @selector(removeVisualLabel : data:)
                                                              data:scoreVisual];
                [scoreVisual runAction:[CCSequence actions:fadein,actionRemove, nil]];

                // This is an action on the guys, which holds up the drop.
                id scaleXY=[CCScaleTo actionWithDuration:0.06 scale:0.2];
                id moveXEase=[CCEaseIn actionWithAction:scaleXY];
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
                                // Dragging connector line???
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


// TIME REMAINING PROGRESS BAR
-(void)loop{
    time-=1;
    
    // I don't understand what's causing this discrepancy -JW
   if(ws.height == 1024)
    {
    timeBar.scaleX= (ws.width/10) * 0.965 * (time/gameTime);
    }
    else
    {
        timeBar.scaleX= (ws.width/5) * 0.965 *(time/gameTime);
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

        // Was it a high score?
        if (score > savedHighScore) {
            savedHighScore = score;
            [highScoreText setString:[NSString stringWithFormat:@"%i",savedHighScore]];
            [newHighText setVisible:YES];
            // Save the high score
            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:highScoreKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            [newHighText setVisible:NO];
        }
        
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