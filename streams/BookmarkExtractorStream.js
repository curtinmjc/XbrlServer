// Generated by CoffeeScript 1.8.0
(function() {
  var stream,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  stream = require('stream');

  exports.BookmarkExtractorStream = (function(_super) {
    __extends(BookmarkExtractorStream, _super);

    function BookmarkExtractorStream(bookmark) {
      this.bookmark = bookmark;
      this.buffer = "";
      this.found = false;
      BookmarkExtractorStream.__super__.constructor.apply(this, arguments);
    }

    BookmarkExtractorStream.prototype._transform = function(chunk, enc, next) {
      var match;
      if (!this.found) {
        this.buffer += chunk.toString('utf8');
        match = this.buffer.match(/\"bookmark\"\:\"([^\"]+)\"/);
        if (match != null) {
          this.bookmark.value = match[1];
          this.buffer = null;
        }
      }
      this.push(chunk);
      return next();
    };

    return BookmarkExtractorStream;

  })(stream.Transform);

}).call(this);

//# sourceMappingURL=BookmarkExtractorStream.js.map
