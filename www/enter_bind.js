var cmd_count = 1;
var cmdInputBinding = new Shiny.InputBinding();

$(document).on('change', '.reactnb-command', function(e) {
  Shiny.onInputChange('cmd_count', cmd_count);
});

$.extend(cmdInputBinding, {
  nextId: 0,
  history: [],
  historyPos: null,
  find: function(scope) {
    return $(scope).find('.reactnb-command');
  },
  getValue: function(el) {
    var ob = $.extend(true, this.parseInput(el), {
      id: 'cmd' + $(el).attr('id').substr(-1)
    });
    return ob;
  },
  parseInput: function(el) {
    var val = $(el).val();
    // Commands with a leading * are plot commands
    var m = /^\[(\w+)\](.*)$/.exec(val);
    if (m) {
      if (!/^(plot|table|html|ui|print|text)$/.test(m[1])) {
        alert('Unknown command type: ' + m[1]);
        throw new Error('Unknown command type');
      }
      return {type: m[1], text: m[2]};
    } else if (/\b(plot|hist|lattice|ggplot|qplot)\b/.test(val) && !/\blibrary\b/.test(val)) {
      return {type: 'plot', text: val}
    } else {
      return {type: 'print', text: val};
    }
  },
  subscribe: function(el, callback) {
    var self = this;
    $el = $(el);
    $el.keydown(function(e) {
      if (e.which == 38) { // up-arrow
        if (self.historyPos > 0) {
          self.historyPos--;
          $el.val(self.history[self.historyPos]);
          $el.select();
          setTimeout(function() {
            el.setSelectionRange($el.val().length, $el.val().length);
          }, 0);
        }
      }
      if (e.which == 40) { // down-arrow
        if (self.historyPos < self.history.length) {
          self.historyPos++;
          if (self.historyPos == self.history.length)
            $el.val('');
          else
            $el.val(self.history[self.historyPos]);
          $el.select();
          setTimeout(function() {
            el.setSelectionRange($el.val().length, $el.val().length);
          }, 0);
        }
      }
      if (e.keyCode == 13) { // enter

        self.history.push($el.val());
        self.historyPos = self.history.length;

        if ($(this).attr('id') == ("command" + cmd_count)) {
          var newCmd = $('<input type="command" id="command' + (cmd_count + 1) + '" class="reactnb-command" autocomplete="off" autocorrect="off"/><br/>');

          var outputClass = 'highlight-text-output';
          var parsed = self.parseInput(el);
          if (parsed.type === 'plot') {
            outputClass = 'shiny-plot-output';
          } else if (parsed.type === 'table') {
            outputClass = 'shiny-html-output';
          } else if (parsed.type === 'text') {
            outputClass = 'highlight-text-output';
          } else if (parsed.type === 'html' || parsed.type === 'ui') {
            outputClass = 'shiny-html-output';
          }
          var newOutput = $('<div id="cmd' + (cmd_count + 1) + '_output" class="output ' + outputClass + '">');

          $('.container-fluid').append(newCmd);
          $('.container-fluid').append(newOutput);

          cmd_count++;
        }

        Shiny.bindAll();
        callback();
      }
    })
  }
});
Shiny.inputBindings.register(cmdInputBinding, 'reactnb-command');


var highlightTextOutputBinding = new Shiny.OutputBinding();
$.extend(highlightTextOutputBinding, {
  find: function(scope) {
    return $(scope).find('.highlight-text-output');
  },
  renderValue: function(el, data) {
    $(el).text(data);
    $(el).addClass('highlight').removeClass('highlight', 800, 'easeInExpo');
  }
});
Shiny.outputBindings.register(highlightTextOutputBinding, 'reactnb-highlightTextOutput');
