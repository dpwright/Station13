Station 13
==========

This is a static site generator for the Station 13 podcast.  Every time the RSS
feed for the podcast is updated, the Swift script in `Sources/main.swift` is
built and executed by Travis CI, generating the site and outputting it into the
`Site` folder.  Travis then commits that folder back to the `master` branch,
from which GitHub hosts the site.

Modifying the design of the output site
---------------------------------------

All the output files can be found in the `Templates` and `Static` directories.
Files in `Static` are copied over directly, while those in `Templates` are used
as a basis for site generation.  Currently this consists of two templates:

- `Templates/index.html`, which is used to generate the main index page.
- `Templates/episode.html`, which is used to generate the page for each episode.

You can generate the site locally by running:

```
swift build && .build/debug/site
```

Then just open the resulting `Site/index.html` in your browser.
