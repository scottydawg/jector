describe 'Jector API', ->

  jector = require(process.cwd() + '/dist/jector')

  describe 'context', ->

    it 'retrieves a unique context for each namespace', ->
      spaceA = jector.context('spaceA')
      spaceB = jector.context('spaceB')
      expect(spaceA).not.toBe(spaceB)

    it 'retrieves the same instance of a named context', ->
      spaceA = jector.context('spaceA')
      spaceB = jector.context('spaceA')
      expect(spaceA).toBe(spaceB)

    it 'indicates the context name', ->
      expect(jector.context('spaceA').namespace).toEqual('spaceA')

  describe 'release', ->

    it 'dereferences the named context', ->
      nsA = jector.context('spaceA')
      jector.release('spaceA')
      nsB = jector.context('spaceA')
      expect(nsB).not.toBe(nsA)

    it 'returns released context', ->
      nsA = jector.context('spaceA')
      nsB = jector.release('spaceA')
      expect(nsB).toBe(nsA)

