//
//  Card.swift
//  TinderClone
//
//  Created by JD on 26/08/20.
//  Updated for colleges with new image names
//

import Foundation

struct Card: Identifiable {
    let id: UUID = UUID()
    let name: String       // e.g. "Harvard University"
    let age: Int           // Using 'age' to store founding year
    let desc: String       // Short descriptor
    let image: String      // Must match image name in Assets.xcassets

    static let cards: [Card] = [
        Card(name: "Harvard University",
             age: 1636,
             desc: "Ivy League in Cambridge, MA",
             image: "harvard"),

        Card(name: "Stanford University",
             age: 1885,
             desc: "Private research in Stanford, CA",
             image: "stanford"),

        Card(name: "Yale University",
             age: 1701,
             desc: "Ivy League in New Haven, CT",
             image: "yale"),

        Card(name: "Princeton University",
             age: 1746,
             desc: "Ivy League in Princeton, NJ",
             image: "princeton"),

        Card(name: "MIT",
             age: 1861,
             desc: "Research in Cambridge, MA",
             image: "mit"),

        Card(name: "Columbia University",
             age: 1754,
             desc: "Ivy League in NYC, NY",
             image: "columbia"),

        Card(name: "Caltech",
             age: 1891,
             desc: "Research in Pasadena, CA",
             image: "caltech"),

        Card(name: "University of Chicago",
             age: 1890,
             desc: "Private research in Chicago, IL",
             image: "uchicago"),

        Card(name: "University of Pennsylvania",
             age: 1740,
             desc: "Ivy League in Philadelphia, PA",
             image: "upenn")
    ]
}
