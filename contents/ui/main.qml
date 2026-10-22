import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property var tasks: []
    property real now: Date.now()

    function formatRemaining(whenDate, nowMs) {
        const total = Math.max(0, Math.floor((whenDate.getTime()) - nowMs) / 1000);
        const h = Math.floor(total / 3600);
        const m = Math.floor((total % 3600) / 60);
        const s = Math.floor(total % 60);

        const pad = n => String(n).padStart(2, "0");
        return h > 0 ? `${h}:${pad(m)}` : `${pad(m)}:${pad(s)}`;
    }

    function addTask(when_schedule, msg) {
        if (!(when_schedule instanceof Date) || isNaN(when_schedule.getTime())) {
            console.error("bad when_schedule");
            return;
        }
        if (typeof msg !== "string" || msg.trim() === "" || msg.length > 250) {
            console.error("bad msg");
            return;
        }

        tasks = [...tasks, {when_schedule: when_schedule, msg: msg}];
    }

    function removeTask(index) {
        tasks = tasks.filter((_, i) => i !== index);
    }

    function runTask(task) {
		console.log(`notify-send -t 3000 "Scheduler" "task msg: ${task.msg}"`)
        executable.exec(`notify-send -t 3000 "Scheduler" "task msg: ${task.msg}"`);
    }

    Plasmoid.icon: "ktimer"

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: source => disconnectSource(source)
        function exec(cmd) {
            connectSource(cmd);
        }
    }

    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: root.tasks.length > 0
		triggeredOnStart: true
        onTriggered: {
            root.now = Date.now();

            const due = root.tasks.filter(t => t.when_schedule.getTime() <= root.now);
            if (due.length > 0) {
                due.forEach(t => root.runTask(t));
                root.tasks = root.tasks.filter(t => t.when_schedule.getTime() > root.now);
            }
        }
    }

    fullRepresentation: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8

        ColumnLayout {
            PlasmaComponents.Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                contentItem: RowLayout {
                    Kirigami.Icon {
                        source: "gtk-add"
                    }

                    PlasmaComponents.Label {
                        text: i18n("New Task")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                onClicked: {
                    root.addTask(new Date(Date.now() + 10 * 1000), "task #" + (root.tasks.length + 1));
                }
            }

            PlasmaComponents.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: taskList
                    model: root.tasks
                    clip: true

                    delegate: PlasmaComponents.ItemDelegate {
                        id: delegate
                        required property var modelData
                        required property int index

                        width: ListView.view.width

                        contentItem: RowLayout {
                            spacing: Kirigami.Units.largeSpacing

                            HoverHandler {
                                id: rowHover
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                PlasmaComponents.Label {
                                    Layout.fillWidth: true
                                    text: delegate.modelData.msg
                                }
                                PlasmaComponents.Label {
                                    text: formatRemaining(delegate.modelData.when_schedule, root.now)
                                }
                            }

                            PlasmaComponents.ToolButton {
                                icon.name: "edit-delete"
                                opacity: rowHover.hovered ? 1 : 0
                                enabled: opacity > 0
                                PlasmaComponents.ToolTip.text: i18n("Cancel")
                                PlasmaComponents.ToolTip.visible: hovered
                                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                                onClicked: root.removeTask(delegate.index)

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: Kirigami.Units.shortDuration
                                    }
                                }
                            }
                        }
                    }
                }

                Kirigami.PlaceholderMessage {
                    anchors.centerIn: parent
                    visible: root.tasks.length === 0
                    text: i18n("No scheduled tasks")
                    width: parent.width - Kirigami.Units.gridUnit * 2
                    height: parent.height - Kirigami.Units.gridUnit * 2
                }
            }
        }

        // PlasmaComponentss.Label {
        //     Layout.alignment: Qt.AlignHCenter
        //     text: root.running
        //           ? i18n("Suspending in %1:%2",
        //                  Math.floor(root.remaining / 60),
        //                  String(root.remaining % 60).padStart(2, "0"))
        //           : i18n("Suspend after:")
        // }
        //
        // RowLayout {
        //     Layout.alignment: Qt.AlignHCenter
        //     visible: !root.running
        //     QQC2.SpinBox {
        //         id: seconds
        //         from: 1; to: 720; value: 10
        //     }
        //     PlasmaComponentss.Label { text: i18n("minutes") }
        // }
        //
        // PlasmaComponentss.Button {
        //     Layout.alignment: Qt.AlignHCenter
        //     text: root.running ? i18n("Cancel") : i18n("Start")
        //     icon.name: root.running ? "dialog-cancel" : "media-playback-start"
        //     onClicked: root.remaining = root.running ? 0 : seconds.value
        // }
    }
}
