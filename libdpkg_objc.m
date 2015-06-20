//
//  libdpkg_objc.m
//  libdpkg-objc
//
//  Created by Mustafa Gezen on 20.06.2015.
//  Copyright (c) 2015 Mustafa Gezen. All rights reserved.
//

#import "libdpkg_objc.h"
NSString * dpkg_path = @"/usr/local/chariz/dpkg";

@implementation libdpkg_objc
- (void)dpkg_install:(NSString *)file completion:(completed)completion {
	[self _launchDpkgTask:@[@"-i", file] completion:^(NSError *error, NSString *output, NSString *errorOutput) {
		struct dpkg_result result;
		
		if ([errorOutput containsString:@"Errors were encountered while processing"]) {
			result.result = 0;
		} else if (![errorOutput containsString:@"Errors were encountered while processing"] && [output containsString:@"Setting up"]) {
			result.result = 1;
		}
		
		result.error = (char*)[errorOutput UTF8String];
		result.output = (char*)[output UTF8String];
		
		completion(result);
	}];
}

- (void)dpkg_remove:(NSString *)name completion:(completed)completion {
	[self _launchDpkgTask:@[@"-r", name] completion:^(NSError *error, NSString *output, NSString *errorOutput) {
		struct dpkg_result result;
		
		if ([errorOutput containsString:@"Errors were encountered while processing"]) {
			result.result = 0;
		} else if (![errorOutput containsString:@"Errors were encountered while processing"] && [output containsString:@"Setting up"]) {
			result.result = 1;
		}
		
		result.error = (char*)[errorOutput UTF8String];
		result.output = (char*)[output UTF8String];
		
		completion(result);
	}];
}

- (void)dpkg_package_installed:(NSString *)name completion:(completed)completion {
	[self _launchDpkgTask:@[@"-s", name] completion:^(NSError *error, NSString *output, NSString *errorOutput) {
		struct dpkg_result result;
		
		if ([errorOutput containsString:@"is not installed"]) {
			result.result = 0;
		} else {
			result.result = 1;
		}
		
		result.error = (char*)[errorOutput UTF8String];
		result.output = (char*)[output UTF8String];
		
		completion(result);
	}];
}

- (void)dpkg_download:(NSString *)stringurl name:(NSString *)name completion:(completed)completion {
	struct dpkg_result result;
	
	NSURL  *url = [NSURL URLWithString:stringurl];
	NSData *urlData = [NSData dataWithContentsOfURL:url];
	if ( urlData ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:dpkg_path
								  withIntermediateDirectories:YES
												   attributes:nil
														error:nil];

		[urlData writeToFile:[dpkg_path stringByAppendingPathComponent:name] atomically:YES];
		
		result.result = 1;
	} else {
		result.result = 0;
	}
	
	completion(result);
}

#pragma mark Tasks
- (void)_launchDpkgTask:(NSArray *)arguments completion:(comp)completion {
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/local/bin/dpkg";
	task.arguments = arguments;
	
	NSDictionary *env_dict = @{
		@"PATH": @"/usr/local/bin:/usr/bin:/bin:/usr/sbin"
	};
	
	task.standardOutput = [NSPipe pipe];
	task.standardError = [NSPipe pipe];
	task.environment = env_dict;
	
	task.terminationHandler = ^(NSTask *task) {
		NSError *error = nil;
		
		if (task.terminationStatus) {
			error = [NSError errorWithDomain:@"io.chariz.CharizHelper" code:task.terminationStatus userInfo:@{
																										   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"dpkg returned an error. Code: %d.", task.terminationStatus]
																										   }];
		}
		
		NSData *outputData = ((NSPipe *)task.standardOutput).fileHandleForReading.readDataToEndOfFile;
		
		NSString *output = nil;
		output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
		
		NSString *errorOutput = [[NSString alloc] initWithData:((NSPipe *)task.standardError).fileHandleForReading.readDataToEndOfFile encoding:NSUTF8StringEncoding];
		
		completion(error, output, errorOutput);
	};
	
	[task launch];
}
@end
