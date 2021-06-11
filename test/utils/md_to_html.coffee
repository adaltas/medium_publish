
os = require 'os'
path = require 'path'
{promises: fs} = require 'fs'
md_to_html = require '../../src/utils/md_to_html'
# pluginParseFrontmatter = require '../../src/plugins/external/remark-read-frontmatter'

describe 'Utils `md_to_html`', ->
  
  it 'Without plugins', ->
    source = path.join(os.tmpdir(), './medium_publish_source')
    fs.writeFile source, """
    # Title
    """
    vfile = await md_to_html [], source
    vfile.contents.should.containEql '<h1>Title</h1>'
    
