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
	cucumber_counter++;
	cucumber_objects[cucumber_counter] = obj;
	
	return cucumber_counter;
}

function dumpGuiObject(obj) {
	var resultingXML = "<"+[obj className]+">";
	resultingXML += "<id>"+addCucumberObject(obj)+"</id>";

	if ([obj respondsToSelector:@selector(text)])
	{
		resultingXML += "<text><![CDATA["+[obj text]+"]]></text>";
	}
	if ([obj respondsToSelector:@selector(title)])
	{
		resultingXML += "<title><![CDATA["+[obj title]+"]]></title>";
	}
	if ([obj respondsToSelector:@selector(isKeyWindow)])
	{
		if([obj isKeyWindow]) {
			resultingXML += "<keyWindow>YES</keyWindow>";
		}
		else {
			resultingXML += "<keyWindow>NO</keyWindow>";
		}
	}

	if([obj respondsToSelector: @selector(frame)]) {
		var frame = [obj frame];
		if(frame) {
			resultingXML += "<frame>";
			resultingXML += "<x>"+frame.origin.x+"</x>";
			resultingXML += "<y>"+frame.origin.y+"</y>";
			resultingXML += "<width>"+frame.size.width+"</width>";
			resultingXML += "<height>"+frame.size.height+"</height>";
			resultingXML += "</frame>";
		}
	}
	
	if([obj respondsToSelector: @selector(subviews)]) {
		var views = [obj subviews];
		if(views.length > 0) {
			resultingXML += "<subviews>";
			for (var i=0; i<views.length; i++) {
				var subview = views[i];
				resultingXML += dumpGuiObject(subview);
			}
			resultingXML += "</subviews>";
		}
		else {
			resultingXML += "<subviews/>";
		}
	}

	if([obj respondsToSelector: @selector(contentView)]) {
		resultingXML += "<contentView>";
		resultingXML += dumpGuiObject([obj contentView]);
		resultingXML += "</contentView>";
	}
	resultingXML += "</"+[obj className]+">";
	
	return resultingXML;
}

@implementation Cucumber : CPObject
{
	BOOL requesting;
	BOOL time_to_die;
}

+ (void) startCucumber {
	if(cucumber_instance==nil) {
		 [[Cucumber alloc] init];
		
		[cucumber_instance startRequest];
	}
}

- (id) init {
	self = [super init];
	
	if(self) {
		// initialization code here
		cucumber_instance = self;
		requesting = YES;
		time_to_die = NO;
	}
	
	return self;
}

- (void) startRequest {
	requesting = YES;
	var request = [[CPURLRequest alloc] initWithURL: "/cucumber"];
	[request setHTTPMethod: "GET"];

	[CPURLConnection connectionWithRequest: request delegate: self];
}

- (void) startResponse:(id)result withError:(CPString) error{
	requesting = NO;
	var request = [[CPURLRequest alloc] initWithURL: "/cucumber"];
	[request setHTTPMethod: "POST"];
	[request setHTTPBody: [CPString JSONFromObject: { result: result, error: error}]];

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
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{	
	if(requesting) {
		var result = nil;
		var error = nil;
		
		try {
			if(data!=null && data!="") {
				var request = [data objectFromJSON];
		
				if(request) {
					var msg = CPSelectorFromString(request.name+":");
				
					if([self respondsToSelector: msg]) {
						result = [self performSelector: msg withObject: request.params];
					} else if([[CPApp delegate] respondsToSelector: msg]) {
						result = [[CPApp delegate] performSelector: msg withObject: request.params];
					} else {
						error = "Unhandled message: "+request.name;
						console.warn(error);
					}
				}
			}
		} catch(e) {
			error = e.message;
		}
		
		[self startResponse: result withError: error];
	} else {
		if(time_to_die) {
			window.close();
		} else {
			[self startRequest];
		}
	}
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
}

#pragma mark -
#pragma mark Cucumber actions

- (CPString) restoreDefaults:(CPDictionary) params {
	if([[CPApp delegate] respondsToSelector: @selector(restoreDefaults:)]) {
		[[CPApp delegate] restoreDefaults: params];
	}
	
	return "OK";
}

- (CPString) outputView:(CPArray) params {
	cucumber_counter = 0;
	cucumber_objects = [];
	
	return [CPApp xmlDescription];
}

- (CPString) simulateTouch:(CPArray) params {
	var obj = cucumber_objects[params[0]];
	
	if(obj) {
		[obj performClick: self];
		return "OK";
	} else {
		return "NOT FOUND";
	}
}

- (CPString) closeBrowser:(CPArray) params {
	time_to_die = YES;
	return "OK";
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
	var resultingXML = "<"+[self className]+">";
	resultingXML += "<id>"+addCucumberObject(self)+"</id>";

	var windows = [self windows];
	if(windows.length > 0) {
		resultingXML += "<windows>";
		for (var i=0; i<windows.length; i++) {
			resultingXML += dumpGuiObject(windows[i]);
		}
		resultingXML += "</windows>";
	}
	else {
		resultingXML += "<windows />";
	}
	resultingXML += "</"+[self className]+">";
	return resultingXML;
}

@end
