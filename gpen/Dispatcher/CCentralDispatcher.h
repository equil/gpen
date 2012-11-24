//
//  Created by Alexey Rogatkin on 16.11.12.
//  
//


#import <Foundation/Foundation.h>


@interface CCentralDispatcher : NSObject

@property (nonatomic, readonly) dispatch_queue_t feedParsingQueue;

- (dispatch_queue_t) queueForDataSavingInModel: (NSString *) modelName;

@end