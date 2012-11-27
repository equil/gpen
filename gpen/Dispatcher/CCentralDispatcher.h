//
//  Created by Alexey Rogatkin on 16.11.12.
//  
//


#import <Foundation/Foundation.h>


@interface CCentralDispatcher : NSObject

@property (nonatomic, readonly) dispatch_queue_t dataUpdateQueue;
@property (nonatomic, readonly) dispatch_queue_t dataSavingQueue;

@end