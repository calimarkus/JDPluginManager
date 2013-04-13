//
//  JDExtraPluginsDataLoader.m
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/12/13.
//
//

#import "JDExtraPluginsDataLoader.h"
#import "JDPluginMetaData.h"


@implementation JDExtraPluginsDataLoader
@synthesize delegate = _delegate;

-(void)getPluginExtraDataFromGithub:(NSArray *)plugins
{
    toFinishCounter = plugins.count;
    for (JDPluginMetaData *plugin in plugins) {
        [self getExtraDataForPlugin:plugin];
    }
}

-(void)getExtraDataForPlugin:(JDPluginMetaData *)plugin
{
    NSString *gitPluginApiRepoUrl = plugin.gitHubApiRepoURL;
    if (!gitPluginApiRepoUrl)
    {
        plugin.gitHubDescription = @"";
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:plugin.gitHubApiRepoURL]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSError *error1;
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error1];
         plugin.gitHubDescription = [json objectForKey:@"description"];
         NSString *lastPush = [json objectForKey:@"pushed_at"];
         plugin.lastPushDate = [NSDate dateWithNaturalLanguageString:lastPush];
         toFinishCounter--;
         if (toFinishCounter == 0)
         {
             [self.delegate finishedLoadingExtraPluginsData];
         }
     }];
}

@end
