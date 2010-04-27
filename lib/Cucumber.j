/*
 * Cucumber.j
 * Cucumber test Framework
 *
 * Created by Daniel Parnell on April 26, 2010.
 * Copyright 2010, Automagic Software Pty Ltd All rights reserved.
 */

@import <Foundation/Foundation.j>


cucumber_instance = nil;
cucumber_objects = nil;
cucumber_counter = 0;

function addCucumberObject(obj) {	
	cucumber_objects[cucumber_counter++] = obj;
	
	return cucumber_counter;
}

function dumpGuiObject(obj, padding) {
	var resultingXML = [CPMutableString stringWithFormat:"\n<%s>", [obj className]];
	[resultingXML appendFormat: "\n\t<id>%@</id>", addCucumberObject(obj)];

	if ([obj respondsToSelector:@selector(text)])
	{
		[resultingXML appendFormat:"\n%@\t<text><![CDATA[%@]]></text>", padding, [text text]];
	}
	if ([obj respondsToSelector:@selector(title)])
	{
		[resultingXML appendFormat:"\n%@\t<title><![CDATA[%@]]></title>", padding, [obj title]];
	}
	if ([obj respondsToSelector:@selector(currentTitle)])
	{
		[resultingXML appendFormat:"\n%@\t<currentTitle><![CDATA[%@]]></currentTitle>", padding, [obj currentTitle]];
	}
	if ([obj respondsToSelector:@selector(isKeyWindow)])
	{
		if([obj isKeyWindow]) {
			[resultingXML appendFormat:"\n%@\t<keyWindow>YES</keyWindow>", padding];
		}
		else {
			[resultingXML appendFormat:"\n%@\t<keyWindow>NO</keyWindow>", padding];
		}
	}

	var frame = [obj frame];
	[resultingXML appendFormat:"\n%@\t<frame>", padding];
	[resultingXML appendFormat:"\n%@\t\t<x>%f</x>", padding, frame.origin.x];
	[resultingXML appendFormat:"\n%@\t\t<y>%f</y>", padding, frame.origin.y];
	[resultingXML appendFormat:"\n%@\t\t<width>%f</width>", padding, frame.size.width];
	[resultingXML appendFormat:"\n%@\t\t<height>%f</height>", padding, frame.size.height];
	[resultingXML appendFormat:"\n%@\t</frame>", padding];
	
	if([obj respondsToSelector: @selector(subviews)]) {
		var views = [obj subviews];
		if(views.count > 0) {
			[resultingXML appendFormat:"\n%@\t<subviews>", padding];
			for (var i=0; i<views.length; i++) {
				var subview = views[i];
				[resultingXML appendString: dumpGuiObject(subView, [NSString stringWithFormat:"%@\t\t", padding])];
			}
			[resultingXML appendFormat:"\n%@\t</subviews>", padding];
		}
		else {
			[resultingXML appendFormat:"\n%@\t<subviews />", padding];
		}
	}

	if([obj respondsToSelector: @selector(contentView)]) {
		[resultingXML appendFormat:"\n%@\t<contentView>", padding];
		[resultingXML appendString: dumpGuiObject([obj contentView], [NSString stringWithFormat:"%@\t\t", padding])];
		[resultingXML appendFormat:"\n%@\t</contentView>", padding];
	}
	[resultingXML appendFormat:"\n</%s>", [obj className]];
	
	return resultingXML;
}

@implementation Cucumber : CPObject
{
	BOOL requesting;
}

+ (void) startCucumber {
	if(cucumber_instance==nil) {
		 [[Cucumber alloc] init];
		
		console.info("Starting");
		[cucumber_instance startRequest];
	}
}

- (id) init {
	self = [super init];
	
	if(self) {
		// initialization code here
		cucumber_instance = self;
		requesting = true;
	}
	
	return self;
}

- (void) startRequest {
	requesting = YES;
	var request = [[CPURLRequest alloc] initWithURL: "/cucumber"];
	[request setHTTPMethod: "GET"];

	[CPURLConnection connectionWithRequest: request delegate: self];
}

- (void) startResponse:(id)result {
	requesting = NO;
	var request = [[CPURLRequest alloc] initWithURL: "/cucumber"];
	[request setHTTPMethod: "POST"];
	[request setHTTPBody: [CPString JSONFromObject: result]];

	[CPURLConnection connectionWithRequest: request delegate: self];
}

#pragma mark -
#pragma mark connection delegate methods

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
	if(requesting) {
		var result = nil;
		
		if(data!=null && data!="") {
			var request = [data objectFromJSON];
		
			if(request) {
				var msg = CPSelectorFromString(request.name+":");
				
				if([self respondsToSelector: msg]) {
					result = [self performSelector: msg withObject: request.params];
				} else if([[CPApp delegate] respondsToSelector: msg]) {
					result = [[CPApp delegate] performSelector: msg withObject: request.params];
				} else {
					console.warn("Unhandled message: "+request.name);
				}
			}
		}

		[self startResponse: result];
	} else {
		[self startRequest];
	}
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
	console.info("THERE");
}

#pragma mark -
#pragma mark Cucumber actions

- (CPString) outputView:(CPDictionary) params {
	return [CPApp xmlDescription];
}

@end

[Cucumber startCucumber];

#pragma mark -
#pragma mark support stuff

@implementation CPObject (ClassName)

- (CPString)className {
	return CPStringFromClass([self class]);
}

+ (CPString)className {
	return CPStringFromClass(self);
}

@end

#pragma mark -
#pragma mark XML UI description

@implementation CPApplication (Cucumber)

- (CPString ) xmlDescription {	
	var resultingXML = [CPMutableString stringWithFormat:"\n<%s>", [self className]];
	[resultingXML appendFormat: "\n\t<id>%@</id>", addCucumberObject(self)];

	var windows = [self windows];
	if(windows.count > 0) {
		[resultingXML appendString:"\n\t<windows>"];
		for (var i=0; i<windows.length; i++) {
			[resultingXML appendString:[windows[i] xmlDescriptionWithStringPadding:"\t"]];
		}
		[resultingXML appendString:"\n\t</windows>"];
	}
	else {
		[resultingXML appendString:"\n\t<windows />"];
	}
	[resultingXML appendFormat:"\n</%s>", [self className]];
	return resultingXML;
}

@end

@implementation CPWindow (Cucumber)

- (CPString) xmlDescriptionWithStringPadding: (CPString) padding {
	return dumpGuiObject(obj, padding);
}

@end
