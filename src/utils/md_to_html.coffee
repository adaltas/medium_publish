
import {read} from 'to-vfile'
import {unified} from 'unified'
import doc from 'rehype-document'
import gfm from 'remark-gfm'
import markdownParse from 'remark-parse'
import remark2rehype from 'remark-rehype'
import frontmatter from 'remark-frontmatter'
import format from 'rehype-format'
import html from 'rehype-stringify'


export default (plugins, source) ->
  await unified()
  .use markdownParse
  .use gfm
  .use frontmatter, ['yaml']
  .use ([plugin, settings] for {plugin, settings} in plugins)
  .use remark2rehype
  .use doc
  .use format
  .use html
  .process await read source
