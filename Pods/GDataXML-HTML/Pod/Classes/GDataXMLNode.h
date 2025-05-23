/* Modifications for HTML parser support:
 * Copyright (c) 2011 Simon Grätzer simon@graetzer.org
 *
 * Copyright (c) 2008 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// These node, element, and document classes implement a subset of the methods
// provided by NSXML.  While NSXML behavior is mimicked as much as possible,
// there are important differences.
//
// The biggest difference is that, since this is based on libxml2, there
// is no retain model for the underlying node data.  Rather than copy every
// node obtained from a parse tree (which would have a substantial memory
// impact), we rely on weak references, and it is up to the code that
// created a document to retain it for as long as any
// references rely on nodes inside that document tree.


#import <Foundation/Foundation.h>
#import <libxml/tree.h>


#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4) || defined(GDATA_TARGET_NAMESPACE)
// we need NSInteger for the 10.4 SDK, or we're using target namespace macros
#import "GDataDefines.h"
#endif

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAXMLNODE_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#if defined(__cplusplus)
#define _EXTERN extern "C"
#else
#define _EXTERN extern
#endif
#define _INITIALIZE_AS(x)
#endif

// when no namespace dictionary is supplied for XPath, the default namespace
// for the evaluated tree is registered with the prefix _def_ns
_EXTERN const char* kGDataXMLXPathDefaultNamespacePrefix _INITIALIZE_AS("_def_ns");

// Nomenclature for method names:
//
// Node = GData node
// XMLNode = xmlNodePtr
//
// So, for example:
//  + (id)nodeConsumingXMLNode:(xmlNodePtr)theXMLNode;

@class NSArray, NSDictionary, NSError, NSString, NSURL;
@class GDataXMLElement, GDataXMLDocument;

enum {
    GDataXMLInvalidKind = 0,
    GDataXMLDocumentKind,
    GDataXMLElementKind,
    GDataXMLAttributeKind,
    GDataXMLNamespaceKind,
    GDataXMLProcessingInstructionKind,
    GDataXMLCommentKind,
    GDataXMLTextKind,
    GDataXMLDTDKind,
    GDataXMLEntityDeclarationKind,
    GDataXMLAttributeDeclarationKind,
    GDataXMLElementDeclarationKind,
    GDataXMLNotationDeclarationKind
};

typedef NSUInteger GDataXMLNodeKind;

@interface GDataXMLNode : NSObject <NSCopying>
#warning pod 之后就没了
- (id)initConsumingXMLNode:(xmlNodePtr)theXMLNode;
- (id)initBorrowingXMLNode:(xmlNodePtr)theXMLNode;
+ (GDataXMLElement *)elementWithName:(NSString *)name;
+ (GDataXMLElement *)elementWithName:(NSString *)name stringValue:(NSString *)value;
+ (GDataXMLElement *)elementWithName:(NSString *)name URI:(NSString *)value;

+ (id)attributeWithName:(NSString *)name stringValue:(NSString *)value;
+ (id)attributeWithName:(NSString *)name URI:(NSString *)attributeURI stringValue:(NSString *)value;

+ (id)namespaceWithName:(NSString *)name stringValue:(NSString *)value;

+ (id)textWithStringValue:(NSString *)value;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;

- (NSUInteger)childCount;
- (NSArray *)children;
- (GDataXMLNode *)childAtIndex:(unsigned)index;

- (NSString *)localName;
- (NSString *)name;
- (NSString *)prefix;
- (NSString *)URI;

- (GDataXMLNodeKind)kind;

- (NSString *)XMLString;

+ (NSString *)localNameForName:(NSString *)name;
+ (NSString *)prefixForName:(NSString *)name;

// This is the preferred entry point for nodesForXPath.  This takes an explicit
// namespace dictionary (keys are prefixes, values are URIs).
- (NSArray *)nodesForXPath:(NSString *)xpath namespaces:(NSDictionary *)namespaces error:(NSError **)error;

- (GDataXMLNode *)firstNodeForXPath:(NSString *)xpath namespaces:(NSDictionary *)namespaces error:(NSError **)error;

// This implementation of nodesForXPath registers namespaces only from the
// document's root node.  _def_ns may be used as a prefix for the default
// namespace, though there's no guarantee that the default namespace will
// be consistenly the same namespace in server responses.
- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error;

- (GDataXMLNode *)firstNodeForXPath:(NSString *)xpath error:(NSError **)error;

// access to the underlying libxml node; be sure to release the cached values
// if you change the underlying tree at all
- (xmlNodePtr)XMLNode;
- (void)releaseCachedValues;

@end


@interface GDataXMLElement : GDataXMLNode

- (id)initWithXMLString:(NSString *)str error:(NSError **)error;
- (id)initWithHTMLString:(NSString *)str error:(NSError **)error;

- (NSArray *)namespaces;
- (void)setNamespaces:(NSArray *)namespaces;
- (void)addNamespace:(GDataXMLNode *)aNamespace;

// addChild adds a copy of the child node to the element
- (void)addChild:(GDataXMLNode *)child;
- (void)removeChild:(GDataXMLNode *)child;

- (NSArray *)elementsForName:(NSString *)name;
- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI;

- (NSArray *)attributes;
- (GDataXMLNode *)attributeForName:(NSString *)name;
- (GDataXMLNode *)attributeForLocalName:(NSString *)name URI:(NSString *)attributeURI;
- (void)addAttribute:(GDataXMLNode *)attribute;

- (NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI;

@end

@interface GDataXMLDocument : NSObject

- (id)initWithXMLString:(NSString *)str encoding:(NSStringEncoding)encoding error:(NSError **)error;
- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding error:(NSError **)error;

- (id)initWithHTMLString:(NSString *)str encoding:(NSStringEncoding)encoding error:(NSError **)error;
- (id)initWithHTMLData:(NSData *)data encoding:(NSStringEncoding)encoding error:(NSError **)error;

- (id)initWithXMLString:(NSString *)str error:(NSError **)error;
- (id)initWithData:(NSData *)data error:(NSError **)error;

- (id)initWithHTMLString:(NSString *)str error:(NSError **)error;
- (id)initWithHTMLData:(NSData *)data error:(NSError **)error;

// initWithRootElement uses a copy of the argument as the new document's root
- (id)initWithRootElement:(GDataXMLElement *)element;

- (GDataXMLElement *)rootElement;

- (NSData *)XMLData;

- (void)setVersion:(NSString *)version;
- (void)setCharacterEncoding:(NSString *)encoding;

// This is the preferred entry point for nodesForXPath.  This takes an explicit
// namespace dictionary (keys are prefixes, values are URIs).
- (NSArray *)nodesForXPath:(NSString *)xpath namespaces:(NSDictionary *)namespaces error:(NSError **)error;

// Convenience method returns first element with speciifed xpath or nil
- (GDataXMLNode *)firstNodeForXPath:(NSString *)xpath namespaces:(NSDictionary *)namespaces error:(NSError **)error;

// This implementation of nodesForXPath registers namespaces only from the
// document's root node.  _def_ns may be used as a prefix for the default
// namespace, though there's no guarantee that the default namespace will
// be consistenly the same namespace in server responses.
- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error;

- (GDataXMLNode *)firstNodeForXPath:(NSString *)xpath error:(NSError **)error;

- (NSString *)description;
@end
