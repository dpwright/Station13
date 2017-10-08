import Foundation
import FeedKit
import Stencil
import Files
import SwiftSoup

/********* CONFIGURATION *********/
let show = [
  "rssFeed":         "http://station13.libsyn.com/rss",
  "iTunes":          "https://itunes.apple.com/us/podcast/station-13/id1240319438",
  "overcast":        "https://overcast.fm/itunes1240319438/station-13",
  "pocketCasts":     "http://pca.st/d2Ca",
  "googlePlayMusic": "https://play.google.com/music/m/Ipdzur3mtrmed4ahbw2or45owwq?t=Station_13",
  "youTube":         "https://www.youtube.com/channel/UCiiX-MrqHpZmuSMOUZR8q6A?view_as=subscriber",
  "podchaser":       "https://www.podchaser.com/podcasts/station-13-525932",
  "reddit":          "https://www.reddit.com/r/Station13",
  "twitter":         "@Station13FM"
]

let episodesOnMainPage = 5
let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .long

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

let feed = try Data(contentsOf: URL(string: show["rssFeed"]!)!)
try feed.write(to: URL(fileURLWithPath: "Site/feed.rss"))

guard let result = FeedParser(data: feed)?.parse() else {
    print("Failed to construct FeedParser for URL \(show["rssFeed"])")
    abort()
}

guard let feed = result.rssFeed,
      result.isSuccess else {
    print(result.error as Any)
    abort()
}

let title       = feed.title ?? "Unnamed Podcast"
let episodes    = feed.items?.reversed().enumerated().reversed().map{ ($0.0 + 1, $0.1) } ?? []
let copyright   = feed.copyright ?? ""
let description = feed.description ?? ""
let image       = feed.image?.url ?? ""
let link        = feed.link ?? ""

let fsLoader = FileSystemLoader(paths: ["Templates/"])
let environment = Environment(loader: fsLoader)

// Main page
let mainTemplate = try environment.loadTemplate(name: "index.html")
let limit = min(episodesOnMainPage, episodes.count)
let index = try mainTemplate.render([
    "podcastTitle" : title,
    "copyright"    : copyright,
    "description"  : description,
    "image"        : image,
    "link"         : link,
    "show"         : show,
    "episodes"     : episodes[0..<limit].map{
      ["index"   : $0.0,
       "content" : $0.1,
       "date"    : dateFormatter.string(from: $0.1.pubDate!),
       "mp3url"  : $0.1.enclosure?.attributes?.url]
    }
])
try index.write(toFile            : "Site/index.html",
                atomically        : true,
                encoding          : .utf8,
                creatingDirectory : true)

// Subscribe
let subscribeTemplate = try environment.loadTemplate(name: "subscribe.html")
let subscribe = try subscribeTemplate.render([
    "podcastTitle" : title,
    "pageTitle"    : "Subscribe",
    "copyright"    : copyright,
    "description"  : description,
    "image"        : image,
    "link"         : "\(link)subscribe",
    "show"         : show
])
try subscribe.write(toFile          : "Site/subscribe/index.html",
                  atomically        : true,
                  encoding          : .utf8,
                  creatingDirectory : true)

// Archive
let archiveTemplate = try environment.loadTemplate(name: "archive.html")
let archive = try archiveTemplate.render([
    "podcastTitle" : title,
    "pageTitle"    : "Archive",
    "copyright"    : copyright,
    "description"  : description,
    "image"        : image,
    "link"         : "\(link)archive",
    "show"         : show,
    "episodes"     : episodes.map{
      ["index"   : $0.0,
       "content" : $0.1,
       "date"    : dateFormatter.string(from: $0.1.pubDate!)]
    }
])
try archive.write(toFile            : "Site/archive/index.html",
                  atomically        : true,
                  encoding          : .utf8,
                  creatingDirectory : true)

// About
let aboutTemplate = try environment.loadTemplate(name: "about.html")
let about = try aboutTemplate.render([
    "podcastTitle" : title,
    "pageTitle"    : "About",
    "copyright"    : copyright,
    "description"  : description,
    "image"        : image,
    "link"         : "\(link)about",
    "show"         : show
])
try about.write(toFile            : "Site/about/index.html",
                  atomically        : true,
                  encoding          : .utf8,
                  creatingDirectory : true)

// Episode pages
let episodeTemplate = try environment.loadTemplate(name: "episode.html")
for (index, episode) in episodes {
    let description = try SwiftSoup.parse(episode.description ?? "").select("p").first()?.text() ?? ""
    let image = episode.iTunes?.iTunesImage?.attributes?.href
    let episodePage = try episodeTemplate.render([
        "podcastTitle" : title,
        "pageTitle"    : episode.title,
        "copyright"    : copyright,
        "episode"      : episode,
        "description"  : description,
        "link"         : "\(link)\(index)",
        "show"         : show,
        "image"        : image,
        "date"         : dateFormatter.string(from: episode.pubDate!),
        "mp3url"       : episode.enclosure?.attributes?.url
    ])
    try episodePage.write(toFile            : "Site/\(index)/index.html",
                          atomically        : true,
                          encoding          : .utf8,
                          creatingDirectory : true)
}

// Static content
extension FileSystem.Item {
    func copy(to newParent: Folder) throws {
        let newPath = newParent.path + name

        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: newPath) {
                try fileManager.removeItem(atPath: newPath)
            }
            try fileManager.copyItem(atPath: path, toPath: newPath)
        } catch {
            throw OperationError.moveFailed(self)
        }
    }
}

let originFolder = try Folder(path: "Static")
let targetFolder = try Folder(path: "Site")
try originFolder.files.forEach{ try $0.copy(to: targetFolder) }
try originFolder.subfolders.forEach{ try $0.copy(to: targetFolder) }
