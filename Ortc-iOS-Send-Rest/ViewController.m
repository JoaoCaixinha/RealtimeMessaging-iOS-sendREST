//
//  ViewController.m
//  Ortc-iOS-Send-Rest
//
//  Created by admin on 12/10/15.
//  Copyright © 2015 realtime.co. All rights reserved.
//

#import "ViewController.h"





//----------------- OrtcClient configuration -----------------
#define APP_KEY @"YLJ7kz"
#define TOKEN @"myAuthenticationToken"
#define CLUSTER_URL @"https://ortc-developers.realtime.co/server/ssl/2.1/"
#define METADATA @"clientConnMeta"
#define CHANNEL @"yellow"
//----------------- OrtcClient configuration -----------------







@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _logs = [[NSMutableArray alloc] init];
    
    
    _sendButton.enabled = NO;
    [_sendButton setTitle:@"Not connected" forState:UIControlStateDisabled];
    
    [self setOrtcClient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)sendMSG:(UIButton *)sender {
    [self sendMsgREST:_textMsg.text url:_client.url callback:^(bool sent) {
        if(sent){
            [self appendToLog:[NSString stringWithFormat:@"REST send MSG: %@, SUCCESS", _textMsg.text]];
        }else{
            [self appendToLog:[NSString stringWithFormat:@"REST send MSG: %@, FAIL", _textMsg.text]];
        }
    }];
}


- (void)appendToLog:(NSString*)log{
    [_logs addObject:log];
    [_tableLog reloadData];
    [_tableLog setNeedsDisplay];
}


//----------------- REST send -----------------

- (void)sendMsgREST:(NSString*)msg url:(NSString*)url callback:(void(^)(bool))isSent{
    url = [NSString stringWithFormat:@"%@/send", url];
    
    NSMutableString *params = [[NSMutableString alloc] init];
    [params appendFormat:@"AT=%@&", TOKEN];
    [params appendFormat:@"AK=%@&", APP_KEY];
    [params appendFormat:@"C=%@&", CHANNEL];
    [params appendFormat:@"M=%@&", msg];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // handle basic connectivity issues here
        
        if (error) {
            isSent(NO);
            return;
        }
        
        // handle HTTP errors here
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200 && statusCode != 201) {
                isSent(NO);
                return;
            }
            isSent(YES);
        }
    }];
    
    [postDataTask resume];
}

//----------------- / REST send -----------------



//----------------- OrtcClient configuration -----------------

- (void)setOrtcClient{
    _client = [OrtcClient ortcClientWithConfig:self];
    [_client setConnectionMetadata:METADATA];
    [_client setClusterUrl:CLUSTER_URL];
    [_client connect:APP_KEY authenticationToken:TOKEN];
}

- (void) onConnected:(OrtcClient*) ortc
{
    __weak typeof(self) weakSelf = self;
   
    _onMessage = ^(OrtcClient* ortc, NSString* channel, NSString* message) {
        [weakSelf appendToLog:[NSString stringWithFormat:@"iOS SDK received msg: %@, on channel: %@", message, channel]];
    };
    
    [_client  subscribe:CHANNEL
    subscribeOnReconnected:YES
              onMessage:_onMessage];
}

- (void) onSubscribed:(OrtcClient*) ortc channel:(NSString*) channel
{
    _sendButton.enabled = YES;
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_textMsg setText:@"some message to send trough REST API"];
    
    [self appendToLog:[NSString stringWithFormat:@"iOS SDK subscribe channel: %@", channel]];
}


- (void)onException:(OrtcClient *)ortc error:(NSError *)error
{
    [self appendToLog:[NSString stringWithFormat:@"iOS SDK onException: %@", error.localizedDescription]];
}





//----------------- TableView DataSource -----------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _logs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [_tableLog dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *text = [_logs objectAtIndexedSubscript:indexPath.row];
    [cell.textLabel setText:text];
    
    cell.textLabel.font = [UIFont systemFontOfSize:10.0];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    if ([text containsString:@"SUCCESS"]) {
        [cell setBackgroundColor:[UIColor greenColor]];
    }else if ([text containsString:@"FAIL"]){
        [cell setBackgroundColor:[UIColor redColor]];
    }
    
    return cell;
}




@end
