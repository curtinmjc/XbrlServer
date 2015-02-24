stream = require('stream')

#Buffer an incoming stream until a "bookmark" field is found and store the value.
class exports.BookmarkExtractorStream extends stream.Transform

  #Ensure that @bookmark is an object with a value field so that it will
  #be passed by reference.  (e.g. myBookmark = {value:'blah'}
  constructor: (@bookmark) ->
    @buffer = ""
    @found = false
    super

  _transform: (chunk, enc, next) ->

    #If we haven't found what we're looking for, keep appending the incoming chunk to our buffer.
    #The bookmark field appears near the beginning of the JSON anyway, so we shouldn't
    #have to store very much in our buffer.
    if not @found
      @buffer += chunk.toString('utf8')
      match = @buffer.match(/\"bookmark\"\:\"([^\"]+)\"/)

      #We found it, throw out the buffer
      if match?
        @bookmark.value = match[1]
        @buffer = null

    @push chunk
    next()