//
//  Created by Alexey Rogatkin on 16.11.12.
//  
//


#import "CCentralDispatcher.h"

#define OS_OBJECT_USE_OBJC 0

@implementation CCentralDispatcher

@synthesize dataUpdateQueue = _dataUpdateQueue;
@synthesize dataSavingQueue = _dataSavingQueue;

- (id)init {
    self = [super init];
    if (self) {
        _dataSavingQueue = dispatch_queue_create("ru.xpguild.gpen.save", NULL);
        _dataUpdateQueue = dispatch_queue_create("ru.xpguild.gpen.update", NULL);
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_dataSavingQueue);
    dispatch_release(_dataUpdateQueue);
}

@end