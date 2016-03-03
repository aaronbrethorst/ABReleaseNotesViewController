//
//  ABReleaseNotesDownloader.h
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


#import <Foundation/Foundation.h>

/**
 Retrieves release notes and the current version number from the App Store for the app whose
 app identifier is passed in on initialization.
 */

NS_ASSUME_NONNULL_BEGIN

@interface ABReleaseNotesDownloader : NSObject

/**
 Returns a newly initialized downloader with the specified app identifier.
 
 @param appIdentifier The unique ID of your app in the App Store.
 
 @return A newly initialized `ABReleaseNotesDownloader` object.
 */
- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier;

/**
 Responsible for checking the App Store for updates to the app identifier specified in initialization.
 
 @param checker The block to execute after the update check finishes. This block has no return value, but has three parameters: a BOOL flag indicating whether the app has been updated, release notes, and a new version number. and takes no parameters.
 */
- (void)checkForUpdates:(void (^)(BOOL updated, NSString *releaseNotes, NSString *versionNumber))checker;
@end

NS_ASSUME_NONNULL_END
