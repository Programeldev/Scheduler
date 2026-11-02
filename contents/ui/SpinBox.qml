import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami


QQC2.SpinBox {
    id: control
    from: 0
    to: 100
    value: 50
    editable: true

    implicitWidth: Kirigami.Units.gridUnit * 6
    implicitHeight: Kirigami.Units.gridUnit * 1.8

    contentItem: QQC2.TextField {
		id: content
        text: control.textFromValue(control.value, control.locale)
        font: control.font
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        verticalAlignment: Text.AlignVCenter
		topPadding: 0
		bottomPadding: 0
        leftPadding: Kirigami.Units.smallSpacing
        background: null
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        y: 0
        width: Kirigami.Units.gridUnit * 1.2
        height: parent.height / 2
        color: control.up.pressed ? Kirigami.Theme.highlightColor
             : control.up.hovered ? Kirigami.Theme.alternateBackgroundColor
             : "transparent"
        border.color: Kirigami.Theme.disabledTextColor

        Kirigami.Icon {
            anchors.centerIn: parent
            source: "arrow-up"
            implicitWidth: Kirigami.Units.iconSizes.small / 1.5
            implicitHeight: implicitWidth
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        y: parent.height / 2
        width: Kirigami.Units.gridUnit * 1.2
        height: parent.height / 2
        color: control.down.pressed ? Kirigami.Theme.highlightColor
             : control.down.hovered ? Kirigami.Theme.alternateBackgroundColor
             : "transparent"
        border.color: Kirigami.Theme.disabledTextColor

        Kirigami.Icon {
            anchors.centerIn: parent
            source: "arrow-down"
            implicitWidth: Kirigami.Units.iconSizes.small / 1.5
            implicitHeight: implicitWidth
        }
    }

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
        border.color: control.activeFocus ? Kirigami.Theme.highlightColor
                                          : Kirigami.Theme.disabledTextColor
        radius: 2
    }
}
