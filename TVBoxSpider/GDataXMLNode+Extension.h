//
//  GDataXMLNode+Extension.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/7.
//

#import <GDataXML_HTML/GDataXMLNode.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDataXMLNode (Extension)

- (GDataXMLNode *)nextSibling;
- (GDataXMLNode *)nextNode;
- (GDataXMLNode *)parent;

@end

NS_ASSUME_NONNULL_END
