@STATIC;1.0;p;10;Cucumber.jt;8048;@STATIC;1.0;I;23;Foundation/Foundation.jt;8001;objj_executeFile("Foundation/Foundation.j", NO);
cucumber_instance = nil;
cucumber_objects = nil;
cucumber_counter = 0;
addCucumberObject= function(obj) {
 cucumber_counter++;
 cucumber_objects[cucumber_counter] = obj;
 return cucumber_counter;
}
dumpGuiObject= function(obj) {
 var resultingXML = "<"+objj_msgSend(obj, "className")+">";
 resultingXML += "<id>"+addCucumberObject(obj)+"</id>";
 if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("text")))
 {
  resultingXML += "<text><![CDATA["+objj_msgSend(obj, "text")+"]]></text>";
 }
 if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("title")))
 {
  resultingXML += "<title><![CDATA["+objj_msgSend(obj, "title")+"]]></title>";
 }
 if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("isKeyWindow")))
 {
  if(objj_msgSend(obj, "isKeyWindow")) {
   resultingXML += "<keyWindow>YES</keyWindow>";
  }
  else {
   resultingXML += "<keyWindow>NO</keyWindow>";
  }
 }
 if(objj_msgSend(obj, "respondsToSelector:",  sel_getUid("frame"))) {
  var frame = objj_msgSend(obj, "frame");
  if(frame) {
   resultingXML += "<frame>";
   resultingXML += "<x>"+frame.origin.x+"</x>";
   resultingXML += "<y>"+frame.origin.y+"</y>";
   resultingXML += "<width>"+frame.size.width+"</width>";
   resultingXML += "<height>"+frame.size.height+"</height>";
   resultingXML += "</frame>";
  }
 }
 if(objj_msgSend(obj, "respondsToSelector:",  sel_getUid("subviews"))) {
  var views = objj_msgSend(obj, "subviews");
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
 if(objj_msgSend(obj, "respondsToSelector:",  sel_getUid("contentView"))) {
  resultingXML += "<contentView>";
  resultingXML += dumpGuiObject(objj_msgSend(obj, "contentView"));
  resultingXML += "</contentView>";
 }
 resultingXML += "</"+objj_msgSend(obj, "className")+">";
 return resultingXML;
}
{var the_class = objj_allocateClassPair(CPObject, "Cucumber"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("requesting"), new objj_ivar("time_to_die")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("init"), function $Cucumber__init(self, _cmd)
{ with(self)
{
 self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("Cucumber").super_class }, "init");
 if(self) {
  cucumber_instance = self;
  requesting = YES;
  time_to_die = NO;
 }
 return self;
}
},["id"]), new objj_method(sel_getUid("startRequest"), function $Cucumber__startRequest(self, _cmd)
{ with(self)
{
 requesting = YES;
 var request = objj_msgSend(objj_msgSend(CPURLRequest, "alloc"), "initWithURL:",  "/cucumber");
 objj_msgSend(request, "setHTTPMethod:",  "GET");
 objj_msgSend(CPURLConnection, "connectionWithRequest:delegate:",  request,  self);
}
},["void"]), new objj_method(sel_getUid("startResponse:withError:"), function $Cucumber__startResponse_withError_(self, _cmd, result, error)
{ with(self)
{
 requesting = NO;
 var request = objj_msgSend(objj_msgSend(CPURLRequest, "alloc"), "initWithURL:",  "/cucumber");
 objj_msgSend(request, "setHTTPMethod:",  "POST");
 objj_msgSend(request, "setHTTPBody:",  objj_msgSend(CPString, "JSONFromObject:",  { result: result, error: error}));
 objj_msgSend(CPURLConnection, "connectionWithRequest:delegate:",  request,  self);
}
},["void","id","CPString"]), new objj_method(sel_getUid("connection:didFailWithError:"), function $Cucumber__connection_didFailWithError_(self, _cmd, connection, error)
{ with(self)
{
 CPLog.error("Connection failed");
}
},["void","CPURLConnection","id"]), new objj_method(sel_getUid("connection:didReceiveResponse:"), function $Cucumber__connection_didReceiveResponse_(self, _cmd, connection, response)
{ with(self)
{
}
},["void","CPURLConnection","CPHTTPURLResponse"]), new objj_method(sel_getUid("connection:didReceiveData:"), function $Cucumber__connection_didReceiveData_(self, _cmd, connection, data)
{ with(self)
{
 if(requesting) {
  var result = nil;
  var error = nil;
  try {
   if(data!=null && data!="") {
    var request = objj_msgSend(data, "objectFromJSON");
    if(request) {
     var msg = CPSelectorFromString(request.name+":");
     if(objj_msgSend(self, "respondsToSelector:",  msg)) {
      result = objj_msgSend(self, "performSelector:withObject:",  msg,  request.params);
     } else if(objj_msgSend(objj_msgSend(CPApp, "delegate"), "respondsToSelector:",  msg)) {
      result = objj_msgSend(objj_msgSend(CPApp, "delegate"), "performSelector:withObject:",  msg,  request.params);
     } else {
      error = "Unhandled message: "+request.name;
      console.warn(error);
     }
    }
   }
  } catch(e) {
   error = e.message;
  }
  objj_msgSend(self, "startResponse:withError:",  result,  error);
 } else {
  if(time_to_die) {
   window.close();
  } else {
   objj_msgSend(self, "startRequest");
  }
 }
}
},["void","CPURLConnection","CPString"]), new objj_method(sel_getUid("connectionDidFinishLoading:"), function $Cucumber__connectionDidFinishLoading_(self, _cmd, connection)
{ with(self)
{
}
},["void","CPURLConnection"]), new objj_method(sel_getUid("restoreDefaults:"), function $Cucumber__restoreDefaults_(self, _cmd, params)
{ with(self)
{
 if(objj_msgSend(objj_msgSend(CPApp, "delegate"), "respondsToSelector:",  sel_getUid("restoreDefaults:"))) {
  objj_msgSend(objj_msgSend(CPApp, "delegate"), "restoreDefaults:",  params);
 }
 return "OK";
}
},["CPString","CPDictionary"]), new objj_method(sel_getUid("outputView:"), function $Cucumber__outputView_(self, _cmd, params)
{ with(self)
{
 cucumber_counter = 0;
 cucumber_objects = [];
 return objj_msgSend(CPApp, "xmlDescription");
}
},["CPString","CPArray"]), new objj_method(sel_getUid("simulateTouch:"), function $Cucumber__simulateTouch_(self, _cmd, params)
{ with(self)
{
 var obj = cucumber_objects[params[0]];
 if(obj) {
  objj_msgSend(obj, "performClick:",  self);
  return "OK";
 } else {
  return "NOT FOUND";
 }
}
},["CPString","CPArray"]), new objj_method(sel_getUid("closeBrowser:"), function $Cucumber__closeBrowser_(self, _cmd, params)
{ with(self)
{
 time_to_die = YES;
 return "OK";
}
},["CPString","CPArray"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("startCucumber"), function $Cucumber__startCucumber(self, _cmd)
{ with(self)
{
 if(cucumber_instance==nil) {
   objj_msgSend(objj_msgSend(Cucumber, "alloc"), "init");
  objj_msgSend(cucumber_instance, "startRequest");
 }
}
},["void"])]);
}
objj_msgSend(Cucumber, "startCucumber");
       
       
{
var the_class = objj_getClass("CPObject")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CPObject\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("className"), function $CPObject__className(self, _cmd)
{ with(self)
{
 return CPStringFromClass(objj_msgSend(self, "class"));
}
},["CPString"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("className"), function $CPObject__className(self, _cmd)
{ with(self)
{
 return CPStringFromClass(self);
}
},["CPString"])]);
}
       
       
{
var the_class = objj_getClass("CPApplication")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CPApplication\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("xmlDescription"), function $CPApplication__xmlDescription(self, _cmd)
{ with(self)
{
 var resultingXML = "<"+objj_msgSend(self, "className")+">";
 resultingXML += "<id>"+addCucumberObject(self)+"</id>";
 var windows = objj_msgSend(self, "windows");
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
 resultingXML += "</"+objj_msgSend(self, "className")+">";
 return resultingXML;
}
},["CPString"])]);
}

e;