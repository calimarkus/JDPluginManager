//
//  JDExtraPluginsDataLoader.m
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/12/13.
//
//

#import "JDExtraPluginsDataLoader.h"
#import "JDPluginMetaData.h"

@interface JDExtraPluginsDataLoader ()
{
    int toFinishCounter;
    id<JDExtraPluginsDataLoaderDelegate> _delegate;
}
@end

@implementation JDExtraPluginsDataLoader

@synthesize delegate = _delegate;

-(void)getPluginsExtraDataFromGithub:(NSArray *)plugins
{
    toFinishCounter = (int)plugins.count;
    NSLog(@"starting to fetch extra data for %d plugins", toFinishCounter);
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
        [self decrementToFinishCountAndCheckIfFinished];
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:gitPluginApiRepoUrl]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error || !data || data.length == 0) {
             NSLog(@"error loading extra data for plugin: %@", gitPluginApiRepoUrl);
             [self decrementToFinishCountAndCheckIfFinished];
             return;
         }
         
         // parse json
         NSError *jsonError;
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingAllowFragments
                                                                error:&jsonError];
         
         // save description or error messsage
         NSString *gitHubDescription = [json objectForKey:@"description"];
         if (!gitHubDescription || gitHubDescription.length == 0) {
             plugin.gitHubDescription = [json objectForKey:@"message"];
         } else {
             plugin.gitHubDescription = gitHubDescription;
         }
         
         // save date, if available
         NSString *lastPush = [json objectForKey:@"pushed_at"];
         if (lastPush) {
             plugin.lastPushDate = [NSDate dateWithNaturalLanguageString:lastPush];
         }
         
         [self decrementToFinishCountAndCheckIfFinished];
     }];
}

-(void)decrementToFinishCountAndCheckIfFinished
{
    toFinishCounter--;
    
    if (toFinishCounter == 0) {
        NSLog(@"finished fetching extra data for all plugins");
        [self.delegate extraPluginsDataLoaderDidFinish:self];
    }
    
}

@end

