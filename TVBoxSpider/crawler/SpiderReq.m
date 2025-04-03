//
//  SpiderReq.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "SpiderReq.h"
#import "SpiderDebug.h"

@implementation SpiderReq

+ (NSURLSession *)sharedSession {
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 60;
        config.timeoutIntervalForResource = 60;
        session = [NSURLSession sessionWithConfiguration:config];
    });
    return session;
}

+ (void)cancel:(NSString *)tag {
    [[self sharedSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSMutableArray *tasks = [NSMutableArray array];
        [tasks addObjectsFromArray:dataTasks];
        [tasks addObjectsFromArray:uploadTasks];
        [tasks addObjectsFromArray:downloadTasks];
        
        for (NSURLSessionTask *task in tasks) {
            if ([task.taskDescription isEqualToString:tag]) {
                [task cancel];
            }
        }
    }];
}

+ (void)request:(NSURLRequest *)request completion:(void(^)(SpiderReqResult *))completion {
    NSURLSessionDataTask *task = [[self sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        SpiderReqResult *result = [SpiderReqResult new];
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            result.headers = httpResponse.allHeaderFields;
        }
        
        if (data) {
            result.content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        if (error) {
            [SpiderDebug logWithThrowable:[NSException exceptionWithName:@"NetworkError" reason:error.localizedDescription userInfo:nil]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result ?: [SpiderReqResult empty]);
        });
    }];
    
    [task resume];
}

+ (void)get:(NSString *)url headers:(NSDictionary<NSString *, NSString *> *)headers completion:(void(^)(SpiderReqResult *))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request addValue:value forHTTPHeaderField:key];
    }];
    [self request:request completion:completion];
}

+ (void)postForm:(NSString *)url form:(NSDictionary<NSString *, NSString *> *)form headers:(NSDictionary<NSString *, NSString *> *)headers completion:(void(^)(SpiderReqResult *))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableArray *params = [NSMutableArray new];
    [form enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [params addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }];
    
    request.HTTPBody = [[params componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request addValue:value forHTTPHeaderField:key];
    }];
    [self request:request completion:completion];
}

+ (void)postJson:(NSString *)url json:(NSDictionary<NSString *, NSString *> *)json headers:(NSDictionary<NSString *, NSString *> *)headers completion:(void(^)(SpiderReqResult *))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if (error) {
        [SpiderDebug logWithThrowable:[NSException exceptionWithName:@"JSONError" reason:error.localizedDescription userInfo:nil]];
        completion([SpiderReqResult empty]);
        return;
    }
    
    request.HTTPBody = jsonData;
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request addValue:value forHTTPHeaderField:key];
    }];
    [self request:request completion:completion];
}

@end
