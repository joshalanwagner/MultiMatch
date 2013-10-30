

#import "StoreObserver.h"
#import "InAppManager.h"
#import "AppController.h"

@implementation StoreObserver

- (void) recordTransaction:(SKPaymentTransaction *)transaction

{
    
    //record the transaction. Set the boolean in USER_DEFAULTS
    if([transaction.payment.productIdentifier isEqualToString:REMOVE_AD_ID])
    {
     
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"removeAd"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
    
}

- (void) showUnlockedAlert:(NSString *)productIdentifier
{

    {
        
        [self showTransactionCompleteAlert:@"Enjoy your purchased item. :)"];
        // It will refresh the viewController

        [[NSNotificationCenter defaultCenter] postNotificationName:@"DZCustomNotification" object:nil];
    }
    //else
    {
        
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
    [[InAppManager sharedManager] setInAppInProcess:NO];
    
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{

    
    // Your application should implement these two methods.
    [self recordTransaction:transaction];
    
    [self showUnlockedAlert:transaction.payment.productIdentifier];
    
    NSLog(@"transaction has been completed");
    
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{

    [self recordTransaction: transaction];

    NSLog(@"transaction has been restored");

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{

    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // Optionally, display an error here.
    }
    
    
    [self showTransactionFailedAlert:@"Cannot connect to iTunes Store"];
    
    NSLog(@"Transaction has been failed: %@",transaction.error);
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - UIAlertView

- (void)showTransactionCompleteAlert : (NSString *) msg
{

    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrats!" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    // It will refresh the viewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAlertView" object:nil];
}

- (void)showTransactionFailedAlert : (NSString *) msg
{

    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction failed" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAlertView" object:nil];
}


@end
