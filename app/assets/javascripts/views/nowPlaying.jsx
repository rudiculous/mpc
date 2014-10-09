/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    window.MPD_APP.views.nowPlaying = components;

    components.NowPlaying = React.createClass({
        render: function() {
            return (
                <div className='now-playing' />
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

