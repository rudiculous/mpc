/** @jsx React.DOM */

(function($) {
    var Button = React.createClass({
        action: function(event) {
            event.preventDefault();
            window.APP.mpd(this.props.action, function(err) {
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

    var Controls = React.createClass({
        getInitialState: function() {
            this.fetchAndSetState();
            return {};
        },

        componentDidMount: function() {
            var self = this;

            $(window).on('mpd:changed:player', function() {
                self.fetchAndSetState();
            });
        },

        fetchAndSetState: function() {
            var self = this;

            window.APP.mpd('status', function(err, status) {
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
                playpause = <Button action='play'  icon='play'  />;
            }
            else {
                playpause = <Button action='pause' icon='pause' />;
            }

            return (
                <div className="controls-buttons">
                    <Button action='previous' icon='fast-backward' />
                    {playpause}
                    <Button action='stop'     icon='stop'          />
                    <Button action='next'     icon='fast-forward'  />
                </div>
            );
        }
    });

    var Player = React.createClass({
        getInitialState: function() {
            this.fetchAndSetState();
            return {};
        },

        componentDidMount: function() {
            var self = this;

            $(window).on('mpd:changed:player', function() {
                self.fetchAndSetState();
            });
        },

        fetchAndSetState: function() {
            var self = this;

            window.APP.mpd('currentsong', function(err, currentsong) {
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
            <Controls />
            <Player />
        </div>,
        document.getElementById('controls')
    );
}(jQuery));
