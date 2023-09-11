//
//  PokemonTypeEntity+CoreDataProperties.swift
//  Pokedex
//
//  Created by Drew Brunning on 9/1/23.
//
//

import Foundation
import CoreData


extension PokemonTypeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonTypeEntity> {
        return NSFetchRequest<PokemonTypeEntity>(entityName: "PokemonTypeEntity")
    }

    @NSManaged public var displayNames: [String: String]?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?

}

extension PokemonTypeEntity : Identifiable {

}
