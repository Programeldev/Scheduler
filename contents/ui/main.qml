import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
	id: root

	property int remaining: 0          // seconds left
	property bool running: remaining > 0
	property var tasks: []

	function addTask(when_schedule, msg) {
		if(!(when_schedule instanceof Date) || isNaN(when_schedule.getTime()))
		{
			console.error("bad when_schedule")
			return
		}
		if(typeof msg !== "string" || msg.trim() === "" || msg.length > 250)
		{
			console.error("bad msg")
			return
		}

		tasks = [...tasks, { when_schedule: when_schedule, msg: msg }]
	}

	function removeTask(index) {
    	tasks = tasks.filter((_, i) => i !== index)
    }

    Plasmoid.icon: "ktimer"
    toolTipMainText: running ? i18n("Suspending in %1 s", remaining) : i18n("Scheduler")

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (source) => disconnectSource(source)
        function exec(cmd) { connectSource(cmd) }
    }

    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            root.remaining--
            if (root.remaining <= 0) {
        	    executable.exec("notify-send -i task-complete 'Scheduler' 'Task Completed!'")
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
				root.addTask(new Date(), "task #" + (root.tasks.length + 1));
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

					contentItem: RowLayout {
						spacing: Kirigami.Units.largeSpacing

						ColumnLayout {
							Layout.fillWidth: true

							PlasmaComponents.Label {
								Layout.fillWidth: true
								text: delegate.modelData.msg
								elide: Text.elideRight
							}
							PlasmaComponents.Label {
								text: Qt.formatDateTime(delegate.modelData.when_schedule,
													Qt.locale().dateTimeFormat(Locale.ShortFormat))

							}
						}

						PlasmaComponents.ToolButton {
							icon.name: "edit-delete"
							onClicked: root.removeTask(delegate.index)
							PlasmaComponents.ToolTip.text: i18n("Cancel")
							PlasmaComponents.ToolTip.visible: hovered
						}
					}
				}
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
