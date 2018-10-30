/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami 
import QtQuick.Shapes 1.11
import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate {
    id: root

    property var timers

    graceTime: timers.length > 0 ? Infinity : 2000
    backgroundDim: 1
    width: Kirigami.Units.gridUnit * 15
    height: Kirigami.Units.gridUnit * 24

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    ListView {
        //FIXME
        //height: Math.max(parent.height, timerLayout.height)
        width: parent.width

        model: root.timers.length

        //TODO: we need models api or we can't do such transitions
        add: Transition {
            NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 1000 }
        }

        delegate: MouseArea {
            id: timerRoot
            width: Math.min(parent.width * 0.8, Kirigami.Units.gridUnit * 15)
            x: parent.width/2 - width/2
            height: width

            property int duration: root.timers[modelData].duration
            property bool running: root.timers[modelData].running

            onClicked: {
                if (timerRoot.running) {
                    Mycroft.MycroftController.sendRequest("skill.mycrofttimer.pause", {"id": modelData})
                } else {
                    Mycroft.MycroftController.sendRequest("skill.mycrofttimer.resume", {"id": modelData})
                }
            }

            Rectangle {
                id: ripple1
                anchors.fill: backgroundRect
                radius: width
                color: Kirigami.Theme.highlightColor
            }
            Rectangle {
                id: ripple2
                anchors.fill: backgroundRect
                radius: width
                color: Kirigami.Theme.highlightColor
            }
            Rectangle {
                id: ripple3
                anchors.fill: backgroundRect
                radius: width
                color: Kirigami.Theme.highlightColor
            }
            ParallelAnimation {
                id: rippleAnimation
                loops: Animation.Infinite
                onRunningChanged: {
                    if (!running) {
                        complete();
                    }
                }
                ScaleAnimator {
                    target: ripple1
                    from: 1
                    to: 1.5
                    duration: 8*Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
                OpacityAnimator {
                    target: ripple1
                    from: 1
                    to: 0
                    duration: 8*Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
                SequentialAnimation {
                    PauseAnimation {
                        duration: 2*Kirigami.Units.longDuration
                    }
                    ParallelAnimation {
                        ScaleAnimator {
                            target: ripple2
                            from: 1
                            to: 1.5
                            duration: 8*Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        OpacityAnimator {
                            target: ripple2
                            from: 1
                            to: 0
                            duration: 8*Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                SequentialAnimation {
                    PauseAnimation {
                        duration: 4*Kirigami.Units.longDuration
                    }
                    ParallelAnimation {
                        ScaleAnimator {
                            target: ripple3
                            from: 1
                            to: 1.5
                            duration: 8*Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        OpacityAnimator {
                            target: ripple3
                            from: 1
                            to: 0
                            duration: 8*Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
            Rectangle {
                id: backgroundRect
                property int remaining: root.timers[modelData].remaining || 0
                anchors {
                    fill: timerRoot
                    margins: path.strokeWidth
                }
                radius: width

                color: Kirigami.Theme.highlightColor
                Kirigami.Heading {
                    id: timeHeading
                    anchors.centerIn: parent
                    y: parent.height/4
                    text: {
                        var totalSeconds = Math.abs(backgroundRect.remaining);
                        var hours   = Math.floor(totalSeconds / 3600);
                        var minutes = Math.floor((totalSeconds - (hours * 3600)) / 60);
                        var seconds = totalSeconds - (hours * 3600) - (minutes * 60);

                        if (hours < 10) {
                            hours = "0" + hours;
                        }
                        if (minutes < 10) {
                            minutes = "0" + minutes;
                        }
                        if (seconds < 10) {
                            seconds = "0" + seconds;
                        }
                        return (backgroundRect.remaining < 0 ? "-" : "") + (hours != "00" ? hours+':' : "") + minutes + ':' + seconds;
                    }
                    verticalAlignment: Text.AlignBottom
                    font.pointSize: undefined
                    font.pixelSize: backgroundRect.remaining < 3600 ? parent.height/4 : parent.height/6
                    font.capitalization: FFont.Boldont.SmallCaps
                    font.weight: Font.Bold
                    SequentialAnimation {
                        running: !timerRoot.running
                        loops: Animation.Infinite
                        onRunningChanged: {
                            if (!running) {
                                complete();
                                timeHeading.opacity = 1;
                            }
                        }
                        OpacityAnimator {
                            target: timeHeading
                            from: 1
                            to: 0.5
                            duration: 8*Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        PauseAnimation {
                            duration: Kirigami.Units.longDuration
                        }
                        OpacityAnimator {
                            target: timeHeading
                            from: 0.4
                            to: 1
                            duration: 8*Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        PauseAnimation {
                            duration: Kirigami.Units.longDuration
                        }
                    }
                }
            }
            Item {
                anchors {
                    fill: parent
                    margins: -path.strokeWidth
                }
                layer.enabled: true
                layer.samples: 4
                Shape {
                    id: roundShape
                    anchors {
                        fill: parent
                        margins: path.strokeWidth
                    }
                    property int radius: width/2
                    property real angle: 360 - Math.max(0.0001, backgroundRect.remaining)/timerRoot.duration * 360
                    visible: angle < 360
                    antialiasing: true
                    smooth: true

                    Behavior on angle {
                        NumberAnimation {
                            duration: 2*Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    ShapePath {
                        id: path
                        strokeWidth: roundShape.width/20
                        strokeColor: Kirigami.Theme.highlightColor
                        fillColor: "transparent"
                        capStyle: ShapePath.FlatCap

                        strokeStyle: ShapePath.SolidLine
                        startX: roundShape.radius
                        startY: 0

                        PathArc {
                            x: roundShape.radius + roundShape.radius * Math.sin(roundShape.angle * 0.0174532925)
                            y: roundShape.radius -roundShape.radius * Math.cos(roundShape.angle * 0.0174532925)
                            radiusX: roundShape.radius
                            radiusY: radiusX
                            direction: PathArc.Counterclockwise
                            useLargeArc: roundShape.angle < 180
                        }
                    }
                }
            }
            state: backgroundRect.remaining > 0 ? "idle" : "ringing"
            states: [
                State {
                    name: "idle"
                    PropertyChanges {
                        target: rippleAnimation
                        running: false
                    }
                },
                State {
                    name: "ringing"
                    PropertyChanges {
                        target: rippleAnimation
                        running: timerRoot.running
                    }
                }
            ]
        }

    }

}
