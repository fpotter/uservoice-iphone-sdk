//
//  UVFooterView.m
//  UserVoice
//
//  Created by Mirko Froehlich on 1/12/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVFooterView.h"
#import "UVBaseViewController.h"
#import "UVUser.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVProfileViewController.h"
#import "UVSignInViewController.h"
#import "UVInfoViewController.h"
#import "UVNewMessageViewController.h"
#import "UVSuggestion.h"
#import "UVSubdomain.h"

#define UV_FOOTER_TAG_NAME_VIEW 1
#define UV_FOOTER_TAG_NAME_LABEL 2
#define UV_FOOTER_TAG_NAME_ICON 3

@implementation UVFooterView

@synthesize controller;
@synthesize tableView;

- (void)infoButtonTapped {
	UVInfoViewController *next = [[UVInfoViewController alloc] init];
	[self.controller.navigationController pushViewController:next animated:YES];
	[next release];
}

+ (CGFloat)heightForFooter {
	return 118 + 42; // actual cells and padding + table footer
}

+ (UVFooterView *)footerViewForController:(UVBaseViewController *)controller {
	UVFooterView *footer = [[[UVFooterView alloc ]initWithFrame:CGRectMake(0, 0, 320, [UVFooterView heightForFooter])] autorelease];
	footer.controller = controller;
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:footer.bounds style:UITableViewStyleGrouped];
	theTableView.scrollEnabled = NO;
	theTableView.delegate = footer;
	theTableView.dataSource = footer;
	theTableView.sectionHeaderHeight = 0.0;
	theTableView.sectionFooterHeight = 10.0;
	theTableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)] autorelease];
	
	UIView *tableFooter = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)] autorelease];
	UILabel *poweredBy = [[[UILabel alloc] initWithFrame:CGRectMake(40, 10, 240, 14)] autorelease];
	poweredBy.text = @"Feedback powered by UserVoice";
	poweredBy.font = [UIFont systemFontOfSize:14.0];
	poweredBy.textColor = [UIColor colorWithRed:0.278 green:0.341 blue:0.435 alpha:1.0];
	poweredBy.backgroundColor = [UIColor clearColor];
	poweredBy.textAlignment = UITextAlignmentCenter;
	[tableFooter addSubview:poweredBy];
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	infoButton.center = CGPointMake(295, 14);
	[infoButton addTarget:footer action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[tableFooter addSubview:infoButton];
	
	theTableView.tableFooterView = tableFooter;
	
	footer.tableView = theTableView;
	[footer addSubview:theTableView];
	[theTableView release];
	
	return footer;
}

- (void)reloadFooter {
	[self.tableView reloadData];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if ([UVSession currentSession].clientConfig.subdomain.messagesEnabled && indexPath.section == 0) {
		cell.textLabel.text = [NSString stringWithFormat:@"Contact %@", [UVSession currentSession].clientConfig.subdomain.name];
		// cell.textLabel.text = [NSString stringWithFormat:@"Contact Support"];
		
	} else {
		if ([UVSession currentSession].loggedIn) {
			cell.textLabel.text = @"My profile";
			UIView *nameView = [[[UIView alloc] initWithFrame:CGRectMake(100, 13, 170, 18)] autorelease];
			UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 2, 170, 14)] autorelease];
			nameLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
			nameLabel.textAlignment = UITextAlignmentRight;
			nameLabel.font = [UIFont systemFontOfSize:14.0];
			nameLabel.text = [[UVSession currentSession].user nameOrAnonymous];
			[nameView addSubview:nameLabel];
			
			if ([[UVSession currentSession].user hasUnconfirmedEmail]) {
				UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_alert.png"]];
				icon.frame = CGRectMake(156, 0, 18, 18);
				[nameView addSubview:icon];
				[icon release];
				
				// Shrink label to make space for the image
				CGRect labelFrame = nameLabel.frame;
				nameLabel.frame = CGRectMake(labelFrame.origin.x, labelFrame.origin.y, labelFrame.size.width - 23, labelFrame.size.height);
			}
			[cell.contentView addSubview:nameView];
		} else {
			cell.textLabel.text = @"Sign in";
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}			
	}
	return cell;	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	if ([UVSession currentSession].clientConfig.subdomain.messagesEnabled) {
		return 2;
	} else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UIViewController *next = nil;
	if ([UVSession currentSession].clientConfig.subdomain.messagesEnabled && indexPath.section == 0) {
		next = [[UVNewMessageViewController alloc] init];
	} else {
		if ([UVSession currentSession].loggedIn) {
			UVUser *user = [UVSession currentSession].user;			
			next = [[UVProfileViewController alloc] initWithUVUser:user];
		} else {
			next = [[UVSignInViewController alloc] init];
		}
	}

	if (next) {
		[self.controller.navigationController pushViewController:next animated:YES];
		[next release];
	}
}

@end
