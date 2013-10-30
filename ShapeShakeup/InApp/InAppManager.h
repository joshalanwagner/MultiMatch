

#import <Foundation/Foundation.h>
#import "StoreObserver.h"

@interface InAppManager : NSObject
{
    StoreObserver *storeObserver;
    BOOL inAppInProcess;
    
    UIAlertView * loadingView;
    
}

@property (nonatomic, retain) UIAlertView * loadingView;
@property (nonatomic) BOOL inAppInProcess;

+(id) sharedManager;
+(void) releaseSharedManager;

- (BOOL) facebookFeatureUnlocked; // Add more methods according to your InApp items

- (void) addPaymentToPaymentQueueForProductKey:(NSString*)productKey;
- (void) restorePurchases;
- (void) removeAlert;
@end
