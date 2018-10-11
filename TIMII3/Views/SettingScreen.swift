//
//  SettingScreen.swift
//  TIMII
//
//  Created by Dennis Huang on 8/5/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

/* TODO Section
 
 TODO: 8.5.18 - This file exist as the 'controller' (swift class) for our 'views' (XML) that can be referenced using the XML tag (ie; <SettingsScreen>)
 TODO: 8.21.18 - Login out and login back in drop user on to profile/Setting screen given the present call here. Remove the present LoginScreen from the HandleLogout func. This was tried but the present / dismiss / Layout with XML views seems to get in the way. I tried a few ways through main.swift to offload this into the LogInOutSystem.swift without too much luck. At least the Firebase calls from this class is no longer needed.
 TODO: 10.10.18 [DONE 10.10.18] - Migrated code from TIMII to TIMII3
 
 */

import UIKit

class SettingScreen: UIViewController
{
    @objc func settingHandleLogout()
    {
        print("Setting Screen logout...")
        let lo = Login()
        lo.handleLogout()
        
        print("Show Login screen from SettingScreen.")
        let login = LoginScreen()
        present(login, animated: true, completion: nil)
    }
}
