/*
 * Cucumber.j
 * Cucumber test Framework
 *
 * Created by Daniel Parnell on April 26, 2010.
 * Copyright 2010, Automagic Software Pty Ltd All rights reserved.
 */

@import <Foundation/Foundation.j>

@implementation Cucumber : CPObject
{
}

- (id) init {
	self = [super init];
	
	if(self) {
		// initialization code here
		console.info("Starting");
		[self start];
	}
	
	return self;
}

- (void) start {
	var request = [[CPURLRequest alloc] initWithURL: "/cucumber"];
	[request setHTTPMethod: "GET"];

	[CPURLConnection connectionWithRequest: request delegate: self];
}

-(void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
//	console.error("connection failed");
	CPLog.error("Connection failed");
}


-(void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
	// do nothing
	console.info("didReceiveResponse")
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	console.info("didReceiveData");
	
	if(data!=null && data!="") {
		var object = [data objectFromJSON];
		
		if(object) {
		}
	}

	console.info(data);
	[self start];
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
	console.info("THERE");
	[self start];
}

@end

[[Cucumber alloc] init];

/*
window.startCucumber = function() {
	console.info("HERE");
	[[[Cucumber alloc] init] start];
	console.info("THERE");
}
*/