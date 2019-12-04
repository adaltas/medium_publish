
module.exports =
  name: 'medium_post'
  description: 'Post draft articles on Medium'
  options:
    source:
      required: true
      description: 'Path to the Mardown source code of the article.'
    url:
      required: true
      description: 'URL where the article is currently being published.'
    author:
      required: true
      description: 'The name of the author.'
    author_url:
      description: 'URL of the author page.'
    db:
      description: 'Path to the database, default to "~/.medium_post"'
      default: "#{require('os').homedir()}/.medium_post"
    langs:
      description: 'Accepted languages'
      type: 'array'
      default: []
