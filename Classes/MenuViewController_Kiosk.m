//
//  MenuViewController_Kiosk.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MenuViewController_Kiosk.h"
#import "MFDocumentManager.h"
#import "DocumentViewController_Kiosk.h"
#import "MFHomeListPdf.h"
#import "XMLParser.h"
#include <stdio.h>
#include <stdlib.h>

@implementation MenuViewController_Kiosk

//@synthesize referenceButton, manualButton, referenceTextView, manualTextView;
//@synthesize document;
//@synthesize passwordAlertView;
//@synthesize downloadProgressView;
//@synthesize downloadProgressContainerView;
//@synthesize documentName;
@synthesize buttonRemoveDict;
@synthesize openButtons;
@synthesize progressViewDict,imgDict;
@synthesize documentsList;
@synthesize graphicsMode;


-(IBAction)actionOpenPlainDocument:(NSString *)documentName {
	
	MFDocumentManager * documentManager = nil;
	DocumentViewController_Kiosk * documentViewController = nil;
	
	NSArray *paths = nil;
	NSString *documentsDirectory = nil;
	NSString *pdfPath = nil;
	NSURL *documentUrl = nil;
	
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];
	pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",documentName]];
	documentUrl = [NSURL fileURLWithPath:pdfPath];
	
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class and use
	// it to initialize an MFDocumentViewController subclass 	
	
	documentManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
	
	documentViewController = [[DocumentViewController_Kiosk alloc]initWithDocumentManager:documentManager];
	documentViewController.documentId = documentName;
	
	[[self navigationController]pushViewController:documentViewController animated:YES];
	
	[documentViewController release];
	[documentManager release];
	
	
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		buttonRemoveDict = [[NSMutableDictionary alloc] init];
		openButtons = [[NSMutableDictionary alloc] init];
		progressViewDict = [[NSMutableDictionary alloc] init];
		imgDict = [[NSMutableDictionary alloc] init];
		
		homeListPdfs = [[NSMutableArray alloc]init];
		
	}
	
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	XMLParser *parser = nil;
	
	UIScrollView * aScrollView = nil;
	CGFloat yBorder = 0 ; 
	UIImageView * anImageView = nil;
	
	CGRect frame;
	NSString * titoloPdf = nil;
	NSString * linkPdf = nil;
	NSString * copertinaPdf = nil;
	MFHomeListPdf * viewPdf = nil;
	int documentsCount;
	
	//Graphics visualization
	
	CGFloat thumbWidth;
	CGFloat thumbHeight;
	CGFloat scrollViewWidth;
	CGFloat scrollViewHeight;
	CGFloat detailViewHeight;
	CGFloat thumbHOffsetLeft;
	CGFloat thumHOffsetRight;
	CGFloat frameHeight;
	CGFloat scrollViewVOffset;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		thumbWidth = 350.0;
		thumbHeight = 480.0;
		thumbHOffsetLeft = 20.0;
		thumHOffsetRight = 380.0;
		frameHeight = 325.0;
		scrollViewWidth = 771.0;
		scrollViewHeight = 875.0;
		detailViewHeight = 665.0;
		scrollViewVOffset = 130.0;
		
	} else {
		
		thumbWidth = 125.0;
		thumbHeight = 170.0;
		thumbHOffsetLeft = 10.0;
		thumHOffsetRight = 160.0;
		frameHeight = 115.0;
		scrollViewWidth = 323.0;
		scrollViewHeight = 404.0;
		detailViewHeight = 240.0;
		scrollViewVOffset = 60.0;
	}
	
	
	parser = [[XMLParser alloc] init];
	parser.menuViewController = self;
	[parser parseXMLFileAtURL:DEF_XML_URL];
	
	self.documentsList = [parser documents];
	
	[parser release];
	
	documentsCount = [documentsList count]; 
	
	
	aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollViewVOffset, scrollViewWidth, scrollViewHeight)];
	aScrollView.backgroundColor = [UIColor whiteColor];
	aScrollView.contentSize = CGSizeMake(scrollViewWidth, detailViewHeight * ((documentsCount/2)+1));
	
    int i;
	for (i=1; i<= documentsCount ; i++) {
		
		titoloPdf = [[documentsList objectAtIndex: i-1] objectForKey: @"title"];
		linkPdf = [[documentsList objectAtIndex: i-1] objectForKey: @"link"];
		copertinaPdf = [[documentsList objectAtIndex: i-1] objectForKey: @"cover"];
		viewPdf = [[MFHomeListPdf alloc] initWithName:titoloPdf andLinkPdf:linkPdf andnumOfDoc:i andImage:copertinaPdf andSize:CGSizeMake(thumbWidth, thumbHeight)];
		
		frame = self.view.frame;
		
		if ((i%2)==0) {
			frame.origin.y = (frameHeight * 2 ) * ( (i-1) / 2 );
			frame.origin.x = thumHOffsetRight;
			frame.size.width = thumbWidth;
			frame.size.height = detailViewHeight;
		}else {
			frame.origin.y = frameHeight *(i-1);
			frame.origin.x = thumbHOffsetLeft;
			frame.size.width = thumbWidth;
			frame.size.height = detailViewHeight;
		}
		
		viewPdf.view.frame = frame;
		viewPdf.menuViewController = self;
		[aScrollView addSubview:viewPdf.view];
		
		// Adding stuff to their respective containers.
		
		[imgDict setValue:viewPdf.openButtonFromImage forKey:titoloPdf];
		[openButtons setValue:viewPdf.openButton forKey:titoloPdf];
		[buttonRemoveDict setValue:viewPdf.removeButton forKey:titoloPdf];
		[progressViewDict setValue:viewPdf.progressDownload forKey:titoloPdf];
		
		[homeListPdfs addObject:viewPdf];
		[viewPdf release];
		
	}
	
	[self.view addSubview:aScrollView];
	// self.scrollView = aScrollView; // Not referenced anywhere else.
	[aScrollView release];
	
	// Border.
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		yBorder = scrollViewVOffset-3 ;
	}else {
		yBorder = scrollViewVOffset-1 ;
	}
	
	anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yBorder, scrollViewWidth, 40)]; 
	[anImageView setImage:[UIImage imageNamed:@"border.png"]];
	[self.view addSubview:anImageView];
	[anImageView release];
	
}

//-(void)showViewDownload{
//	
//	downloadProgressContainerView.hidden = NO;
//	
//	[UIView beginAnimations:@"show" context:NULL];
//	[UIView setAnimationDuration:0.10];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//	[downloadProgressContainerView setFrame:CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width, 200)];
//	[UIView commitAnimations];
//}
//
//-(void)hideViewDownload{
//	
//	[UIView beginAnimations:@"show" context:NULL];
//	[UIView setAnimationDuration:0.35];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//	[downloadProgressContainerView setFrame:CGRectMake(0, downloadProgressContainerView.frame.origin.y+downloadProgressContainerView.frame.size.height, downloadProgressContainerView.frame.size.width, downloadProgressContainerView.frame.size.height)];
//	[UIView commitAnimations];
//}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if(interfaceOrientation == UIDeviceOrientationPortrait){
		return YES;
	}else {
		return NO;
	}
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	//[self setManualButton:nil];
//	[self setManualTextView:nil];
//	[self setReferenceButton:nil];
//	[self setReferenceTextView:nil];
	
	[buttonRemoveDict removeAllObjects];
	[openButtons removeAllObjects];
	[progressViewDict removeAllObjects];
	[imgDict removeAllObjects];
	[homeListPdfs removeAllObjects];
	
}


- (void)dealloc {
	
	//[referenceButton release];
//	[manualButton release];
//	[referenceTextView release];
	
	[documentsList release];
	
	[buttonRemoveDict release];
	[openButtons release];
	[progressViewDict release];
	[imgDict release];
	
	[homeListPdfs release];
	
    [super dealloc];
}

@end
