/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
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
            return {};
        },

        componentDidMount: function() {
            var self = this;

            document.addEventListener('mpd:changed:player', function() {
                self.fetchAndSetState();
            }, false);
        },

        fetchAndSetState: function() {
            var self = this;

            window.MPD_APP.mpd('status', function(err, status) {
                var data = {},
                    lines, i, line, index, key, val;

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

                self.setState(data);
            });
        },

        render: function() {
            var playpause;
            if (this.state.state !== 'play') {
                playpause = <components.PlaybackButton action='play'  icon='play'  />;
            }
            else {
                playpause = <components.PlaybackButton action='pause' icon='pause' />;
            }

            return (
                <div className="controls-buttons">
                    <components.PlaybackButton action='previous' icon='fast-backward' />
                    {playpause}
                    <components.PlaybackButton action='stop'     icon='stop'          />
                    <components.PlaybackButton action='next'     icon='fast-forward'  />
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

            document.addEventListener('mpd:changed:player', function() {
                self.fetchAndSetState();
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

                self.setState(data);
            });
        },

        render: function() {
            return (
                <div className="controls-player">
                    {this.state.Artist} - {this.state.Title}
                </div>
            );
        }
    });

    React.renderComponent(
        <div className="controls-container">
            <components.Controls />
            <components.Player />
        </div>,
        document.getElementById('controls')
    );
}());
