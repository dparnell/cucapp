@import <Foundation/CPObject.j>
@import "CalculatorController.j"

@implementation CalculatorController : CPObject
{
    CPWindow    theWindow;
	CPTextField output;
	CPString    value;
	CPString    operation;
}

- (id) init {
	self = [super init];
	
	if(self) {
		[CPBundle loadCibNamed: "Calculator" owner: self];
		value = null;
		operation = null;
	}
	
	return self;
}

- (void) checkForOperation:(CPString)nextOperation {
	var result;
	
	if(operation && value) {
		result = eval(''+value+operation+[output stringValue]);
	} else {	
		value = [output stringValue];
	}
	
	if(nextOperation==null) {
		value = null;
		[output setStringValue: result];
	} else {
		[output setStringValue: '0'];
	}
	operation = nextOperation;
}

- (IBAction) digitPressed:(CPButton)sender {
	var text = [output stringValue];
	if(text=='0') {
		text = '';
	}
	
	text = text + [sender title];
	[output setStringValue: text];
}

- (IBAction) addPressed:(CPButton)sender {
	[self checkForOperation: "+"];
}

@end