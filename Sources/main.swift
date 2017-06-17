import Foundation
import FeedKit

let feedURL = URL(string: "http://station13.libsyn.com/rss")!
guard let result = FeedParser(URL: feedURL)?.parse() else {
    print("Failed to construct FeedParser for URL \(feedURL)")
    abort()
}

guard let feed = result.rssFeed,
      result.isSuccess else {
    print(result.error)
    abort()
}

let podcastTitle = feed.title ?? "Unnamed Podcast"
let podcastDescription = feed.description ?? ""

print(podcastTitle)
print(podcastDescription)

for item in feed.items ?? [] {
    print(item.title ?? "")
    print(item.pubDate ?? "")
}
