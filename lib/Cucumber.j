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
	if(obj) {
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
		if ([obj respondsToSelector:@selector(tag)])
		{
		    resultingXML += "<tag><![CDATA["+[obj tag]+"]]></tag>";
		}
		if ([obj respondsToSelector:@selector(isKeyWindow)])
		{
			if([obj isKeyWindow]) {
				resultingXML += "<keyWindow>YES</keyWindow>";
			}
		}
		if ([obj respondsToSelector:@selector(title)])
		{
			resultingXML += "<title><![CDATA["+[obj title]+"]]></title>";
		}
		if ([obj respondsToSelector:@selector(objectValue)])
		{
			resultingXML += "<objectValue><![CDATA["+[CPString stringWithFormat: "%@", [obj objectValue]]+"]]></objectValue>";
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
			if(views && views.length > 0) {
				resultingXML += "<subviews>";
				for (var i=0; i<views.length; i++) {
					resultingXML += dumpGuiObject(views[i]);
				}
				resultingXML += "</subviews>";
			}
			else {
				resultingXML += "<subviews/>";
			}
		}

		if([obj respondsToSelector: @selector(itemArray)]) {
			var items = [obj itemArray];
			if(items && items.length>0) {
				resultingXML += "<items>";
				for (var i=0; i<items.length; i++) {
					resultingXML += dumpGuiObject(items[i]);
				}
				resultingXML += "</items>";
			} else {
				resultingXML += "<items/>";
			}
		}
	
		if([obj respondsToSelector: @selector(submenu)]) {
			var submenu = [obj submenu];
			if(submenu!=null) {
				resultingXML += dumpGuiObject(submenu);
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
	
	return '';
}

@implementation Cucumber : CPObject
{
	BOOL requesting;
	BOOL time_to_die;
	BOOL launched;
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
		launched = NO;
		
		[[CPNotificationCenter defaultCenter]
		    addObserver:self
		    selector:@selector(applicationDidFinishLaunching:)
		    name:CPApplicationDidFinishLaunchingNotification
		    object:nil];
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

- (CPString) closeWindow:(CPArray) params {
	var obj = cucumber_objects[params[0]];
	
	if(obj) {
		[obj performClose: self];
		return "OK";
	} else {
		return "NOT FOUND";
	}
}

- (CPString) performMenuItem:(CPArray) params {
	var obj = cucumber_objects[params[0]];
	
	if(obj) {
		[[obj target] performSelector: [obj action] withObject: obj];
		
		return "OK";
	} else {
		return "NOT FOUND";
	}
}

- (CPString) closeBrowser:(CPArray) params {
	time_to_die = YES;
	return "OK";
}

- (CPString)launched:(CPArray)params {	
    if(launched || CPApp._finishedLaunching) {
        return "YES";
    }
    
    return "NO";
}

- (CPString)selectFrom:(CPArray)params {
    var obj = cucumber_objects[params[1]];
    
    if(obj) {
        var columns = [obj tableColumns];
        
        if([[obj dataSource] respondsToSelector:@selector(tableView:objectValueForTableColumn:row:)])
            for(var i = 0; i < [columns count]; i++) {
                var column = columns[i];
                for(var j = 0; j < [obj numberOfRows]; j++) {
                    var data = [[obj dataSource] tableView:obj
                        objectValueForTableColumn:column
                        row:j];
                        
                    [obj selectRowIndexes:[CPIndexSet indexSetWithIndex:j] byExtendingSelection:NO];
                    
                    if(data === params[0]) {
                        return "OK";
                    }
                }
        }
        
        if([[obj dataSource] respondsToSelector:@selector(outlineView:numberOfChildrenOfItem:)])
            if([self searchForObjectValue:params[0] inItemsInOutlineView:obj forItem:nil])
                return "OK";
                
        return "DATA NOT FOUND";
    } else {
        return "OBJECT NOT FOUND";
    }
}

- (BOOL)searchForObjectValue:(id)value inItemsInOutlineView:(CPOutlineView)obj forItem:(id)item {
    for(var i = 0; i < [[obj dataSource] outlineView:obj numberOfChildrenOfItem:item]; i++) {
        var child = [[obj dataSource] outlineView:obj child:i ofItem:item];
        var testValue = [[obj dataSource] outlineView:obj objectValueForTableColumn:nil byItem:child];
        
        if(testValue === value) {
            return YES;
        }
        
        if([self searchForObjectValue:value inItemsInOutlineView:obj forItem:child]) {
            var index = [obj rowForItem:value];
            
            [obj selectRowIndexes:[CPIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
            
            return YES;
        }
    }
    
    return NO;
}

- (CPString)selectMenu:(CPArray)params {
    var obj = [CPApp mainMenu];
    
    if(obj) {
        var item = [obj itemWithTitle:params[0]];
        
        if(item) {
            return "OK";
        } else {
            return "MENU ITEM NOT FOUND";
        }
    } else {
        return "MENU NOT FOUND";
    }
}

- (CPString)findIn:(CPArray)params {
    return [self selectFrom:params];
}

- (CPString)textFor:(CPArray)params {
    var obj = cucumber_objects[params[0]];
    
    if(obj) {
        if([obj respondsToSelector:@selector(stringValue)]) {
            return [obj stringValue];
        } else {
            return "__CUKE_ERROR__";
        }
    } else {
        return "__CUKE_ERROR__";
    }
}

- (CPString)doubleClick:(CPArray)params {
    var obj = cucumber_objects[params[0]];
    
    if(obj) {
        if([obj respondsToSelector:@selector(doubleAction)] && [obj doubleAction] !== null) {
            [[obj target] performSelector:[obj doubleAction] withObject:self];
            
            return "OK";
        } else {
            return "NO DOUBLE ACTION";
        }
    } else {
        return "OBJECT NOT FOUND";
    }
}

- (CPString)setText:(CPArray)params {
    var obj = cucumber_objects[params[1]];
    
    if(obj) {
        if([obj respondsToSelector:@selector(setStringValue:)]) {
            [obj setStringValue:params[0]];
            [self propagateValue:[obj stringValue] forBinding:"value" forObject:obj];
            return "OK";
        } else {
            return "CANNOT SET TEXT ON OBJECT";
        }
    } else {
        return "OBJECT NOT FOUND";
    }
}

-(void) propagateValue:(id)value forBinding:(CPString)binding forObject:(id)aObject;
{

    //WARNING: bindingInfo contains CPNull, so it must be accounted for
    var bindingInfo = [aObject infoForBinding:binding];
    if(!bindingInfo)
        return; //there is no binding

    //apply the value transformer, if one has been set
    var bindingOptions = [bindingInfo objectForKey:CPOptionsKey];
    if(bindingOptions){
        var transformer = [bindingOptions valueForKey:CPValueTransformerBindingOption];
        if(!transformer || transformer == [CPNull null]){
            var transformerName = [bindingOptions valueForKey:CPValueTransformerNameBindingOption];
            if(transformerName && transformerName != [CPNull null]){
                transformer = [CPValueTransformer valueTransformerForName:transformerName];
            }
        }

        if(transformer && transformer != [CPNull null]){
            if([[transformer class] allowsReverseTransformation]){
                value = [transformer reverseTransformedValue:value];
            } else {
                CPLog(@"WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
            }
        }
    }

    var boundObject = [bindingInfo objectForKey:CPObservedObjectKey];
    if(!boundObject || boundObject == [CPNull null]){
        CPLog(@"ERROR: CPObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }

    var boundKeyPath = [bindingInfo objectForKey:CPObservedKeyPathKey];
    if(!boundKeyPath || boundKeyPath == [CPNull null]){
        CPLog(@"ERROR: CPObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }

    [boundObject setValue:value forKeyPath:boundKeyPath];
}

- (void)applicationDidFinishLaunching:(CPNotification)note {
    launched = YES;
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
	var menu = [self mainMenu];
	if(menu) {
		resultingXML += "<menus>";
		resultingXML += dumpGuiObject(menu);
		resultingXML += "</menus>";
	} else {
		resultingXML += "<menus/>";
	}
	resultingXML += "</"+[self className]+">";
	return resultingXML;
}

@end
