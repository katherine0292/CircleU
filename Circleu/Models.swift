//
//  Models.swift
//  Circleu
//
//  Created by David Oyarekhua on 3/6/2026.
//

import Foundation

struct Party: Identifiable {
    let id: UUID = UUID()
    var guests: [Guest]
}

struct Guest: Identifiable {
    let id: UUID = UUID()
    var name: String
    var prefersSugar: Bool
    let yearOfBirth: Int
    var vehicle: Vehicle
}

enum Vehicle: String {
    case motorcycle = "Motorcycle"
    case car = "Car"
    case semitruck = "Semitruck"
}
