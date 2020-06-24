
visit = require 'unist-util-visit'
{exec} = require 'child_process'
path = require 'path'

###
Upload every image present on the markdown article into a public GIT repository and update the `src` image attribute to reflect the new public URL.
###

module.exports = (options = {}) ->
  # Normalization
  throw Error 'Required Property: public_images require the "target" option' unless options.target
  throw Error 'Required Property: public_images require the "repository" option' unless options.repository
  throw Error 'Required Property: public_images require the "base_url" option' unless options.base_url
  throw Error 'Required Property: public_images require the "source" option' unless options.source
  options.source = path.resolve process.cwd(), options.source
  options.location ?= ({options, node}) ->
    path.join hash(options.source), node.url
  (tree, file) ->
    images = []
    res = visit tree, 'image', (node) ->
      return unless /\.png$/.test node.url
      image =
        url: node.url
        alt: node.alt
        target: options.location options: options, node: node
      node.url = "#{options.base_url}/#{image.target}"
      images.push image
    await new Promise (resolve, reject) ->
      exec """
      [ -d #{options.target} ] || mkdir -p #{options.target}
      cd #{options.target}
      [ -d #{options.target}/.git ] || git init
      git remote get-url origin || git remote add origin #{options.repository}
      if [ ! -f .gitignore ]; then
      cat <<-GITIGNORE >.gitignore
      .*
      !.gitignore
      GITIGNORE
        git add .gitignore
        git commit -m "ignore hidden files"
        git push origin master
      fi
      # Reset if option is activated and if there is more than the first initial commit
      reset=$([ ! -z '#{if options.reset then '1' else ''}' ] && [ `git rev-list HEAD --count` -gt '1' ] && echo '1')
      if [ ! -z "$reset" ]; then
        git reset --hard HEAD~1
      fi
      #{images.map (image) ->
        [
          "mkdir -p #{path.dirname image.target}"
          "cp #{path.dirname options.source}/#{image.url} #{image.target}"
          "git add #{image.target}"
        ].join '\n'
      .join '\n'}
      if [ ! -z "$(git status --porcelain)" ]; then
        #git commit $reset -m 'upload new images'
        git commit -m 'upload new images'
      fi
      force=$([ ! -z "$reset" ] && echo '-f')
      echo "git push $force origin master"
      git push $force origin master
      """, (err, stdout, stderr) ->
        if err
        then reject err
        else resolve()
    res
    
hash = (str) ->
  require('crypto').createHash('md5').update(str, 'utf8').digest('hex')
