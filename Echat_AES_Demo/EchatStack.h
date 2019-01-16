//
//  EchatStack.h
//  test
//
//  Created by xll on 2018/4/18.
//  Copyright © 2018年 yons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EchatStack : NSObject{
    NSMutableArray * _stackArray;
}

- (BOOL) empty;



- (id) top;



- (void) pop;


- (void) push:(id)value;
@end
