/** @jsx React.DOM */

(function() {
    "use strict";

    var components = {};
    var updateState = window.MPD_APP.updateState;
    var formatTime = window.APP_LIB.formatTime;
    var parseMPDResponse = window.APP_LIB.parseMPDResponse;
    window.MPD_APP.views.fileBrowser = components;

    components.Directory = React.createClass({
        contextMenu: function(event) {
            event.preventDefault();
        },

        render: function() {
            var segments = this.props.entry.directory.split('/'),
                lastSegment = segments[segments.length - 1];

            return (
                <li onContextMenu={this.contextMenu} className='list-group-item'>
                    <a href={'/file_browser?pathName=' + encodeURIComponent(this.props.entry.directory)}>
                        {lastSegment}
                    </a>
                </li>
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
                loading: true,
                entries: [],
                files: [],
                directories: []
            };
        },

        fetchAndSetState: function() {
            var self = this;

            window.MPD_APP.mpd('lsinfo', this.props.pathName, function(err, playlistinfo) {
                var count = 0, data = {};

                if (err) {
                    self.setState({
                        loading: false,
                        error: err
                    });
                    return console.error(err);
                }

                data.directories = [];
                data.files = [];

                data.entries = parseMPDResponse(playlistinfo, {
                    'file': function(entry) {
                        var file = <components.File entry={entry} key={count++} />;
                        data.files.push(file);
                        return file;
                    },
                    'directory': function(entry) {
                        var directory = <components.Directory entry={entry} key={count++} />;
                        data.directories.push(directory);
                        return directory;
                    }
                });

                self.replaceState(data);
            });
        },

        render: function() {
            var crumbs = [],
                pathName = this.props.pathName,
                pathSoFar = '',
                crumbCount = 0,
                segments, i, segment,
                files,
                directories = '';

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

            if (this.state.loading) {
                return (
                    <div className='music-file-browser'>
                        <h1>File Browser</h1>

                        <ol className='breadcrumb'>{crumbs}</ol>

                        <div className='alert alert-info'>Loading&hellip;</div>
                    </div>
                );
            }
            else if (this.state.error) {
                return (
                    <div className='music-file-browser'>
                        <h1>File Browser</h1>

                        <ol className='breadcrumb'>{crumbs}</ol>

                        <div className='alert alert-danger'>
                            <strong>An error occurred!</strong>
                            <pre>
                                {this.state.error}
                            </pre>
                        </div>
                    </div>
                );
            }
            else {
                if (this.state.directories.length) {
                    directories = (
                        <div>
                            <h2>Directories</h2>
                            <ul className='list-group'>
                                {this.state.directories}
                            </ul>
                        </div>
                    );
                }

                if (this.state.files.length) {
                    files = (
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
                                {this.state.files}
                            </tbody>
                        </table>
                    );
                }
                else {
                    files = <p>No files found.</p>;
                }

                return (
                    <div className='music-file-browser'>
                        <h1>File Browser</h1>

                        <ol className='breadcrumb'>{crumbs}</ol>

                        {directories}

                        <h2>Files</h2>
                        {files}
                    </div>
                );
            }
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

        updateState({
            'activeTab': 'file_browser',
            'title': 'File Browser'
        });

        React.renderComponent(
            <components.FileBrowser pathName={pathName} />,
            where
        );
    };
}());
