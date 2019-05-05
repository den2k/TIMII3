//
//  Global.swift
//  TIMII4
//
//  Created by Dennis Huang on 4/14/19.
//  Copyright © 2019 Autonomii. All rights reserved.
//
// 5.3.19 - created this to help with a weird problem with animations in Timer CollectionView - but now may not need it.

import Foundation

protocol TimerCollectionViewStatsProtocol : Codable
{
    var savedActiveTimerID: String { get }
    var savedPreviousTimerID: String { get }
}

extension TimerCollectionViewStatsProtocol
{
//    var activeTimerID: String { return "" }
//    var previousTimerID: String { return "" }
}


struct TimerCollectionViewStats : TimerCollectionViewStatsProtocol
{
    var savedActiveTimerID: String
    var savedPreviousTimerID: String
}



class TimerCollectionViewStatsFileHandler : TimerCollectionViewStatsProtocol
{
    private let timerCollectionViewStatsFileURL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent("Global")
        .appendingPathExtension("plist")
    
    var savedActiveTimerID: String = ""
    var savedPreviousTimerID: String = ""
    
    /// Singleton definition
    static let shared = TimerCollectionViewStatsFileHandler()
    
    private init()
    {
        guard fetchTimerCollectionViewStats() == nil else { return }
        let timerCVS = TimerCollectionViewStats(
            savedActiveTimerID: savedActiveTimerID,
            savedPreviousTimerID: savedPreviousTimerID)
        save(timerCVS)
        print("init:",timerCVS)
    }
    
    func fetchTimerCollectionViewStats() -> TimerCollectionViewStats?
    {
        guard let data = try? Data(contentsOf: timerCollectionViewStatsFileURL) else { return nil }
        let decoder = PropertyListDecoder()
        return try? decoder.decode(TimerCollectionViewStats.self, from: data)
    }
    
    func save(_ timerCVS: TimerCollectionViewStats)
    {
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(timerCVS) { try? data.write(to: timerCollectionViewStatsFileURL) }
        print("save:",timerCVS)
    }
}

