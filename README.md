
# medium_post - Post draft articles to Medium

This little CLI application is used internally by [Adatas](http://www.adaltas.com) to export our articles as draft into Medium. It is generic enough to be usable and shall be easy to customize to your fit custom needs. It run as a [Node.js](https://nodejs.org) application and the source code is written in [CoffeeScript](https://coffeescript.org)

## Installation

For users not familiar with the Node.js environment, you can follow the [official installation instructions](https://nodejs.org/en/download/) to get started and have the `node`, `npm` and `npx` command available on your system.

This package is published on NPM. Once Node.js is installed, it could be installed and executed with:

```bash
# Installation
npm install -g medium_post
# Print help
npx medium_post -h
```

The help print:

```
NAME
    medium_post - Post draft articles on Medium

SYNOPSIS
    medium_post [medium_post options]

OPTIONS
    --source                Path to the Markdown source code of the article. Required.
    --url                   URL where the article is currently being published. Required.
    --author                The name of the author. Required.
    --author_url            URL of the author page.
    --db                    Path to the database, default to "~/.medium_post"
    -h --help               Display help information

EXAMPLES
    medium_post --help      Show this message
```

## Exemple

Use `npx medium_post` if installed globally or locally as a dependency. Otherwise, from inside a cloned repository, use `./bin/medium_post`.

```bash
npx medium_post \
  --source ./path/to/article.md \
  --url http://www.adaltas.com/en/my_article/ \
  --author 'Author Name' \
  --author_url http://www.adaltas.com/en/author/name/ \
  --langs en,fr
```
