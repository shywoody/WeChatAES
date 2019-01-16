//
//  EchatStack.m
//  test
//
//  Created by xll on 2018/4/18.
//  Copyright © 2018年 yons. All rights reserved.
//

#import "EchatStack.h"

@implementation EchatStack
- (id) init {
    
    self = [super init];
    
    if (self) {
        
        _stackArray = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}


- (BOOL) empty {
    
    return ((_stackArray == nil)||([_stackArray count] == 0));
    
}


- (id) top {
    
    id value = nil;
    
    if (_stackArray&&[_stackArray count]) {
        
        value = [_stackArray lastObject];
        
    }
    
    return value;
    
}



- (void) pop {
    
    if (_stackArray&&[_stackArray count]) {
        
        [_stackArray removeLastObject];
        
    }
    
}



- (void) push:(id)value {
    
    [_stackArray addObject:value];
    
}

- (void) dealloc {
    
}
@end
