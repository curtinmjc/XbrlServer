// Generated by CoffeeScript 1.8.0
(function() {
  var stream,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  stream = require('stream');

  exports.UniqueArrayWriteStream = (function(_super) {
    __extends(UniqueArrayWriteStream, _super);

    function UniqueArrayWriteStream(myArray, keySelector, valueSelector, limit) {
      this.myArray = myArray;
      this.keySelector = keySelector;
      this.valueSelector = valueSelector;
      this.limit = limit;
      UniqueArrayWriteStream.__super__.constructor.call(this, {
        objectMode: true
      });
    }

    UniqueArrayWriteStream.prototype._write = function(chunk, enc, next) {
      if (Object.keys(this.myArray).length < this.limit) {
        this.myArray[chunk[this.keySelector]] = chunk[this.valueSelector];
      }
      return next();
    };

    return UniqueArrayWriteStream;

  })(stream.Writable);

}).call(this);

//# sourceMappingURL=UniqueArrayWriteStream.js.map
