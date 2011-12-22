//
//  SHKVkontakteForm.m
//  ShareKit
//
//  Created by Alterplay Team on 06.12.11.
//  Based on https://github.com/maiorov/VKAPI
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKVkontakteForm.h"
#import "SHKVkontakte.h"
#import "SHK.h"

@implementation SHKVkontakteForm

@synthesize delegate;
@synthesize textView;

- (void)dealloc 
{
	[textView release];
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{		
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																																													 target:self
																																													 action:@selector(cancel)] autorelease];
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:SHKLocalizedString(@"Send to %@", [SHKVkontakte sharerTitle]) 
																																							 style:UIBarButtonItemStyleDone
																																							target:self
																																							action:@selector(save)] autorelease];
	}
	return self;
}

- (void)loadView 
{
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.textView = [[[UITextView alloc] initWithFrame:self.view.bounds] autorelease];
	textView.delegate = self;
	textView.font = [UIFont systemFontOfSize:15];
	textView.contentInset = UIEdgeInsetsMake(5,5,0,0);
	textView.backgroundColor = [UIColor whiteColor];	
	textView.autoresizesSubviews = YES;
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self.view addSubview:textView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];	
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
	
	[self.textView becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];	
	
	// Remove observers
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name: UIKeyboardWillShowNotification object:nil];
	
	// Remove the SHK view wrapper from the window
	[[SHK currentHelper] viewWasDismissed];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return YES;
}

//#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)keyboardWillShow:(NSNotification *)notification
{	
	CGRect keyboardFrame;
	CGFloat keyboardHeight;
	
	// 3.2 and above
	/*if (UIKeyboardFrameEndUserInfoKey)
	 {		
	 [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];		
	 if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) 
	 keyboardHeight = keyboardFrame.size.height;
	 else
	 keyboardHeight = keyboardFrame.size.width;
	 }
	 
	 // < 3.2
	 else 
	 {*/
	
	[[notification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardFrame];
	keyboardHeight = keyboardFrame.size.height;
	//}
	
	// Find the bottom of the screen (accounting for keyboard overlay)
	// This is pretty much only for pagesheet's on the iPad
	UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
	BOOL inLandscape = orient == UIInterfaceOrientationLandscapeLeft || orient == UIInterfaceOrientationLandscapeRight;
	BOOL upsideDown = orient == UIInterfaceOrientationPortraitUpsideDown || orient == UIInterfaceOrientationLandscapeRight;
	
	CGPoint topOfViewPoint = [self.view convertPoint:CGPointZero toView:nil];
	CGFloat topOfView = inLandscape ? topOfViewPoint.x : topOfViewPoint.y;
	
	CGFloat screenHeight = inLandscape ? [[UIScreen mainScreen] applicationFrame].size.width : [[UIScreen mainScreen] applicationFrame].size.height;
	
	CGFloat distFromBottom = screenHeight - ((upsideDown ? screenHeight - topOfView : topOfView ) + self.view.bounds.size.height) + ([UIApplication sharedApplication].statusBarHidden || upsideDown ? 0 : 20);							
	CGFloat maxViewHeight = self.view.bounds.size.height - keyboardHeight + distFromBottom;
	
	textView.frame = CGRectMake(0,0,self.view.bounds.size.width,maxViewHeight);
}
//#pragma GCC diagnostic pop  

#pragma mark -

- (void)cancel
{	
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
	[(SHKVkontakte *)delegate sendDidCancel];
}

- (void)save
{	
	if (textView.text.length == 0)
	{
		[[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Message is empty")
																 message:SHKLocalizedString(@"You must enter a message in order to post.")
																delegate:nil
											 cancelButtonTitle:SHKLocalizedString(@"Close")
											 otherButtonTitles:nil] autorelease] show];
		return;
	}
	
	[(SHKVkontakte *)delegate sendForm:self];
	
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
}

@end