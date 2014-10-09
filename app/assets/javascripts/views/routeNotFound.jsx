/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    window.MPD_APP.views.routeNotFound = components;

    components.RouteNotFound = React.createClass({
        render: function() {
            return (
                <div className='route-not-found'>
                    <h1>Not Found</h1>
                </div>
            );
        }
    });

    components.mount = function(where, req) {
        React.renderComponent(
            <components.RouteNotFound />,
            where
        );
    };
}());
