//
//  JDPluginMetaData.m
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "JDPluginMetaData.h"

NSString *const JDPluginManagerMetaDataFileName = @".JDPluginManager.meta";
NSString *const JDPluginManagerMetaDataReadmeName = @"README.md";

NSString *const JDPluginManagerMetaDataRepositoryKey = @"JDPluginManagerMetaDataRepositoryKey";
NSString *const JDPluginManagerMetaDataReadmePathKey = @"JDPluginManagerMetaDataReadmePathKey";

@interface JDPluginMetaData ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, copy) NSString *pluginPath;
@end

@implementation JDPluginMetaData

@synthesize dictionary = _dictionary;
@synthesize pluginPath = _pluginPath;
@synthesize name = _name;
@synthesize gitHubDescription = _gitHubDescription;
@synthesize lastPushDate = _lastPushDate;
@synthesize localPluginModifiedDate = _localPluginModifiedDate;

+ (JDPluginMetaData*)metaDataForPluginAtPath:(NSString*)pluginPath
{
    return [self metaDataForPluginAtPath:pluginPath andName:nil];
}

+ (JDPluginMetaData*)metaDataForPluginAtPath:(NSString*)pluginPath andName:(NSString *)name
{
    JDPluginMetaData *metaData = [[[JDPluginMetaData alloc] initWithPluginPath:pluginPath andName:name] autorelease];

    // read saved meta data
    NSString *path = [pluginPath stringByAppendingPathComponent:JDPluginManagerMetaDataFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSMutableDictionary *dictionary = [[[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy] autorelease];
        if (dictionary) {
            metaData.dictionary = dictionary;
        }
    };
    
    // set repo path for JDPluginManager
    if([metaData.dictionary objectForKey:JDPluginManagerMetaDataRepositoryKey] == nil &&
       [pluginPath rangeOfString:@"JDPluginManager"].length > 0) {
        [metaData.dictionary setObject:@"git@github.com:jaydee3/JDPluginManager.git" forKey:JDPluginManagerMetaDataRepositoryKey];
    }
    
    return metaData;
}

- (id)initWithPluginPath:(NSString*)pluginPath;
{
    self = [self initWithPluginPath:pluginPath andName:nil];
    return self;
}

- (id)initWithPluginPath:(NSString*)pluginPath andName:(NSString *)name;
{
    self = [super init];
    if (self) {
        _pluginPath = [pluginPath copy];
        _dictionary = [[NSMutableDictionary alloc] init];
        _name = [name copy];
    }
    return self;
}

- (void)dealloc
{
    self.dictionary = nil;
    self.pluginPath = nil;
    [super dealloc];
}

#pragma mark data

- (id)objectForKey:(id)aKey; {
    return [self.dictionary objectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey; {
    [self.dictionary setObject:anObject forKey:aKey];
}

- (void)findAndSetReadmeAtBuildPath:(NSString*)buildPath;
{
    NSString *sourcePath = [buildPath stringByAppendingPathComponent:@"README.md"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        sourcePath = [buildPath stringByAppendingPathComponent:@"README"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
            sourcePath = [buildPath stringByAppendingPathComponent:@"readme"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
                return;
            }
        }
    }
    
    NSString *targetPath = [self.pluginPath stringByAppendingPathComponent:JDPluginManagerMetaDataReadmeName];
    [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
    if([[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:targetPath error:nil]) {
        [self.dictionary setObject:targetPath forKey:JDPluginManagerMetaDataReadmePathKey];
        [self save];
    } else {
        NSLog(@"ERROR copying readme");
    }
}

- (BOOL)save;
{
    NSString *path = [self.pluginPath stringByAppendingPathComponent:JDPluginManagerMetaDataFileName];
    BOOL succes = [self.dictionary writeToFile:path atomically:YES];
    
    if (!succes) {
        NSLog(@"error saving metadata");
    }
    
    return succes;
}

-(BOOL *)needsUpdate
{
    if (!self.localPluginModifiedDate || !self.lastPushDate)
        return NO;
    return [self.localPluginModifiedDate compare:self.lastPushDate] == NSOrderedAscending;
}

-(NSString *)gitHubApiRepoURL
{
    NSString *pluginRepo = [self objectForKey:JDPluginManagerMetaDataRepositoryKey];
    if (pluginRepo == nil || pluginRepo.length == 0) return nil;
    NSURL *gitRepoUrl = [NSURL URLWithString:pluginRepo];
    NSString *gitHubUser = @"";
    NSString *repoName = @"";
    for (NSString *comp in gitRepoUrl.pathComponents) {
        if ([comp rangeOfString:@":"].location != NSNotFound)
        {
            gitHubUser = [[comp componentsSeparatedByString:@":"] objectAtIndex:1];
            continue;
        }
        NSRange dotGit = [comp rangeOfString:@".git"];
        if (dotGit.location != NSNotFound)
        {
            repoName = [comp substringWithRange:NSMakeRange(0, dotGit.location)];
            continue;
        }
    }
    if (repoName.length == 0 || gitHubUser.length == 0)
        return nil;

    return [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@", gitHubUser, repoName];
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"plugin name: %@, path: %@", self.name, self.pluginPath ];
}
@end
