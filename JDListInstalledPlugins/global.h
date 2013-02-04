//
//  global.h
//  JDListInstalledPlugins
//
//  Created by Markus Emrich on 04.02.13.
//
//

#if JDListInstalledPluginsTest == 1
    #define JDLocalize(keyName) NSLocalizedString(keyName, nil)
#else
    #define JDLocalize(keyName) NSLocalizedStringFromTableInBundle(keyName, @"Localizable", [NSBundle bundleForClass:[self class]], nil)
#endif



