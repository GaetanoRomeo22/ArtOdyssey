import Foundation

struct Floor {
    let name: String
    let artWorks: [ArtWork]
}

let floors: [Floor] = [
    Floor(name: "Piano Terra", artWorks: [crocifissioneMasaccio, sanNicola]),
    Floor(name: "Primo Piano", artWorks: [flagellazioneCristo, strageInnocnti]),
    Floor(name: "Secondo Piano", artWorks: [sanGirolamo, vesuvius])
]
