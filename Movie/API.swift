//
//  API.swift
//  API
//
//  Created by Nudzejma Kezo on 10/1/20.
//
import Foundation

struct APIResult:Codable {
    var results:[APIObject]
}
struct APIObject:Codable {
    var title: String
    var release_date:String?
    var overview:String?
    var poster_path:String?
}
