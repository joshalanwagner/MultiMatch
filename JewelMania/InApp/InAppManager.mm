

#import "InAppManager.h"
#import "CCDirector.h"


static InAppManager * sharedInstance = nil;

@implementation InAppManager
@synthesize inAppInProcess, loadingView;

+(id) sharedManager;
{
    if (sharedInstance == nil) 
    {
        sharedInstance = [[InAppManager alloc] init];
    }
    return sharedInstance;
}

+(void) releaseSharedManager;
{
    [sharedInstance release];
    sharedInstance = nil;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here
        storeObserver = [[StoreObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:storeObserver];        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAlert) name:@"removeAlertView" object:nil];
        
    }
    
    return self;
}

- (void) dealloc
{
    NSLog(@"inappmgr dealloc");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:storeObserver];
    [storeObserver release];
    
    [super dealloc];
}

// Define more methods if you have more IN_APPS

- (BOOL) facebookFeatureUnlocked
{
//    return [USER_DEFAULTS boolForKey:FACEBOOK_INAPP_KEY];
}


- (void) addPaymentToPaymentQueueForProductKey:(NSString*)productKey
{
     
//    NSString *productID = [NSString stringWithFormat:@"%@.%@",APP_BUNDLE_ID,productKey];
//    NSLog(@"%@",productID);
    if([SKPaymentQueue canMakePayments])
    {
        SKMutablePayment *payment = [[[SKMutablePayment alloc] init] autorelease];
        payment.productIdentifier = productKey;
        payment.quantity = 1 ;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
//        [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProductIdentifier:productID]];
        self.inAppInProcess = YES;
        
        // Loading Indicator
        self.loadingView = [[[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
        
        UIActivityIndicatorView *actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        actInd.frame = CGRectMake(128.0f, 45.0f, 25.0f, 25.0f);
        [self.loadingView addSubview:actInd];
        [actInd startAnimating];
        [actInd release];
        
        
        UILabel *l = [[UILabel alloc]init];
        l.frame = CGRectMake(100, -25, 210, 100);
        l.text = @"Please wait...";
        l.font = [UIFont fontWithName:@"Helvetica" size:16];
        l.textColor = [UIColor whiteColor];
        l.shadowColor = [UIColor blackColor];
        l.shadowOffset = CGSizeMake(1.0, 1.0);
        l.backgroundColor = [UIColor clearColor];
        [self.loadingView addSubview:l];
        [l release];
        
        [self.loadingView show];
        
    }
    else 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry !!!" message:@"Payments are disabled" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
}

- (void) restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [self setInAppInProcess:YES];
    
}

- (void) removeAlert
{
    if (self.loadingView)
    {
        [self.loadingView dismissWithClickedButtonIndex:0 animated:NO];
//        [self.loadingView release];
    }
}

@end
