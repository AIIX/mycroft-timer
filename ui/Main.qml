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

Mycroft.ScrollingDelegate {
    id: root

    property var timers

    width: Kirigami.Units.gridUnit * 15
    height: Kirigami.Units.gridUnit * 24

    color: "black"
    state: "idle"

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Column {
        id: timerLayout
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea {
            id: timerRoot
            width: parent.width
            height: width

            property int timeout: 6

            //onClicked: ringTimer.running = !ringTimer.running
            
            Rectangle {
                id: backgroundRect
                property int countdown: timerRoot.timeout
                anchors {
                    fill: timerRoot
                    margins: path.strokeWidth
                }
                radius: width
                Behavior on radius {
                    NumberAnimation {
                        duration: 2*Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: 20*Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                color: Kirigami.Theme.highlightColor
                Kirigami.Heading {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height/4
                    text: backgroundRect.countdown
                    //Layout.alignment: Qt.AlignBottom
                    verticalAlignment: Text.AlignBottom
                    font.pointSize: 40
                    font.capitalization: Font.SmallCaps
                }
            }
            Shape {
                id: roundShape
                anchors.fill: parent
                property int radius: width/2
                property real angle: 360 - Math.max(0, backgroundRect.countdown)/timerRoot.timeout * 360
                visible: angle > 0
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
            state: backgroundRect.countdown > 0 ? "idle" : "ringing"
            states: [
                State {
                    name: "idle"
                    PropertyChanges {
                        target: backgroundRect
                        radius: backgroundRect.width/2
                    }
                },
                State {
                    name: "ringing"
                    PropertyChanges {
                        target: backgroundRect
                        radius: Kirigami.Units.gridUnit
                    }
                }
            ]
        }
    }

}
