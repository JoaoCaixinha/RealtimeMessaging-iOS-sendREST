//
//  ViewController.h
//  Ortc-iOS-Send-Rest
//
//  Created by admin on 12/10/15.
//  Copyright © 2015 realtime.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OrtcClient.h>

@interface ViewController : UIViewController<UITableViewDataSource, OrtcClientDelegate, NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableLog;
@property (weak, nonatomic) IBOutlet UITextField *textMsg;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property(retain, nonatomic) OrtcClient *client;
@property(retain, nonatomic) NSMutableArray *logs;
@property(retain, nonatomic) id onMessage;

- (IBAction)sendMSG:(UIButton *)sender;
@end

