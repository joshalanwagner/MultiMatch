//
//  AppDelegate.h
//  JellyMania
//
//  Created by Chris on 13-7-13.
//  Copyright AppyPocket 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "MopubSDK/MPInterstitialAdController.h"
#import <Nextpeer/Nextpeer.h>
#import <AdColony/AdColony.h>

#define CB_APPID @"525b080XXXXXXXXXX4000008"
#define CB_SIGNATURE @"66c945989ab11cb5da6cXXXXXXXXXXc47afd8f9f"
#define REVMOB_ID @"525b07d1XXXXXXXXXX000006"
#define REMOVE_AD_ID @"SSRemoveAds"
#define ADCOLONY_ID  @"appab576XXXXXXXXXXa9f2bc6"
#define ADCOLONY_ZONE_ID @"vz8203cXXXXXXXXXXa84f749"
//MOPUB
#define iPadDevice (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define moPubAdUnitID_fullScreenTablet @"c43a5a0bd76a4f168cc3304186afe165"
#define moPubAdUnitID_fullScreenPhone @"0bcd9c2054ac4c3bac098963b5aab640" 

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate,NPTournamentDelegate,NextpeerDelegate,GKLeaderboardViewControllerDelegate,AdColonyDelegate,AdColonyAdDelegate,MPInterstitialAdControllerDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, retain) MPInterstitialAdController *interstitial; //mopub

-(void) initializeNextpeer;
- (void) showLeaderboard;

@end
