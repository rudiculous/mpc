/** @jsx React.DOM */

(function() {
    var Button = React.createClass({
        action: function(event) {
            event.preventDefault();
            window.APP.mpd(this.props.action);
        },

        getClass: function() {
            return 'glyphicon glyphicon-' + this.props.icon;
        },

        render: function() {
            return <a onClick={this.action}><span className={this.getClass()} /></a>
        }
    });

    var Controls = React.createClass({
        getInitialState: function() {
            return this.getState();
        },

        componentDidMount: function() {
            var self = this;

            window.APP.mpd.onceSocketReady(function(state) {
                self.setState(self.getState(state));
            });

            window.APP.mpd.onUpdate(function(state) {
                self.setState(self.getState(state));
            });
        },

        getState: function(state) {
            if (arguments.length === 0) {
                state = window.APP.mpd.state;
            }

            return {
                'state': state.state
            };
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
            return this.getState();
        },

        componentDidMount: function() {
            var self = this;

            window.APP.mpd.onceSocketReady(function(state) {
                self.setState(self.getState(state));
            });

            window.APP.mpd.onUpdate(function(state) {
                self.setState(self.getState(state));
            });
        },

        getState: function(state) {
            if (arguments.length === 0) {
                state = window.APP.mpd.state;
            }

            return {
                'Artist': window.APP.mpd.state.Artist,
                'Title': window.APP.mpd.state.Title
            };
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
}());
