/** @jsx React.DOM */

var Controls = React.createClass({
    play: function(e) {
        e.preventDefault();
        window.APP.mpd('play');
    },

    stop: function(e) {
        e.preventDefault();
        window.APP.mpd('stop');
    },

    pause: function(e) {
        e.preventDefault();
        window.APP.mpd('pause');
    },

    next: function(e) {
        e.preventDefault();
        window.APP.mpd('next');
    },

    previous: function(e) {
        e.preventDefault();
        window.APP.mpd('previous');
    },

    render: function() {
        return (
            <div className="controls-buttons">
                <a onClick={this.previous}><span className="glyphicon glyphicon-fast-backward" /></a>
                <a onClick={this.play}><span className="glyphicon glyphicon-play" /></a>
                <a onClick={this.stop}><span className="glyphicon glyphicon-stop" /></a>
                <a onClick={this.pause}><span className="glyphicon glyphicon-pause" /></a>
                <a onClick={this.next}><span className="glyphicon glyphicon-fast-forward" /></a>
            </div>
        );
    }
});

var Player = React.createClass({
    getInitialState: function() {
        var self = this;

        window.APP.mpd.onUpdate(function(state) {
            self.setState(state);
        });

        window.APP.mpd('status');

        return {};
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
