//
//  Colors.swift
//  TIMII
//
//  Created by Dennis Huang on 7/24/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

/* --- TODO Section ---
 
 TODO: 10.10.18 [DONE 10.10.18] - Migrated from TIMII to TIMII3
 
 */
 
import UIKit

extension UIColor
{
    // http://www.flatuicolorpicker.com/
    // GRAY
    @objc static let gallery         = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)  // #EEEEEE
    @objc static let cararra         = UIColor(red: 242.0/255.0, green: 241.0/255.0, blue: 239.0/255.0, alpha: 1.0)  // #F2F1EF
    @objc static let whiteSmoke      = UIColor(red: 236.0/255.0, green: 236.0/255.0, blue: 236.0/255.0, alpha: 1.0)  // #ECECEC
    @objc static let porcelain       = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)  // #ECF0F1
    @objc static let silverSand      = UIColor(red: 189.0/255.0, green: 195.0/255.0, blue: 199.0/255.0, alpha: 1.0)  // #BDC3C7
    @objc static let lynch           = UIColor(red: 108.0/255.0, green: 122.0/255.0, blue: 137.0/255.0, alpha: 1.0)  // #6C7A89
    @objc static let iron            = UIColor(red: 218.0/255.0, green: 223.0/255.0, blue: 225.0/255.0, alpha: 1.0)  // #DADFE1
    @objc static let silver          = UIColor(red: 191.0/255.0, green: 191.0/255.0, blue: 191.0/255.0, alpha: 1.0)  // #BFBFBF
    @objc static let porcelainOpaque = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 0.2)
    @objc static let ironOpaque      = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 0.9)
    
    // RED
    @objc static let cinnabar   = UIColor(red: 240.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 1.0)    // #F03434
    @objc static let oldBrick   = UIColor(red: 150.0/255.0, green: 40.0/255.0, blue: 27.0/255.0, alpha: 1.0)    // #96281B
    @objc static let monza      = UIColor(red: 207.0/255.0, green: 0.0/255.0, blue: 15.0/255.0, alpha: 1.0)     // #CF000F
    @objc static let valencia   = UIColor(red: 214.0/255.0, green: 69.0/255.0, blue: 65.0/255.0, alpha: 1.0)    // #D64541
    
    // GREEN
    @objc static let summerGreen = UIColor(red: 145.0/255.0, green: 180.0/255.0, blue: 150.0/255.0, alpha: 1.0) // #91B496
    @objc static let eucalyptus  = UIColor(red: 38.0/255.0, green: 166.0/255.0, blue: 91.0/255.0, alpha: 1.0)   // #26A65B
    @objc static let salem       = UIColor(red: 30.0/255.0, green: 130.0/255.0, blue: 76.0/255.0, alpha: 1.0)   // #1E824C
    
    // Ellie Colors
    @objc static let mintGreen  = UIColor(red: 151.0/255.0, green: 204.0/255.0, blue: 141.0/255.0, alpha: 1.0)  // #97CC8D
    @objc static let jungle     = UIColor(red: 73.0/255.0, green: 105.0/255.0, blue: 68.0/255.0, alpha: 1.0)    // #496944
    @objc static let softWhite  = UIColor(red: 250.5/255.0, green: 248.0/255.0, blue: 245.0/255.0, alpha: 1.0)  // #FAF8F5
    @objc static let gray       = UIColor(red: 154.0/255.0, green: 172.0/255.0, blue: 177.0/255.0, alpha: 1.0)  // #9AACB1
    @objc static let lightTan   = UIColor(red: 212.0/255.0, green: 204.0/255.0, blue: 191.0/255.0, alpha: 1.0)  // #D4CCBF
    @objc static let camo       = UIColor(red: 95.0/255.0, green: 158.0/255.0, blue: 92.0/255.0, alpha: 1.0)    // #5F9E5C
    
    // ORIGINAL
    @objc static let black        = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)      // #000000
    @objc static let red          = UIColor(red: 255.0/255.0, green: 115.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    @objc static let orange       = UIColor(red: 255.0/255.0, green: 175.0/255.0, blue: 72.0/255.0, alpha: 1.0)
    @objc static let brightOrange = UIColor(red: 255.0/255.0, green: 69.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    @objc static let blue         = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 228.0/255.0, alpha: 1.0)
    @objc static let green        = UIColor(red: 91.0/255.0, green: 197.0/255.0, blue: 159.0/255.0, alpha: 1.0)
    @objc static let darkGrey     = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    @objc static let veryDarkGrey = UIColor(red: 13.0/255.0, green: 13.0/255.0, blue: 13.0/255.0, alpha: 1.0)
    @objc static let lightGrey    = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    @objc static let white        = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    @objc static let transparent  = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0)
}
