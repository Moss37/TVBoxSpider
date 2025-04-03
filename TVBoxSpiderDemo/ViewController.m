//
//  ViewController.m
//  TVBoxSpiderDemo
//
//  Created by Moss37 on 2025/3/6.
//

#import "ViewController.h"
#import <dlfcn.h>
#import "Spider.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)testHongxujixi {
    Class jumiClass = NSClassFromString(@"Crqz");
    id<Spider> jumi = [[jumiClass alloc] init];
    [jumi homeContent:false completion:^(NSString * _Nonnull str) {
        NSLog(@"%@", str);
    }];
//    [jumi categoryContent:@"crq-tv" page:@"1" filter:false extend:[NSDictionary dictionary] completion:^(NSString * _Nonnull str) {
//        NSLog(@"%@", str);
//    }];
//    [jumi detailContent:@[@"jialijiawai2009"] completion:^(NSString * _Nonnull str) {
//        NSLog(@"%@", str);
//    }];
//    [jumi playerContent:@"" videoId:@"jialijiawai2009/1-1" vipFlags:@[] completion:^(NSString * _Nonnull str) {
//        NSLog(@"%@", str);
//    }];
//    [jumi searchContent:@"凡人修仙传" quick:NO completion:^(NSString * _Nonnull str) {
//        NSLog(@"%@", str);
//    }];
}

- (IBAction)testActions:(id)sender {
    [self testHongxujixie];
    return;
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"jumi" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:jsonPath] encoding:NSUTF8StringEncoding error:nil];
    Class jumiClass = NSClassFromString(@"Jumi");
    id<Spider> jumi = [[jumiClass alloc] initWithExt:jsonString];
//    [jumi homeContent:false completion:^(NSString * _Nonnull str) {
//        NSLog(@"%@", str);
//    }];
//    [jumi categoryContent:@"2" page:@"1" filter:false extend:[NSDictionary dictionary] completion:^(NSString * _Nonnull str) {
//        NSLog(@"%@", str);
//    }];
//    [jumi detailContent:@[@"35956"] completion:^(NSString * _Nonnull str) {
//        NSLog(@"%@", str);
//    }];
//    [jumi playerContent:@"" videoId:@"35956-6-1" vipFlags:@[] completion:^(NSString * _Nonnull str) {
//        NSLog(@"%@", str);
//    }];
    [jumi searchContent:@"三十而已" quick:NO completion:^(NSString * _Nonnull str) {
        NSLog(@"%@", str);
    }];
//    [self testHomeContentWithFilter:false];
//    [self testCategoryContent:@"2" page:@"1" filter:false extend:[NSDictionary dictionary]];
//    [self testDetailContent:@[@"281255"]];
//    [self testPlayerContent:@"" videoId:@"281255-2-1" vipFlags:@[]];
//    [self testSearchContent:@"三十而已" quick:false];
}

@end
