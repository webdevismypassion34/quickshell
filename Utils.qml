pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: utils

  Component {
    id: procComponent

    Process {
      id: proc

      required property var onDone

      stdout: StdioCollector {
        onStreamFinished: {
          proc.onDone(text);
          proc.destroy();
        }
      }
    }
  }

  function exec(command, callback) {
    procComponent.createObject(utils, {
      onDone: callback ?? (() => {})
    }).exec(command);
  }

  function readFile(path, callback) {
    exec(['cat', path], callback);
  }

  function writeFile(path, content) {
    exec(['sh', '-c', 'mkdir -p "$(dirname "$1")" && printf %s "$2" > "$1"', 'sh', path, content]);
  }

  readonly property var hash: str => [...str].reduce((h, c) => (Math.imul(31, h) + c.charCodeAt(0)) | 0, 0).toString(36)

  function fuzzyCompare(query, target) {
    [query, target] = [query, target].map(v => v.toLowerCase());

    let [score, qi, mi] = [0, 0, -1];

    [...target].forEach((char, i) => {
      if (char === query[qi]) {
        let last = target[i - 1];
        score += i === mi + 1 ? 5 : 1; // if its in a row theres points added
        if (i === 0 || last === ' ' || last === '-' || last === '_')
          score += 3;
        mi = i;
        qi++;
      }
    });

    return score;
  }

  readonly property var fuzzySearch: (query, targets, key) => query ? targets.map(v => key ? {
        target: v[key],
        item: v
      } : {
        target: v,
        item: v
      }).map(({
        target,
        item
      }) => ({
          score: fuzzyCompare(query, target),
          item
        })).sort((a, b) => b.score - a.score).map(({
        item
      }) => item) : targets

  readonly property var mod: (n, m) => ((n % m) + m) % m
}
