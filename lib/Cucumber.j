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
	var resultingXML = "\n<"+[obj className]+">";
	resultingXML += "\n\t<id>"+addCucumberObject(obj)+"</id>";

	if ([obj respondsToSelector:@selector(text)])
	{
		resultingXML += "\n"+padding+"\t<text><![CDATA["+[obj text]+"]]></text>";
	}
	if ([obj respondsToSelector:@selector(title)])
	{
		resultingXML += "\n"+padding+"\t<title><![CDATA["+[obj title]+"]]></title>";
	}
	if ([obj respondsToSelector:@selector(isKeyWindow)])
	{
		if([obj isKeyWindow]) {
			resultingXML += "\n"+padding+"\t<keyWindow>YES</keyWindow>";
		}
		else {
			resultingXML += "\n"+padding+"\t<keyWindow>NO</keyWindow>";
		}
	}
/*
	var frame = [obj frame];
	[resultingXML appendFormat:"\n%@\t<frame>", padding];
	[resultingXML appendFormat:"\n%@\t\t<x>%f</x>", padding, frame.origin.x];
	[resultingXML appendFormat:"\n%@\t\t<y>%f</y>", padding, frame.origin.y];
	[resultingXML appendFormat:"\n%@\t\t<width>%f</width>", padding, frame.size.width];
	[resultingXML appendFormat:"\n%@\t\t<height>%f</height>", padding, frame.size.height];
	[resultingXML appendFormat:"\n%@\t</frame>", padding];
*/	
	if([obj respondsToSelector: @selector(subviews)]) {
		var views = [obj subviews];
		if(views.count > 0) {
			resultingXML += "\n"+padding+"\t<subviews>";
			for (var i=0; i<views.length; i++) {
				var subview = views[i];
				resultingXML += dumpGuiObject(subView, padding+"\t\t");
			}
			resultingXML += "\n"+padding+"\t</subviews>";
		}
		else {
			resultingXML += "\n"+padding+"\t<subviews/>";
		}
	}

	if([obj respondsToSelector: @selector(contentView)]) {
		resultingXML += "\n"+padding+"\t<contentView>";
		resultingXML += dumpGuiObject([obj contentView], padding+"\t\t");
		resultingXML += "\n"+padding+"\t</contentView>";
	}
	resultingXML += "\n</"+[obj className]+">";
	
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
	cucumber_counter = 0;
	cucumber_objects = [];
	
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
	var resultingXML = "\n<"+[self className]+">";
	resultingXML += "\n\t<id>"+addCucumberObject(self)+"</id>";

	var windows = [self windows];
	if(windows.count > 0) {
		resultingXML += "\n\t<windows>";
		for (var i=0; i<windows.length; i++) {
			resultingXML += [windows[i] xmlDescriptionWithStringPadding:"\t"];
		}
		resultingXML += "\n\t</windows>";
	}
	else {
		resultingXML += "\n\t<windows />";
	}
	resultingXML += "\n</"+[self className]+">";
	return resultingXML;
}

@end

@implementation CPWindow (Cucumber)

- (CPString) xmlDescriptionWithStringPadding: (CPString) padding {
	return dumpGuiObject(obj, padding);
}

@end
