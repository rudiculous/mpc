/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    var formatTime = window.APP_LIB.formatTime;

    /**
     * In order to keep the progress bar of the player up to date, we
     * have to keep track of the elapsed time. We don't automatically
     * get this value, so we try to update it ourselves. Every once in a
     * while we have to check with the server, just to make sure we are
     * still in sync.
     */
    var progressUpdater = null;
    var progressInterval = 15000;

    window.MPD_APP.views.playbackControls = components;

    components.PlaybackButton = React.createClass({
        action: function(event) {
            event.preventDefault();
            window.MPD_APP.mpd(this.props.action, function(err) {
                if (err) {
                    console.error(err);
                }
            });
        },

        getClass: function() {
            return 'glyphicon glyphicon-' + this.props.icon;
        },

        render: function() {
            return (
                <a className='player-control' onClick={this.action}>
                    <span className={this.getClass()} />
                </a>
            );
        }
    });

    components.Controls = React.createClass({
        getInitialState: function() {
            this.fetchAndSetState();
            return {
                'progress': {}
            };
        },

        componentDidMount: function() {
            var self = this;

            // Increases progress while playing.
            setInterval(function() {
                if (self.state.state !== 'play') {
                    return;
                }

                if (self.state.progress && self.state.progress.elapsed) {
                    self.setState({
                        'progress': {
                            'elapsed': self.state.progress.elapsed + 1,
                            'duration': self.state.progress.duration
                        }
                    });
                }
            }, 1000);

            document.addEventListener('mpd:changed:player', function() {
                self.fetchAndSetState();
            }, false);
        },

        fetchAndSetState: function() {
            var self = this;

            if (progressUpdater !== null) {
                clearTimeout(progressUpdater);
                progressUpdater = null;
            }

            window.MPD_APP.mpd('status', function(err, status) {
                var data = {},
                    lines, i, line, index, key, val, elapsed, duration;

                if (err) {
                    return console.error(err);
                }

                lines = status.split('\n');
                for (i = 0; i < lines.length; i++) {
                    line = lines[i];
                    index = line.indexOf(': ');
                    if (index > -1) {
                        key = line.substring(0, index);
                        val = line.substring(index + 2);
                        data[key] = val;
                    }
                }

                data.progress = {};
                if (data.time) {
                    i = data.time.indexOf(':');

                    if (i > -1) {
                        data.progress.elapsed = Number(data.time.substring(0, i));
                        data.progress.duration = Number(data.time.substring(i + 1));
                    }
                }

                self.replaceState(data);

                // If currently playing, check the status again in a
                // little while.
                if (data.state === 'play') {
                    progressUpdater = setTimeout(function() {
                        self.fetchAndSetState();
                    }, progressInterval);
                }
            });
        },

        render: function() {
            var playpause, progress = 0;
            if (this.state.state !== 'play') {
                playpause = <components.PlaybackButton action='play'  icon='play'  />;
            }
            else {
                playpause = <components.PlaybackButton action='pause' icon='pause' />;
            }

            if (this.state.progress && this.state.progress.duration) {
                progress = 100 * this.state.progress.elapsed / this.state.progress.duration;
                if (progress > 100) progress = 100;
                if (!(progress >= 0)) progress = 0;
            }

            return (
                <div>
                    <div className="controls-buttons">
                        <components.PlaybackButton action='previous' icon='fast-backward' />
                        {playpause}
                        <components.PlaybackButton action='stop'     icon='stop'          />
                        <components.PlaybackButton action='next'     icon='fast-forward'  />
                    </div>
                    <div className='playing-prog'>
                        <div className='playing-prog-bar' style={{width: String(progress) + '%'}} />
                    </div>
                </div>
            );
        }
    });

    components.Player = React.createClass({
        getInitialState: function() {
            this.fetchAndSetState();
            return {};
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

            window.MPD_APP.mpd('currentsong', function(err, currentsong) {
                var data = {},
                    lines, i, line, index, key, val;

                if (err) {
                    return console.error(err);
                }

                lines = currentsong.split('\n');
                for (i = 0; i < lines.length; i++) {
                    line = lines[i];
                    index = line.indexOf(': ');
                    if (index > -1) {
                        key = line.substring(0, index);
                        val = line.substring(index + 2);
                        data[key] = val;
                    }
                }

                self.replaceState(data);
            });
        },

        render: function() {
            return (
                <div className="controls-player">
                    <a href="/now_playing" id="currentsong" data-pos={this.state.Pos}>
                        {this.state.Artist} - {this.state.Title}
                    </a>
                </div>
            );
        }
    });

    components.mount = function(where) {
        React.renderComponent(
            <div className="controls-container">
                <components.Controls />
                <components.Player />
            </div>,
            where
        );
    };
}());
