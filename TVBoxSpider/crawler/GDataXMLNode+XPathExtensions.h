//
//  GDataXMLNode+XPathExtensions.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/10.
//

#import <Foundation/Foundation.h>
#import "GDataXML_HTML/GDataXMLNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDataXMLNode (XPathExtensions)

- (NSString *)stringTrimmed;

@end

@interface NSString (XPathExtensions)

- (NSString *)subNodeText;

@end

NS_ASSUME_NONNULL_END
