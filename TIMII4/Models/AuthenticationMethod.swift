//
//  AuthenticationMethod.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/13/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

protocol AuthMethod {
    var authMethod: AuthenticationMethod { get }
}

extension AuthMethod
{
    // Default setting for AuthMethod is email
    var authMethod: AuthenticationMethod { return .email }
}

enum AuthenticationMethod: String
{
    // rawValue would give us this String label definition by default but making this explicit
    case email      = "email"
    case facebook   = "facebook"
    case phone      = "phone"
    case google     = "google"
}
