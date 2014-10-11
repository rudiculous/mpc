/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    var updateState = window.MPD_APP.updateState;
    var formatTime = window.APP_LIB.formatTime;
    var parseMPDResponse = window.APP_LIB.parseMPDResponse;
    window.MPD_APP.views.nowPlaying = components;

    components.SingleEntry = React.createClass({
        clickHandler: function() {
            if (this.props.song.Pos) {
                window.MPD_APP.mpd('play', this.props.song.Pos, function(err) {
                    if (err) {
                        console.error(err);
                    }
                });
            }
        },

        render: function() {
            return (
                <tr className={this.props.active ? 'info now-playing' : ''} onClick={this.clickHandler}>
                    <td style={{'text-align':'center'}}><span className='glyphicon glyphicon-play' style={this.props.active ? {} : {display:'none'}} /></td>
                    <td>{this.props.song.Artist} - {this.props.song.Album}</td>
                    <td style={{'text-align':'right'}}>{this.props.song.Track}</td>
                    <td>{this.props.song.Title}</td>
                    <td style={{'text-align':'right'}}>{formatTime(this.props.song.Time)}</td>
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

        cleanUpHandlers: function() {
            if (this.__mpdChangedHandler) {
                document.removeEventListener('mpd:changed', this.__mpdChangedHandler);
                delete this.__mpdChangedHandler;
            }
        },

        componentDidMount: function() {
            var self = this;

            this.cleanUpHandlers();

            this.__mpdChangedHandler = function(event) {
                var what = null;

                if (event.detail) {
                    what = event.detail.what;
                }

                if (what === 'player' || what === 'playlist') {
                    self.fetchAndSetState();
                }
            };

            document.addEventListener('mpd:changed', this.__mpdChangedHandler, false);
        },

        componentWillUnmount: function() {
            this.cleanUpHandlers();
        },

        fetchAndSetState: function() {
            var self = this;

            var currentsong = document.getElementById('currentsong');

            window.MPD_APP.mpd('playlistinfo', function(err, playlistinfo) {
                var data = {};

                if (err) {
                    return console.error(err);
                }

                data.songs = parseMPDResponse(playlistinfo, {
                    'file': function(entry) {
                        var active = currentsong.dataset
                                && currentsong.dataset.pos === entry.Pos;

                        return <components.SingleEntry key={entry.Pos} song={entry} active={active} />
                    }
                });

                self.replaceState(data);
            });
        },

        render: function() {
            return (
                <div className='now-playing'>
                    <h1>Now Playing</h1>
                    <table className='playlist table table-striped table-condensed table-hover'>
                        <col style={{width: '65px'}} />
                        <col style={{width: '400px'}} />
                        <col style={{width: '50px'}} />
                        <col />
                        <col style={{width: '70px'}} />

                        <thead>
                            <th>Playing</th>
                            <th>Artist - Album</th>
                            <th>Track</th>
                            <th>Title</th>
                            <th>Duration</th>
                        </thead>

                        <tfoot />

                        <tbody>
                            {this.state.songs}
                        </tbody>
                    </table>
                </div>
            );
        }
    });

    components.mount = function(where, req) {
        updateState({
            'activeTab': 'now_playing',
            'title': 'Now Playing'
        });

        React.renderComponent(
            <components.NowPlaying />,
            where
        );
    };
}());
