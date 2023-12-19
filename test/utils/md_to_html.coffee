
import os from 'os'
import path from 'path'
import fs from 'fs/promises'
import md_to_html from 'medium_publish/utils/md_to_html'

describe 'Utils `md_to_html`', ->
  
  it 'Without plugins', ->
    source = path.join(os.tmpdir(), './medium_publish_source')
    await fs.writeFile source, """
    # Title
    """
    vfile = await md_to_html [], source
    vfile.value.should.containEql '<h1>Title</h1>'
    
