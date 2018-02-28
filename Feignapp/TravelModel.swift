//
//  TravelModel.swift
//  TrainApp
//
//  Created by Joly Axel on 02/02/2018.
//  Copyright © 2018 Axel. All rights reserved.
//

import Foundation

class TravelModel {
    var direction: String
    var departure_date: Date
    
    init(direction: String, departure_date: Date) {
        self.departure_date = departure_date
        self.direction = direction
    }
}
