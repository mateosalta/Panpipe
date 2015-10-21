/*
Copyright (C) 2015 Micah Losli <micah.losli@gmail.com>

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

import "models"
import "pandora"

import "./AudioStream.js" as AudioStream

Item {
    /* Signals */
    signal loginSuccess(bool success)
    signal stationsUpdated()
    signal moreSongsRetrieved()
    signal serverError()

    /* Public methods */
    /*
    login(string username, string password)
    selectStation(string stationToken)
    setStationSortingMethodAlphabetical(bool setAlphabetical)
    nextSong()

    */

    /* Aliases */
    property alias connected: pandoraInterfaceComponent.connected
    property alias stationsData: userStationsData.model
    property alias stationSortMethod: userStationsData.sortMethod
    property alias playlistData: currentStationPlaylist.model
    property alias currentSong: currentStationPlaylist.currentPlaylistItem
//    property alias quickMixStationIdList
    property alias playlistAvailable: currentStationPlaylist.playlistDataAvailable

    /* Public properties */
    property bool loggingIn
    property bool loadingStations
    property bool loadingPlaylist
    property bool loading: loggingIn || loadingStations || loadingPlaylist

    property bool stationSelected
    property string currentStationId
    property string currentStationName
    property string currentStationToken

    property var currentSongItem
    property string currentSongAudioUrl:_selectAudioUrl(selectedAudioStream)//: currentSong.additionalAudioUrl;
    property string currentSongArtist
    property string selectedAudioStream

    /* Private properties */


    /* Initialization */
    Component.onCompleted: {
        selectedAudioStream = AudioStream.Streams.DFLT_MED;

    }

    /* Pandora interface component */
    PandoraInterface {
        id: pandoraInterfaceComponent

        onLoginFailed: {
            loginSuccess(false);
        }

        onLoginSucceeded: {
            loginSuccess(true);
        }
    }

    /* User stations data */
    PandoraStationsModel {
        id: userStationsData

        pandoraInterface: pandoraInterfaceComponent

        onUpdated: {
            loadingStations = false;
            stationsUpdated();
        }

        onDataTimeout: {
            loadingStations = false;
        }

        onReceivedError: {
            loadingStations = false;
        }

    }



    /* Current station playlist data */
    PandoraPlaylistModel {
        id: currentStationPlaylist

        pandoraInterface: pandoraInterfaceComponent

        onUpdated: {
            moreSongsRetrieved();
            loadingPlaylist = false;
        }

    }


    /* Event handlers */
    onLoginSuccess: {
        loggingIn = false;
        if(success == true) {
            loadingStations = true;
            userStationsData.getStationData();
        }
    }

    onSelectedAudioStreamChanged: {
        currentStationPlaylist.pandoraInterface.audioStreamString = selectedAudioStream;
    }



    /* Public method implementations */
    function login(username, password) {
        if(username && password && typeof(username) == "string" && typeof(password) == "string") {
            loggingIn = true;
            pandoraInterfaceComponent.login(username, password, null);
        }
    }

    function selectStation(stationToken) {
        if(stationToken !== currentStationToken){
            loadingPlaylist = true;
            currentStationPlaylist.currentStationToken = stationToken;  //also loads some songs
        }
    }

    function setStationSortingMethodAlphabetical(setAlphabetical) {
        if(typeof(setAlphabetical) == "bool") {
            if(setAlphabetical) {
                userStationsData.sortMethod = "alphabetical";
            }
            else {
                userStationsData.sortMethod = "date";
            }
        }
    }

    function nextSong() {
        if(currentStationToken !== "") {
            currentStationPlaylist.loadNextSong();
        }
    }


    /* Private methods */

    function _selectAudioUrl(selectedAudioStreamName) {
        switch(selectedAudioStreamName) {
            case AudioStream.Streams.DFLT_LOW:
                currentSongAudioUrl = currentSong.audioUrlMap.lowQuality.audioUrl;
                break;
            case AudioStream.Streams.DFLT_MED:
                currentSongAudioUrl = currentSong.audioUrlMap.mediumQuality.audioUrl;
                break;
            case AudioStream.Streams.DFLT_HI:
                currentSongAudioUrl = currentSong.audioUrlMap.highQuality.audioUrl;
                break;
            case AudioStream.Streams.AAC_MONO_40:
            case AudioStream.Streams.AAC_64:
            case AudioStream.Streams.AACP_32:
            case AudioStream.Streams.AACP_64:
            case AudioStream.Streams.AACP_ADTS_24:
            case AudioStream.Streams.AACP_ADTS_32:
            case AudioStream.Streams.AACP_ADTS_64:
            case AudioStream.Streams.MP3_128:
            case AudioStream.Streams.WMA_32:
                currentSongAudioUrl = currentSong.additionalAudioUrl;
                break;
            default:
                currentSongAudioUrl = currentSong.audioUrlMap.lowQuality.audioUrl;
        }
    }

}
