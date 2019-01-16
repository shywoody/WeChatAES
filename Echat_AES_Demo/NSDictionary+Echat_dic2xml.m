//
//  NSDictionary+Echat_dic2xml.m
//  test
//
//  Created by xll on 2018/4/18.
//  Copyright © 2018年 yons. All rights reserved.
//

#import "NSDictionary+Echat_dic2xml.h"
#import "EchatStack.h"

@implementation NSDictionary (Echat_dic2xml)
- (NSArray*) Echat_trans2Array {
    
    NSMutableArray *entities = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    NSEnumerator *enumerator = [self objectEnumerator];
    
    id value;
    
    while ((value = [enumerator nextObject])) {
        
        [entities addObject:value];
        
    }
    
    return entities;
    
}

- (NSString*)Echat_trans2XMLString{
    
    NSMutableString *xmlString = [[NSMutableString alloc] initWithString:@"<xml>\n"];
    
    EchatStack *stack = [[EchatStack alloc] init];
    
    NSArray  *keys = nil;
    
    NSString *key  = nil;
    
    NSObject *value    = nil;
    
    NSObject *subvalue = nil;
    
    NSInteger size = 0;
    
    [stack push:self];
    
    while (![stack empty]) {
        
        value = [stack top];
        
        [stack pop];
        
        if (value) {
            
            if ([value isKindOfClass:[NSString class]]) {
                
                [xmlString appendFormat:@"</%@>", value];
                
            }
            
            else if([value isKindOfClass:[NSDictionary class]]) {
                
                keys = [(NSDictionary*)value allKeys];
                
                size = [(NSDictionary*)value count];
                
                for (key in keys) {
                    
                    subvalue = [(NSDictionary*)value objectForKey:key];
                    
                    if ([subvalue isKindOfClass:[NSDictionary class]]) {
                        
                        [xmlString appendFormat:@"<%@>", key];
                        
                        [stack push:key];
                        
                        [stack push:subvalue];
                        
                    }
                    
                    else if([subvalue isKindOfClass:[NSString class]]) {
                        
                        [xmlString appendFormat:@"<%@><![CDATA[%@]]></%@>\n", key, subvalue, key];
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    return [NSString stringWithFormat:@"%@</xml>",xmlString];
    
}


@end
