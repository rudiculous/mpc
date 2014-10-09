/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    window.MPD_APP.views.nowPlaying = components;

    components.SingleEntry = React.createClass({
        render: function() {
            return (
                <tr className={this.props.active ? 'info now-playing' : ''}>
                    <td>{this.props.song.Artist}</td>
                    <td>{this.props.song.Album}</td>
                    <td>{this.props.song.Title}</td>
                </tr>
            );
        }
    });

    components.NowPlaying = React.createClass({
        getInitialState: function() {
            this.fetchAndSetState();

            return {
                songs: []
            };
        },

        componentDidMount: function() {
            var self = this;

            document.addEventListener('mpd:changed', function(event) {
                var what = null;

                if (event.detail) {
                    what = event.detail.what;
                }

                if (what === 'player' || what === 'playlist') {
                    self.fetchAndSetState();
                }
            }, false);
        },

        fetchAndSetState: function() {
            var self = this;

            var currentsong = document.getElementById('currentsong');

            window.MPD_APP.mpd('playlistinfo', function(err, playlistinfo) {
                var data = {},
                    lines, i, line, index, key, val, song, active;

                data.songs = [];

                if (err) {
                    return console.error(err);
                }

                lines = playlistinfo.split('\n');
                song = null;

                for (i = 0; i < lines.length; i++) {
                    line = lines[i];
                    index = line.indexOf(': ');
                    if (index > -1) {
                        key = line.substring(0, index);
                        val = line.substring(index + 2);

                        // The first key is 'file'.
                        if (key === 'file') {
                            if (song !== null) {
                                active = currentsong.dataset
                                        && currentsong.dataset.pos === song.Pos;

                                data.songs.push(
                                    <components.SingleEntry key={song.Pos} song={song} active={active} />
                                );
                            }

                            song = {};
                        }

                        song[key] = val;
                    }
                }

                if (song !== null) {
                    data.songs.push(
                        <components.SingleEntry key={song.Pos} song={song} />
                    );
                }

                self.replaceState(data);
            });
        },

        render: function() {
            return (
                <div className='now-playing'>
                    <h1>Now Playing</h1>
                    <table className='playlist table table-striped table-condensed'>
                        <tbody>
                            {this.state.songs}
                        </tbody>
                    </table>
                </div>
            );
        }
    });

    components.mount = function(where, req) {
        React.renderComponent(
            <components.NowPlaying />,
            where
        );
    };
}());

