

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
//#import "RefreshViewProtocol.h"

@interface StoreObserver : NSObject<SKPaymentTransactionObserver,UIAlertViewDelegate> {
   
}

@property (nonatomic, retain) UIAlertView * loadingAlert;

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) showUnlockedAlert:(NSString *)productIdentifier;
- (void) showTransactionCompleteAlert : (NSString *) msg;
- (void) showTransactionFailedAlert : (NSString *) msg;

@end
