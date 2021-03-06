/*
Copyright (C) 2013 Micah Losli <micah.losli@gmail.com>

This file is part of Panpipe.

Panpipe is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Panpipe is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Panpipe.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0 as Popups
import Ubuntu.Components.ListItems 1.0 as ListItem
import "components"

Item {
    property alias playerControls: controlBar

    /* Station name */
    Label {
        id: stationLabel
        objectName: "label"
        anchors {
            top: parent.top
            topMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }
        text: stationName
        width: (parent.width - units.gu(4))
        elide: Text.ElideRight
        fontSize: "large"
        horizontalAlignment: Text.AlignLeft
    }

    /* Album artwork */
    Rectangle {
        id: albumArt
        anchors {
            top: stationLabel.bottom
            topMargin: units.gu(2)
            horizontalCenter: parent.horizontalCenter
        }
        width: Math.min( (parent.width - units.gu(2)), (Math.abs(stationLabel.y - songLabel.y) - (stationLabel.height + songLabel.height + playbackRemainingLabel.height)) )
        height: albumArt.width

        MouseArea {
            id: albumArtMouseArea
            anchors.fill: parent
            onPressAndHold: PopupUtils.open(songMenu)
        }

        CrossFadeImage {
            id: currentArt
            anchors.fill: parent
            source: playlist[currentPlaylistIndex].albumArtUrl
            fadeDuration: 1000
            fillMode: Image.PreserveAspectCrop
        }

        Image {
            id: songRatingArt
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            width: parent.width / 8
            height: width
            source: ((playlist[currentPlaylistIndex].songRating == 1) || (_temp_song_thumbs_up == 1)) ? Qt.resolvedUrl("./resources/icons/favorite-selected.svg") : ""
        }
    }

    /* Progress bar */
    RectangleProgressBar {
        id: songProgressBar
        anchors {
            top: albumArt.bottom
            left: albumArt.left
            right: albumArt.right
        }
        height: units.gu(0.5)

        percentageComplete: playbackPercentage
        backgroundColor: UbuntuColors.coolGrey
        progressColor: UbuntuColors.orange
    }

    /* Playback position */
    Label {
        id: playbackPositionLabel
        anchors {
            top: songProgressBar.bottom
            left: songProgressBar.left
        }
        fontSize: "small"
        text: (audioSourceUrl != "") ? __durationToString(playbackPosition) : "0:00"
    }

    /* Playback remaining */
    Label {
        id: playbackRemainingLabel
        anchors {
            top: songProgressBar.bottom
            right: songProgressBar.right
        }
        fontSize: "small"
        text: (audioSourceUrl != "") ? "-" + __durationToString(playbackDuration - playbackPosition) : "0:00"
    }

    /* Song name */
    Label {
        id: songLabel
        anchors {
            bottom: artistLabel.top
            horizontalCenter: parent.horizontalCenter
        }
        width: (parent.width - units.gu(4))
        elide: Text.ElideRight
        fontSize: "large"
        horizontalAlignment: Text.AlignHCenter
        text: i18n.tr(playlist[currentPlaylistIndex].songName)
    }

    /* Artist name */
    Label {
        id: artistLabel
        anchors {
            bottom: albumLabel.top
            horizontalCenter: parent.horizontalCenter
        }
        width: (parent.width - units.gu(4))
        elide: Text.ElideRight
        fontSize: "medium"
        horizontalAlignment: Text.AlignHCenter
        text: (playlist[currentPlaylistIndex].artistName != "") ? i18n.tr("By " + playlist[currentPlaylistIndex].artistName) : i18n.tr("")
    }


    /* Album name */
    Label {
        id: albumLabel
        anchors {
            bottom: controlBar.top
            bottomMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }
        width: (parent.width - units.gu(4))
        elide: Text.ElideRight
        fontSize: "medium"
        horizontalAlignment: Text.AlignHCenter
        text: (playlist[currentPlaylistIndex].albumName != "") ? i18n.tr("On " + playlist[currentPlaylistIndex].albumName) : i18n.tr("")
    }

    UbuntuShape {
        id: controlBar

        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }
        width: {
            if(parent.width > units.gu(40)) {
                parent.width - units.gu(12)
            } else {
                parent.width - units.gu(4)
            }
        }
        height: Math.min(units.gu(8), (width / 4) )
        color: headerColor
        radius: "medium"

        Row {
            anchors.fill: parent

            /* Note: units.gu(32) is the combined width of the buttons */
            spacing: Math.max( ((parent.width - units.gu(32)) / 3), 0 )

            height: parent.height

            /* Play / Pause button */
            Item {
                id: playPause
                height: parent.height
                width: parent.height

                Image {
                    source: (playButtonState) ? Qt.resolvedUrl("resources/icons/media-playback-pause.svg") : Qt.resolvedUrl("resources/icons/media-playback-start.svg")
                    sourceSize.width: parent.width
                    sourceSize.height: parent.height
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        playButtonState = !playButtonState;
                    }
                }
            }

            /* Next track button */
            Item {
                id: nextTrack
                height: parent.height
                width: parent.height

                Image {
                    source: Qt.resolvedUrl("resources/icons/media-skip-forward.svg")
                    sourceSize.width: parent.width
                    sourceSize.height: parent.height
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        nextTrackPressed();
                    }
                }
            }

            /* Thumbs up button */
            Item {
                id: thumbsUp
                height: parent.height
                width: parent.height

                Image {
                    source: Qt.resolvedUrl("resources/icons/arrow-up.svg")
                    anchors.fill: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(playlist[currentPlaylistIndex].songRating != 1) {
                            thumbsUpPressed();
                            _temp_song_thumbs_up = 1;
                        }
                    }
                }
            }

            /* Thumbs down button */
            Item {
                id: thumbsDown
                height: parent.height
                width: parent.height

                Image {
                    source: Qt.resolvedUrl("resources/icons/arrow-down.svg")
                    anchors.fill: parent

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(playlist[currentPlaylistIndex].songRating != -1) {
                            thumbsDownPressed();
                        }
                    }
                }
            }
        }
    }

    /* Song options popover */
    Component {
        id: songMenu

        Popups.Popover {
            id: popover

            autoClose: true

            Column {
                id: containerLayout
                anchors {
                    left: parent.left
                    right: parent.right
                }
                ListItem.Header { text: "Song Options" }
                ListItem.Standard {
                    text: "Explore Song"
                    onClicked: {
                        hide();
                        webviewURL = playlist[currentPlaylistIndex].songExplorerUrl;
                        pagestack.push(webViewPage);
                    }
                }
                ListItem.Standard {
                    text: "Explore Artist"
                    onClicked: {
                        hide();
                        webviewURL = playlist[currentPlaylistIndex].artistExplorerUrl;
                        pagestack.push(webViewPage);
                    }
                }
                ListItem.Standard {
                    text: "Song Details"
                    onClicked: {
                        hide();
                        webviewURL = playlist[currentPlaylistIndex].songDetailUrl;
                        pagestack.push(webViewPage);
                    }
                }
                ListItem.Standard {
                    text: "Album Details"
                    onClicked: {
                        hide();
                        webviewURL = playlist[currentPlaylistIndex].albumDetailUrl;
                        pagestack.push(webViewPage);
                    }
                }
                ListItem.Standard {
                    text: "Artist Details"
                    onClicked: {
                        hide();
                        webviewURL = playlist[currentPlaylistIndex].artistDetailUrl;
                        pagestack.push(webViewPage);
                    }
                }
                ListItem.Standard {
                    text: "Buy from Amazon"
                    onClicked: {
                        hide();
                        Qt.openUrlExternally(playlist[currentPlaylistIndex].amazonAlbumUrl)
                    }
                }
                ListItem.Standard {
                    text: "Buy from iTunes"
                    onClicked: {
                        hide();
                        Qt.openUrlExternally(playlist[currentPlaylistIndex].itunesSongUrl)
                    }
                }
            }
        }
    }

    /* Show the song options popover */
    function displaySongOptions() {
        PopupUtils.open(songMenu)
    }

    /* Converts an duration in ms to a formated string ("minutes:seconds") */
    function __durationToString(duration) {
        var minutes = Math.floor((duration/1000) / 60);
        var seconds = Math.floor((duration/1000)) % 60;
        return minutes + ":" + (seconds<10 ? "0"+seconds : seconds);
    }
}
