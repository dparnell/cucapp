@import <Foundation/CPObject.j>
@import "CalculatorController.j"

@implementation CalculatorController : CPObject
{
    CPWindow    theWindow;
	CPTextField output;
}

- (id) init {
	self = [super init];
	
	if(self) {
		[CPBundle loadCibNamed: "Calculator" owner: self];
	}
	
	return self;
}

- (IBAction) digitPressed:(CPButton)sender {
	var text = [output stringValue];
	text = text + [sender title];
	[output setStringValue: text];
}

@end