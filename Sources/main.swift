import Foundation
import FeedKit
import Stencil

/********* CONFIGURATION *********/
let feedURL            = URL(string: "http://station13.libsyn.com/rss")!
let episodesOnMainPage = 5

/*********    THE CODE   *********/
extension String {
    func write(toFile path: String,
               atomically useAuxiliaryFile: Bool,
               encoding enc: String.Encoding,
               creatingDirectory: Bool
    ) throws {
        if creatingDirectory {
            let fileManager = FileManager.default
            let parentPath = (path as NSString).deletingLastPathComponent
            var isDirectory: ObjCBool = false
            if !fileManager.fileExists(atPath: parentPath, isDirectory: &isDirectory) {
                try fileManager.createDirectory(atPath: parentPath, withIntermediateDirectories: true, attributes: nil)
            }
            else if !isDirectory.boolValue {
                print("Path \(parentPath) isn't a directory!")
                abort()
            }
        }

        try write(toFile: path, atomically: useAuxiliaryFile, encoding: enc)
    }
}

guard let result = FeedParser(URL: feedURL)?.parse() else {
    print("Failed to construct FeedParser for URL \(feedURL)")
    abort()
}

guard let feed = result.rssFeed,
      result.isSuccess else {
    print(result.error as Any)
    abort()
}

let title    = feed.title ?? "Unnamed Podcast"
let episodes = feed.items?.reversed().enumerated().reversed().map{ ($0.0 + 1, $0.1) } ?? []

let fsLoader = FileSystemLoader(paths: ["Templates/"])
let environment = Environment(loader: fsLoader)

// Main page
let mainTemplate = try environment.loadTemplate(name: "index.html")
let limit = min(episodesOnMainPage, episodes.count)
let index = try mainTemplate.render([
    "podcastTitle" : title,
    "episodes"     : episodes[0..<limit].map{ ["index": $0.0, "content": $0.1] }
])
try index.write(toFile            : "Site/index.html",
                atomically        : true,
                encoding          : .utf8,
                creatingDirectory : true)

// Episode pages
let episodeTemplate = try environment.loadTemplate(name: "episode.html")
for (index, episode) in episodes {
    let episodePage = try episodeTemplate.render([
        "podcastTitle" : title,
        "episode"      : episode
    ])
    try episodePage.write(toFile            : "Site/\(index)/index.html",
                      atomically        : true,
                      encoding          : .utf8,
                      creatingDirectory : true)
}
