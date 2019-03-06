//
//  Named.swift
//  TIMII
//
//  Created by Dennis Huang on 10/8/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

protocol Nameable
{
    var name: String        { get set }
    var description: String { get set }
}

extension Nameable
{
    var name: String        { return "enter a name" }
    var description: String { return "enter a description" }
}
