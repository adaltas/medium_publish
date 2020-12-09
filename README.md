
# medium_publish - Publish draft articles from Markdown to Medium

This little CLI application is used internally by [Adatas](http://www.adaltas.com) to export our articles as draft into Medium. It is generic enough to be usable and shall be easy to customize to your fit custom needs. It run as a [Node.js](https://nodejs.org) application and the source code is written in [CoffeeScript](https://coffeescript.org)

## Installation

For users not familiar with the Node.js environment, you can follow the [official installation instructions](https://nodejs.org/en/download/) to get started and have the `node`, `npm` and `npx` command available on your system.

This package is published on NPM. Once Node.js is installed, it could be installed and executed with:

```bash
# Installation
npm install -g medium_publish
# Print help
npx medium_publish -h
```

The help print:

```
NAME
    medium_publish - Post draft articles on Medium

SYNOPSIS
    medium_publish [medium_publish options]

OPTIONS
    --source                Path to the Markdown source code of the article. Required.
    --url                   URL where the article is currently being published. Required.
    --author                The name of the author. Required.
    --author_url            URL of the author page.
    --db                    Path to the database, default to "~/.medium_publish"
    -h --help               Display help information

EXAMPLES
    medium_publish --help      Show this message
```

## Exemple

Use `npx medium_publish` if installed globally or locally as a dependency. Otherwise, from inside a cloned repository, use `./bin/medium_publish`.

```bash
npx medium_publish \
  --source ./path/to/article.md \
  --url http://www.adaltas.com/en/my_article/ \
  --author 'Author Name' \
  --author_url http://www.adaltas.com/en/author/name/ \
  --langs en,fr
```

## Plugins

* `medium_publish/lib/plugins/parse_frontmatter`   
  Parse frontmatter and insert the "frontmatter" field in the vfile object.
* `medium_publish/lib/plugins/public_images`   
  Upload every image present on the markdown article into a public GIT repository and update the `src` image attribute to reflect the new public URL.
  Options:
  * `base_url` (string, required)   
    Base URL used to download the images.
  * `location` (function)   
    User function used to formal the image location relative to the repository location.
  * `repository` (string, required)   
    Remote GIT repository URL.
  * `reset` (boolean, `false`)   
    Overwrite the previous commit and images
  * `source` (string, required)   
    Location of the markdown file
  * `target` (string, required)   
    Directory storing the git repository.

## Developer

Test are executed with Mocha and Should.js:

```bash
yarn test
```

Versioning and changelog generation use the `standard-version` package:

```bash
yarn release
# Or
yarn release --prerelease beta
```

Note, it does not push and publish. After release, run:

```bash
git push --follow-tags origin master && npm publish
```

TODO: integrate CI/CD, publish inside of it.
