/** @jsx React.DOM */

(function($) {
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
            return window.APP.mpd.getState();
        },

        componentDidMount: function() {
            var self = this;

            $(window).on('mpd:stateUpdate', function() {
                self.setState(window.APP.mpd.getState());
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
            return window.APP.mpd.getState();
        },

        componentDidMount: function() {
            var self = this;

            $(window).on('mpd:stateUpdate', function() {
                self.setState(window.APP.mpd.getState());
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
