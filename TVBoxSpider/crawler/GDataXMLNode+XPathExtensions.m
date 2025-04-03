//
//  GDataXMLNode+XPathExtensions.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/10.
//

#import "GDataXMLNode+XPathExtensions.h"

@implementation GDataXMLNode (XPathExtensions)

- (NSString *)stringTrimmed {
    NSString *trimStr = [[self stringValue] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    return [trimStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end

#pragma mark - NSString 扩展

@implementation NSString (XPathExtensions)

- (NSString *)subNodeText {
    if ([self length] == 0) {
        return self;
    }
    
    if ([self hasPrefix:@"/"]) {
        return [self substringFromIndex:1];
    }
    
    return self;
}

@end
