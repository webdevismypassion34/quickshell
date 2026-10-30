pragma Singleton

import QtQml
import Quickshell
import Quickshell.Services.Mpris
import "."

Singleton {
  id: root

  readonly property var player: Mpris.players.values.filter(v => v.dbusName === Settings.player)[0]
  readonly property bool isPlaying: (root.player?.playbackState === MprisPlaybackState.Playing) ?? false
  readonly property string lyricsCacheDir: `${Quickshell.env("XDG_CACHE_HOME")}/quickshell/lyrics`
  readonly property string artsCacheDir: `${Quickshell.env("XDG_CACHE_HOME")}/quickshell/art`

  property string lastTrack: ''
  property var lyrics: ({
      available: false,
      lyrics: []
    })
  property string localArt: ''
  property string currentLyric: lyrics.available ? (lyrics.lyrics.filter(line => line[0] <= player.position).pop()?.[1] ?? '') : ''
  readonly property int currentLyricIndex: lyrics.available ? lyrics.lyrics.reduce((acc, line, i) => line[0] <= player.position ? i : acc, -1) : -1

  Connections {
    target: root.player

    function onPostTrackChanged() {
      const id = `${root.player.trackTitle}:${root.player.trackArtist}`;
      if (id === root.lastTrack)
        return;
      root.lastTrack = id;

      // lyric fetch and cache

      root.lyrics = {
        available: false,
        lyrics: []
      };

      const cachePath = `${root.lyricsCacheDir}/${Utils.hash(id)}.json`;

      Utils.readFile(cachePath, text => {
        if (root.lastTrack !== id)
          return;

        if (text) {
          root.lyrics = JSON.parse(text);
          return;
        }

        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = () => {
          if (xhr.readyState !== XMLHttpRequest.DONE)
            return;

          if (root.lastTrack !== id)
            return;

          if (xhr.status !== 200) {
            return;
          }

          const data = JSON.parse(xhr.responseText);

          if (!data.syncedLyrics) {
            return;
          }

          let lyrics = data.syncedLyrics.split('\n').map(line => {
            const [, mm, ss, cs, words] = line.match(/\[(..):(..)\.(..)\] ?(.*)/);
            const time = (+mm) * 60 + (+ss) + (+cs) / 100;
            return [time, words];
          });

          root.lyrics = {
            available: !!data.syncedLyrics,
            lyrics: lyrics
          };

          Utils.writeFile(cachePath, JSON.stringify(root.lyrics));
        };
        xhr.open('GET', `https://lrclib.net/api/get?track_name=${encodeURIComponent(player.trackTitle)}&artist_name=${encodeURIComponent(player.trackArtist)}`);
        xhr.send();
      });

      // art extraction and cache

      const metadata = root.player.metadata;
      const local = metadata['mpris:trackid'].startsWith('/com/spotify/local/');

      root.localArt = '';

      if (local) {
        const artCachePath = `${root.artsCacheDir}/${Utils.hash(id)}.jpg`;

        Utils.readFile(artCachePath, text => {
          if (root.lastTrack !== id)
            return;

          if (text) {
            root.localArt = artCachePath;
            return;
          }

          Utils.exec(['xdg-user-dir', 'MUSIC'], musicDir => {
            if (root.lastTrack !== id)
              return;

            const file = `${musicDir.trim()}/${metadata['xesam:title']}.mp3`;

            Utils.exec({
              command: ['sh', '-c', `mkdir -p "$(dirname '${artCachePath}')" && ffmpeg -y -i '${file.replace(/'/g, "'\\''")}' -an -c:v copy -update 1 '${artCachePath}'`]
            }, () => {
              if (root.lastTrack !== id)
                return;
              root.localArt = artCachePath;
            });
          });
        });
      }
    }
  }
}
