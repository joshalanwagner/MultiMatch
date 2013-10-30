//
//  AppDelegate.m
//  JellyMania
//
//  Created by Chris on 13-7-13.
//  Copyright AppyPocket 2013. All rights reserved.
//

#import "cocos2d.h"
#import "Nextpeer/Nextpeer.h"
#import "AppController.h"
#import "IntroLayer.h"
#import "SharedData.h"
#import "SimpleAudioEngine.h"



@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Interstitial ad placeholder
    
    // Game Center???
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
        if (error == nil)
        {
            
            NSLog(@" Authenticate local player complete");
            
        }
        else
        {
           
            NSLog(@"Authenticate local player Error: %@", [error description]);
        }
    }];
   
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;

	// Display FSP and SPF
	[director_ setDisplayStats:NO];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [IntroLayer scene]]; 

    /// Seems like we should be setting a scale factor of 1.2 for SD iPads?
    if ([UIScreen mainScreen].bounds.size.width == 768 && [UIScreen mainScreen].bounds.size.height == 1024)
    {
        SharedData * sd =   [SharedData getSharedInstance];
        sd.scaleFactorX = 2.4;
        sd.scaleFactorY = 2.133;
        sd.imgScaleFactorY = .90;
    }
    else
    {
        SharedData * sd =   [SharedData getSharedInstance];
        sd.scaleFactorX = 1.0;
        sd.scaleFactorY = 1.0;
        sd.imgScaleFactorY = 1.0;
    }
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
 
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	// make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];

	[super dealloc];
}



// NEXT PEER MULTIPLAYER


- (void)initializeNextpeer
{
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:TRUE], NextpeerSettingSupportsDashboardRotation,
                              [NSNumber numberWithInt:NPNotificationPosition_BOTTOM], NextpeerSettingNotificationPosition,
                              [NSNumber numberWithBool:TRUE], NextpeerSettingObserveNotificationOrientationChange,
                              nil];
    
	// NP Integration steps: Make sure to place you code from the developer dashboard
	[Nextpeer initializeWithProductKey:@"6caa2668cdbXXXXXXXXXXc3f2ae950bc" andSettings:settings andDelegates:
     [NPDelegatesContainer containerWithNextpeerDelegate:self notificationDelegate:nil tournamentDelegate:self currencyDelegate:nil]];
}
-(void)nextpeerDidTournamentStartWithDetails:(NPTournamentStartDataContainer *)tournamentContainer {
    // Add code that starts a tournament:
    // 1. Load scene
    // 2. Start game
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"start_multi_game" object:nil];
}

-(BOOL)nextpeerNotSupportedShouldShowCustomError
{
    return YES;
}
-(void)nextpeerDidTournamentEnd {
    // Add code that ends the current tournament
    // 1. Stop game and animations
    // 2. Release any unneeded resources
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([Nextpeer handleOpenURL:url]) {
        return YES;
    }
    
    // Handle other possible URLS
    
    return NO;
}




- (void) showLeaderboard{
	NSLog(@"show leaderboard");
	
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [self.window.rootViewController presentModalViewController:leaderboardController animated: YES];
    }
}
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
}


# pragma mark Adcolont delegate
- ( void ) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID {
	NSLog(@"AdColony zone %@ reward %i %i %@", zoneID, success, amount, currencyName);
	
	if (success)
    {
        NSLog(@"Sucess");
		NSUserDefaults* storage = [NSUserDefaults standardUserDefaults];
        
        [storage setBool:YES forKey:@"multiplayerUnlocked"];
//
//		// Get currency balance from persistent storage and update it
//		NSNumber* wrappedBalance = [storage objectForKey:kCurrencyBalance];
//		NSUInteger balance = wrappedBalance && [wrappedBalance isKindOfClass:[NSNumber class]] ? [wrappedBalance unsignedIntValue] : 0;
//		balance += amount;
//		
//		// Persist the currency balance
//		[storage setValue:[NSNumber numberWithUnsignedInt:balance] forKey:kCurrencyBalance];
		[storage synchronize];
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Jelly Mania" message:@"MultiPlayer Unlocked." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //  [[NSUserDefaults standardUserDefaults]setValue:@"pnt" forKey:@"pnt"];
        
        [alert show];
		
		// Post a notification so the rest of the app knows the balance changed
		[[NSNotificationCenter defaultCenter] postNotificationName:@"multiPlayerUnlocked" object:nil];
	} else
    {
        NSLog(@"fail");
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];

//		[[NSNotificationCenter defaultCenter] postNotificationName:kZoneOff object:nil];
	}
}


- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID
{
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

/**
 * Notifies your app that an ad completed playing (or never played) and control has been returned to the app.
 * This method is called when AdColony has finished trying to show an ad, either successfully or unsuccessfully.
 * If an ad was shown, apps should implement app-specific code such as unpausing a game and restarting app music.
 * @param shown Whether an ad was actually shown
 * @param zoneID The affected zone
 */
- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID
{
    if(shown)
    {
       
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"NO videos Available At this time." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //  [[NSUserDefaults standardUserDefaults]setValue:@"pnt" forKey:@"pnt"];
        
        [alert show];
    }
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}
@end

