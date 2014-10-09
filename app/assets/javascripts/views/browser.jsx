/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    window.MPD_APP.views.browser = components;

    components.Browser = React.createClass({
        render: function() {
            return (
                <div className='music-browser' />
            );
        }
    });

    components.mount = function(where) {
        React.renderComponent(
            <components.Browser />,
            where
        );
    };
}());
