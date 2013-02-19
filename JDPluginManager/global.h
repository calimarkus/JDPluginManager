//
//  global.h
//  JDPluginManager
//
//  Created by Markus Emrich on 04.02.13.
//
//

#if JDPluginManagerTest == 1
    #define JDLocalize(keyName) NSLocalizedString(keyName, nil)
#else
    #define JDLocalize(keyName) NSLocalizedStringFromTableInBundle(keyName, @"Localizable", [NSBundle bundleForClass:[self class]], nil)
#endif



