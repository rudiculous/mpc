/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    var updateState = window.MPD_APP.updateState;
    window.MPD_APP.views.routeNotFound = components;

    components.RouteNotFound = React.createClass({
        render: function() {
            return (
                <div className='route-not-found'>
                    <h1>Not Found</h1>

                    <p>
                        The URL you are trying to call was not found.
                    </p>

                    <ul>
                        <li><a href="/">Home</a></li>
                    </ul>
                </div>
            );
        }
    });

    components.mount = function(where, req) {
        updateState({
            'activeTab': null,
            'title': 'Not Found'
        });

        React.renderComponent(
            <components.RouteNotFound />,
            where
        );
    };
}());
