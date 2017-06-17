import Foundation
import FeedKit
import Stencil

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

let feedURL = URL(string: "http://station13.libsyn.com/rss")!
guard let result = FeedParser(URL: feedURL)?.parse() else {
    print("Failed to construct FeedParser for URL \(feedURL)")
    abort()
}

guard let feed = result.rssFeed,
      result.isSuccess else {
    print(result.error as Any)
    abort()
}

let fsLoader = FileSystemLoader(paths: ["Templates/"])
let environment = Environment(loader: fsLoader)

let context : [String: Any] = [
    "title" : feed.title ?? "Unnamed Podcast",
    "items" : feed.items ?? []
]

let template = try environment.loadTemplate(name: "index.html")
let index = try template.render(context)
try index.write(toFile            : "Site/index.html",
                atomically        : true,
                encoding          : .utf8,
                creatingDirectory : true)
