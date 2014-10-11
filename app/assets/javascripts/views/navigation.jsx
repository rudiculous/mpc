/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    window.MPD_APP.views.navigation = components;

    components.Item = React.createClass({
        getInitialState: function() {
            var state = history.state;

            if (state === null) {
                state = {};
            }

            return state;
        },

        componentDidMount: function() {
            var self = this;

            document.addEventListener('state:updated', function() {
                var state = history.state;

                if (state === null) {
                    state = {};
                }

                self.replaceState(history.state);
            }, false);
        },

        render: function() {
            var className = 'navigation-menu-item';

            if (this.state.activeTab === this.props.key) {
                className += ' active';
            }

            return (
                <li className={className}>
                    <a href={this.props.href}>{this.props.label}</a>
                </li>
            );
        }
    });

    components.Menu = React.createClass({
        render: function() {
            return (
                <ul className='navigation-menu nav nav-pills nav-stacked'>
                    <components.Item href='/now_playing'  label='Now Playing'  key='now_playing'  />
                    <components.Item href='/file_browser' label='File Browser' key='file_browser' />
                </ul>
            );
        }
    });

    components.mount = function(where) {
        React.renderComponent(
            <components.Menu />,
            where
        );
    };
}());
