/** @jsx React.DOM */

(function($) {
    "use strict";

    var Browser = React.createClass({
        render: function() {
            return (
                <div className='music-browser' />
            );
        }
    });

    React.renderComponent(
        <Browser />,
        document.getElementById('main')
    );
}(jQuery));
