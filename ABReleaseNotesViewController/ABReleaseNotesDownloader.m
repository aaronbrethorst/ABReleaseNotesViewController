//
//  ABReleaseNotesDownloader.m
//
//  ABReleaseNotesViewController
//
//  Copyright (c) 2016 Aaron Brethorst
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


#import "ABReleaseNotesDownloader.h"

@interface ABReleaseNotesDownloader ()
@property(nonatomic,copy) NSString *appIdentifier;
@property(nonatomic,strong) NSURLSessionDataTask *task;
@property(nonatomic,copy,readwrite) NSString *releaseNotes;
@property(nonatomic,copy,readwrite) NSString *versionNumber;
@end

@implementation ABReleaseNotesDownloader

- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier {
    self = [super init];

    if (self) {
        _appIdentifier = [appIdentifier copy];
    }
    return self;
}

- (void)dealloc {
    [self.task cancel];
    self.task = nil;
}

- (void)checkForUpdates:(void (^)(BOOL updated, NSString *releaseNotes, NSString *versionNumber))checker {

    NSURL *URL = [self.class requestURLForAppIdentifier:self.appIdentifier];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];

    [self loadRequest:request success:^(id response) {

        self.releaseNotes = [self.class extractReleaseNotesFromResponse:response];
        self.versionNumber = [self.class extractVersionNumberFromResponse:response];

        checker(YES, self.releaseNotes, self.versionNumber);
    } failure:^(NSError *error) {
        checker(NO, nil, nil);
    }];
}

- (void)loadRequest:(NSURLRequest *)request success:(void (^)(id response))success failure:(void (^)(NSError* error))failure {

    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        id responseObject = nil;

        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            return;
        }

        if (data.length) {
            NSError *jsonError = nil;
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&jsonError];

            if (!responseObject && jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(jsonError);
                });
                return;
            }
        }


        dispatch_async(dispatch_get_main_queue(), ^{
            success(responseObject);
        });
    }];

    [self.task resume];
}

#pragma mark - Private

+ (NSURL*)requestURLForAppIdentifier:(NSString*)appIdentifier {
    NSURLComponents *components = [NSURLComponents componentsWithURL:[NSURL URLWithString:@"http://itunes.apple.com/lookup"] resolvingAgainstBaseURL:NO];
    components.queryItems = @[
                              [NSURLQueryItem queryItemWithName:@"id" value:appIdentifier],
                              [NSURLQueryItem queryItemWithName:@"country" value:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]],
                              ];
    return components.URL;
}

+ (NSString*)extractVersionNumberFromResponse:(NSDictionary*)response {
    @try {
        return response[@"results"][0][@"version"];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (NSString*)extractReleaseNotesFromResponse:(NSDictionary*)response {
    @try {
        return response[@"results"][0][@"releaseNotes"];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

@end
