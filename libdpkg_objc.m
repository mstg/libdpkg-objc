//
//  libdpkg_objc.m
//  libdpkg-objc
//
//  Created by Mustafa Gezen on 20.06.2015.
//  Copyright (c) 2015 Mustafa Gezen. All rights reserved.
//

#import "libdpkg_objc.h"

@implementation libdpkg_objc
- (struct dpkg_result)dpkg_install:(NSString *)file {
	struct dpkg_result result;

	[self _launchDpkgTask:@[@"-i", file] completion:^(NSError *error, NSString *output, NSString *errorOutput) {
		self->_error = (char*)[errorOutput UTF8String];
		self->_output = (char*)[output UTF8String];
	}];
	
	result.error = self->_error;
	result.output = self->_output;
	
	return result;
}

#pragma mark Tasks
- (void)_launchDpkgTask:(NSArray *)arguments completion:(comp)completion {
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/local/bin/dpkg";
	task.arguments = arguments;
	task.standardOutput = [NSPipe pipe];
	task.standardError = [NSPipe pipe];
	
	task.terminationHandler = ^(NSTask *task) {
		NSError *error = nil;
		
		if (task.terminationStatus) {
			error = [NSError errorWithDomain:@"io.mstg.libdpkg-objc" code:task.terminationStatus userInfo:@{
																										   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"dpkg returned an error. Code: %d.", task.terminationStatus]
																										   }];
		}
		
		NSData *outputData = ((NSPipe *)task.standardOutput).fileHandleForReading.readDataToEndOfFile;
		
		NSString *output = nil;
		output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
		
		NSString *errorOutput = [[NSString alloc] initWithData:((NSPipe *)task.standardError).fileHandleForReading.readDataToEndOfFile encoding:NSUTF8StringEncoding];
		
		NSLog(@"[Chariz] %@", errorOutput);
		
		completion(error, output, errorOutput);
	};
	
	[task launch];
}
@end
