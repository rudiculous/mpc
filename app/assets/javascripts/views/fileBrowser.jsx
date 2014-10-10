/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    var updateState = window.MPD_APP.updateState;
    var formatTime = window.APP_LIB.formatTime;
    window.MPD_APP.views.fileBrowser = components;

    components.Directory = React.createClass({
        contextMenu: function(event) {
            event.preventDefault();
        },

        render: function() {
            var segments = this.props.entry.directory.split('/'),
                lastSegment = segments[segments.length - 1];

            return (
                <tr onContextMenu={this.contextMenu}>
                    <td colSpan='3'>
                        <a href={'/file_browser?pathName=' + encodeURIComponent(this.props.entry.directory)}>
                            {lastSegment}
                        </a>
                    </td>
                    <td />
                </tr>
            );
        }
    });

    components.File = React.createClass({
        render: function() {
            return (
                <tr>
                    <td>{this.props.entry.Artist} - {this.props.entry.Album}</td>
                    <td style={{'text-align':'right'}}>{this.props.entry.Track}</td>
                    <td>{this.props.entry.Title}</td>
                    <td style={{'text-align':'right'}}>{formatTime(this.props.entry.Time)}</td>
                </tr>
            );
        }
    });

    components.FileBrowser = React.createClass({
        getInitialState: function() {
            this.fetchAndSetState();

            return {
                entries: []
            };
        },

        fetchAndSetState: function() {
            var self = this;

            window.MPD_APP.mpd('lsinfo', this.props.pathName, function(err, playlistinfo) {
                var data = {},
                    lines, i, line, index, key, val, entry, active, uniqueKey = 0;

                data.entries = [];

                if (err) {
                    return console.error(err);
                }

                lines = playlistinfo.split('\n');
                entry = null;

                for (i = 0; i < lines.length; i++) {
                    line = lines[i];
                    index = line.indexOf(': ');
                    if (index > -1) {
                        key = line.substring(0, index);
                        val = line.substring(index + 2);

                        // The first key is 'file' or 'directory'.
                        if (key === 'file' || key === 'directory') {
                            if (entry !== null) {
                                if (entry.directory) {
                                    data.entries.push(
                                        <components.Directory entry={entry} key={uniqueKey++} />
                                    );
                                }
                                else if (entry.file) {
                                    data.entries.push(
                                        <components.File entry={entry} key={uniqueKey++} />
                                    );
                                }
                            }

                            entry = {};
                        }

                        entry[key] = val;
                    }
                }

                if (entry !== null) {
                    if (entry.directory) {
                        data.entries.push(
                            <components.Directory entry={entry} key={uniqueKey++} />
                        );
                    }
                    else if (entry.file) {
                        data.entries.push(
                            <components.File entry={entry} key={uniqueKey++} />
                        );
                    }
                }

                self.replaceState(data);
            });
        },

        render: function() {
            var crumbs = [],
                pathName = this.props.pathName,
                pathSoFar = '',
                crumbCount = 0,
                segments, i, segment;

            if (pathName) {
                crumbs.push(
                    <li key={crumbCount++}><a href='/file_browser'>home</a></li>
                );

                segments = pathName.split('/');

                for (i = 0; i < segments.length; i++) {
                    segment = segments[i];
                    if (pathSoFar !== '') {
                        pathSoFar += '/';
                    }
                    pathSoFar += segment;

                    if (i < segments.length - 1) {
                        crumbs.push(
                            <li key={crumbCount++}><a href={'/file_browser?pathName=' + encodeURIComponent(pathSoFar)}>{segment}</a></li>
                        );
                    }
                    else {
                        crumbs.push(
                            <li key={crumbCount++} className='active'>{segment}</li>
                        );
                    }
                }
            }
            else {
                crumbs.push(
                    <li key={crumbCount++} className='active'>home</li>
                );
            }

            return (
                <div className='music-file-browser'>
                    <h1>File Browser</h1>

                    <ol className='breadcrumb'>
                        {crumbs}
                    </ol>

                    <table className='playlist table table-striped table-condensed table-hover'>
                        <col style={{width: '400px'}} />
                        <col style={{width: '50px'}} />
                        <col />
                        <col style={{width: '70px'}} />

                        <thead>
                            <th>Artist - Album</th>
                            <th>Track</th>
                            <th>Title</th>
                            <th>Duration</th>
                        </thead>

                        <tfoot />

                        <tbody>
                            {this.state.entries}
                        </tbody>
                    </table>
                </div>
            );
        }
    });

    components.mount = function(where, req) {
        var pathName = req.params.pathName;

        if (Array.isArray(pathName) && pathName.length > 0) {
            pathName = pathName[0];
        }
        else {
            pathName = '';
        }

        React.renderComponent(
            <components.FileBrowser pathName={pathName} />,
            where
        );

        updateState({
            'activeTab': 'file_browser'
        });
    };
}());
