//
//  Created by Alexey Rogatkin on 16.11.12.
//  
//


#import "CCentralDispatcher.h"

#define OS_OBJECT_USE_OBJC 0

@implementation CCentralDispatcher {
    NSMutableDictionary *_dataSavingQueues;
}

@synthesize feedParsingQueue = _feedParsingQueue;

- (id)init {
    self = [super init];
    if (self) {
        _dataSavingQueues = [[NSMutableDictionary alloc] init];
        _feedParsingQueue = dispatch_queue_create("ru.xpguild.feed.parsing", NULL);
    }
    return self;
}

- (dispatch_queue_t)queueForDataSavingInModel:(NSString *)modelName {
    if ([_dataSavingQueues objectForKey:modelName] == nil) {
        dispatch_queue_t newQueue = dispatch_queue_create([[NSString stringWithFormat:@"ru.xpguild.saving.%@", modelName] UTF8String], NULL);
        [_dataSavingQueues setObject:newQueue forKey:modelName];
    }
    return [_dataSavingQueues objectForKey:modelName];
}

@end