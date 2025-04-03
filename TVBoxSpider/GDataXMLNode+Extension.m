//
//  GDataXMLNode+Extension.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/7.
//

#import "GDataXMLNode+Extension.h"
#import <libxml/tree.h>


@implementation GDataXMLNode (Extension)

- (GDataXMLNode *)nextSibling {
    xmlNodePtr nodePtr = self.XMLNode;
    if (!nodePtr || !nodePtr->next) return nil;
    
    return [[GDataXMLNode alloc] initBorrowingXMLNode:(xmlNodePtr)nodePtr->next];
}

- (GDataXMLNode *)nextNode {
    if (!self.parent) return nil;
        
    NSArray *siblings = [self.parent children];
    NSUInteger currentIndex = [siblings indexOfObject:self];
    
    if (currentIndex == NSNotFound || currentIndex >= siblings.count - 1) {
        return nil;
    }
    
    return siblings[currentIndex + 1];
}

- (GDataXMLNode *)parent {
    xmlNodePtr nodePtr = self.XMLNode;
    if (!nodePtr || !nodePtr->parent) return nil;
    
    return [[GDataXMLNode alloc] initBorrowingXMLNode:(xmlNodePtr)nodePtr->parent];
}

@end
