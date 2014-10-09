/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    window.MPD_APP.views.browser = components;

    components.Browser = React.createClass({
        render: function() {
            return (
                <div className='music-browser'>
                    <h1>Browser</h1>
                </div>
            );
        }
    });

    components.mount = function(where, req) {
        React.renderComponent(
            <components.Browser />,
            where
        );
    };
}());
