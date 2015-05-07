// Generated by CoffeeScript 1.9.2
(function() {
  var Fact, stream,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Fact = require('../model/Fact').Fact;

  stream = require('stream');

  exports.FACTransformStream = (function(superClass) {
    extend(FACTransformStream, superClass);

    function FACTransformStream(entities) {
      var entity, i, len, ref;
      this.entities = entities;
      this.bsFacts = {
        Assets: {},
        CurrentAssets: {},
        NoncurrentAssets: {},
        LiabilitiesAndEquity: {},
        Liabilities: {},
        CurrentLiabilities: {},
        NoncurrentLiabilities: {},
        CommitmentsAndContingencies: {},
        TemporaryEquity: {},
        RedeemableNoncontrollingInterest: {},
        Equity: {},
        EquityAttributableToNoncontrollingInterest: {},
        EquityAttributableToParent: {}
      };
      ref = this.entities;
      for (i = 0, len = ref.length; i < len; i++) {
        entity = ref[i];
        this.bsFacts.Assets[entity] = {};
        this.bsFacts.CurrentAssets[entity] = {};
        this.bsFacts.NoncurrentAssets[entity] = {};
        this.bsFacts.LiabilitiesAndEquity[entity] = {};
        this.bsFacts.Liabilities[entity] = {};
        this.bsFacts.CurrentLiabilities[entity] = {};
        this.bsFacts.NoncurrentLiabilities[entity] = {};
        this.bsFacts.CommitmentsAndContingencies[entity] = {};
        this.bsFacts.TemporaryEquity[entity] = {};
        this.bsFacts.RedeemableNoncontrollingInterest[entity] = {};
        this.bsFacts.Equity[entity] = {};
        this.bsFacts.EquityAttributableToNoncontrollingInterest[entity] = {};
        this.bsFacts.EquityAttributableToParent[entity] = {};
      }
      this.bsDates = {};
      FACTransformStream.__super__.constructor.call(this, {
        objectMode: true
      });
    }

    FACTransformStream.prototype._transform = function(chunk, enc, next) {
      var fact, timeIndex;
      fact = new Fact(chunk);
      timeIndex = "" + (fact.EndDate.getTime());
      switch (fact.ElementName) {
        case 'fac:Assets':
          this.bsFacts.Assets[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:CurrentAssets':
          this.bsFacts.CurrentAssets[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:NoncurrentAssets':
          this.bsFacts.NoncurrentAssets[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:LiabilitiesAndEquity':
          this.bsFacts.LiabilitiesAndEquity[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:Liabilities':
          this.bsFacts.Liabilities[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:CurrentLiabilities':
          this.bsFacts.CurrentLiabilities[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:NoncurrentLiabilities':
          this.bsFacts.NoncurrentLiabilities[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:CommitmentsAndContingencies':
          this.bsFacts.CommitmentsAndContingencies[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:TemporaryEquity':
          this.bsFacts.TemporaryEquity[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:RedeemableNoncontrollingInterest':
          this.bsFacts.RedeemableNoncontrollingInterest[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:Equity':
          this.bsFacts.Equity[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:EquityAttributableToNoncontrollingInterest':
          this.bsFacts.EquityAttributableToNoncontrollingInterest[fact.Entity][timeIndex] = fact.Value;
          break;
        case 'fac:EquityAttributableToParent':
          this.bsFacts.EquityAttributableToParent[fact.Entity][timeIndex] = fact.Value;
      }
      this.bsDates["" + (fact.EndDate.getTime())] = fact.EndDate.getTime();
      return next();
    };

    FACTransformStream.prototype._flush = function(next) {
      var date, entity, i, j, k, len, len1, outputBsDates, outputBsFacts, ref, sortedBsDates, timeIndex, v, value;
      outputBsFacts = {};
      sortedBsDates = (function() {
        var ref, results;
        ref = this.bsDates;
        results = [];
        for (k in ref) {
          v = ref[k];
          results.push(new Date(v));
        }
        return results;
      }).call(this);
      sortedBsDates.sort(function(a, b) {
        if (a > b) {
          return -1;
        } else if (a < b) {
          return 1;
        } else {
          return 0;
        }
      });
      outputBsDates = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = sortedBsDates.length; i < len; i++) {
          value = sortedBsDates[i];
          results.push(value.getMonth() + 1 + "/" + value.getDate() + "/" + value.getFullYear());
        }
        return results;
      })();
      outputBsFacts = {
        Assets: [],
        CurrentAssets: [],
        NoncurrentAssets: [],
        LiabilitiesAndEquity: [],
        Liabilities: [],
        CurrentLiabilities: [],
        NoncurrentLiabilities: [],
        CommitmentsAndContingencies: [],
        TemporaryEquity: [],
        RedeemableNoncontrollingInterest: [],
        Equity: [],
        EquityAttributableToNoncontrollingInterest: [],
        EquityAttributableToParent: []
      };
      for (i = 0, len = sortedBsDates.length; i < len; i++) {
        date = sortedBsDates[i];
        ref = this.entities;
        for (j = 0, len1 = ref.length; j < len1; j++) {
          entity = ref[j];
          timeIndex = "" + (date.getTime());
          outputBsFacts.Assets.push(this.bsFacts.Assets[entity][timeIndex] != null ? this.bsFacts.Assets[entity][timeIndex] : null);
          outputBsFacts.CurrentAssets.push(this.bsFacts.CurrentAssets[entity][timeIndex] != null ? this.bsFacts.CurrentAssets[entity][timeIndex] : null);
          outputBsFacts.NoncurrentAssets.push(this.bsFacts.NoncurrentAssets[entity][timeIndex] != null ? this.bsFacts.NoncurrentAssets[entity][timeIndex] : null);
          outputBsFacts.LiabilitiesAndEquity.push(this.bsFacts.LiabilitiesAndEquity[entity][timeIndex] != null ? this.bsFacts.LiabilitiesAndEquity[entity][timeIndex] : null);
          outputBsFacts.Liabilities.push(this.bsFacts.Liabilities[entity][timeIndex] != null ? this.bsFacts.Liabilities[entity][timeIndex] : null);
          outputBsFacts.CurrentLiabilities.push(this.bsFacts.CurrentLiabilities[entity][timeIndex] != null ? this.bsFacts.CurrentLiabilities[entity][timeIndex] : null);
          outputBsFacts.NoncurrentLiabilities.push(this.bsFacts.NoncurrentLiabilities[entity][timeIndex] != null ? this.bsFacts.NoncurrentLiabilities[entity][timeIndex] : null);
          outputBsFacts.CommitmentsAndContingencies.push(this.bsFacts.CommitmentsAndContingencies[entity][timeIndex] != null ? this.bsFacts.CommitmentsAndContingencies[entity][timeIndex] : null);
          outputBsFacts.TemporaryEquity.push(this.bsFacts.TemporaryEquity[entity][timeIndex] != null ? this.bsFacts.TemporaryEquity[entity][timeIndex] : null);
          outputBsFacts.RedeemableNoncontrollingInterest.push(this.bsFacts.RedeemableNoncontrollingInterest[entity][timeIndex] != null ? this.bsFacts.RedeemableNoncontrollingInterest[entity][timeIndex] : null);
          outputBsFacts.Equity.push(this.bsFacts.Equity[entity][timeIndex] != null ? this.bsFacts.Equity[entity][timeIndex] : null);
          outputBsFacts.EquityAttributableToNoncontrollingInterest.push(this.bsFacts.EquityAttributableToNoncontrollingInterest[entity][timeIndex] != null ? this.bsFacts.EquityAttributableToNoncontrollingInterest[entity][timeIndex] : null);
          outputBsFacts.EquityAttributableToParent.push(this.bsFacts.EquityAttributableToParent[entity][timeIndex] != null ? this.bsFacts.EquityAttributableToParent[entity][timeIndex] : null);
        }
      }
      this.push({
        bsDates: outputBsDates,
        bsFacts: outputBsFacts
      });
      return next();
    };

    return FACTransformStream;

  })(stream.Transform);

}).call(this);

//# sourceMappingURL=FACTransformStream.js.map
