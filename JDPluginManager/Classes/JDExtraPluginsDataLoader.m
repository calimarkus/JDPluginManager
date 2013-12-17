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

-(void)getPluginsExtraDataFromGithub:(NSArray *)plugins
{
    toFinishCounter = plugins.count;
    NSLog(@"starting fething extra data for %d plugins", toFinishCounter);
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
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             NSLog(@"failed loading extra data for plugin: %@", gitPluginApiRepoUrl);
             [self decrementToFinishCountAndCheckIfFinished];
             return;
         }
         @try {
             NSError *error1;
             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error1];
             NSString *gitHubDescription = [json objectForKey:@"description"];
             if (!gitHubDescription || gitHubDescription.length == 0)
                 [NSException exceptionWithName:@"ErrorParsingGithubJSONException" reason:nil userInfo:nil];
             plugin.gitHubDescription = gitHubDescription;
             
             NSString *lastPush = [json objectForKey:@"pushed_at"];
             plugin.lastPushDate = [NSDate dateWithNaturalLanguageString:lastPush];

         }
         @catch (NSException *exception) {
             NSLog(@"error parsing json from github %@", exception.userInfo);
         }
         @finally {
            [self decrementToFinishCountAndCheckIfFinished]; 
         }
     }];
}

-(void)decrementToFinishCountAndCheckIfFinished
{
    toFinishCounter--;
    if (toFinishCounter == 0)
    {
        NSLog(@"finished fetching extra data for all plugins");
        [self.delegate finishedLoadingExtraPluginsData];
    }
    
}

@end
