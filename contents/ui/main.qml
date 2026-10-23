import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import "DateTimePicker"


PlasmoidItem {
    id: root

    property var task: null // {when_schedule: Date, command: string}
	property bool task_running: task !== null ? true : false
    property real now: Date.now()

    Plasmoid.icon: "ktimer"

    function formatRemaining(whenDate, nowMs) {
        const total = Math.max(0, Math.floor((whenDate.getTime()) - nowMs) / 1000);
        const h = Math.floor(total / 3600);
        const m = Math.floor((total % 3600) / 60);
        const s = Math.floor(total % 60);

        const pad = n => String(n).padStart(2, "0");
        return h > 0 ? `${h}:${pad(m)}` : `${pad(m)}:${pad(s)}`;
    }

    P5Support.DataSource {
        id: execute
        engine: "executable"
        connectedSources: []
        onNewData: source => disconnectSource(source)
        function cmd(command) {
            connectSource(command);
        }
    }

    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: root.task_running
		triggeredOnStart: true
        onTriggered: {
            root.now = Date.now();

			if(root.task !== null || root.task.when_schedule < root.now)
			{
				console.log("task completed")
				const command = root.task.command
				root.task = null
				execute.cmd(command)
			}
        }
    }

    TimePicker {
        id: timePicker
        hour: root.now.getHours()
        minute: root.now.getMinutes()
        onAccepted: {
            // root.now.setHours(hour);
            // root.now.setMinutes(minute);
        }
    }

    DatePicker {
        id: datePicker
        year: root.now.getFullYear()
        month: root.now.getMonth()
        day: root.now.getDate()
        onAccepted: {
            // app.date.setFullYear(year, month, day);
        }
    }

    fullRepresentation: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        Layout.minimumWidth: Kirigami.Units.gridUnit * 15
        Layout.minimumHeight: Kirigami.Units.gridUnit * 10

		StackLayout {
		    id: stackLayout
			anchors.fill: parent
			currentIndex: 0

			ColumnLayout {
				anchors.centerIn: parent

				PlasmaComponents.Button {
					id: button
					anchors.centerIn: parent
					Layout.fillWidth: true
					Layout.fillHeight: true
					Kirigami.Theme.colorSet: Kirigami.Theme.Button
					Layout.margins: Kirigami.Units.gridUnit * 1.6

					onPressed: stackLayout.currentIndex = 1

					background: Rectangle {
						radius: Kirigami.Units.cornerRadius
						color: button.hovered ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
							 : Kirigami.Theme.backgroundColor
						scale: button.pressed ? 1.1
							 : 1.0

						Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }
						Behavior on scale { NumberAnimation { duration: Kirigami.Units.shortDuration } }
					}

					contentItem: Item {
        				implicitWidth: row.implicitWidth
        				implicitHeight: row.implicitHeight

						RowLayout {
							id: row
							anchors.centerIn: parent

							Kirigami.Icon {
								source: "gtk-add"
        						implicitWidth: Kirigami.Units.iconSizes.medium
        						implicitHeight: Kirigami.Units.iconSizes.medium
							}

							PlasmaComponents.Label {
								text: i18n("Schedule Task")
								font.pointSize: 12
							}
						}
					}
				}
			}

			Kirigami.FormLayout {
				anchors.fill: parent

				PlasmaComponents.ComboBox {
					Kirigami.FormData.label: "Task"

					model: [
						{ value: "poweroff", text: i18n("Shutdown") },
						{ value: "reboot", text: i18n("Reboot") },
						{ value: "suspend", text: i18n("Suspend") },
						{ value: "hibernate", text: i18n("Hibernate") },
						{ value: "command", text: i18n("Custom command") },
					]

					textRole: "text"
					valueRole: "value"
				}

				PlasmaComponents.Button {
					onClicked: {
						let date = new Date()
						datePicker.minSelectableYear = date.getFullYear() - 5;
                    	datePicker.minSelectableMonth = 5;
                    	datePicker.maxSelectableYear = date.getFullYear() + 5;
                    	datePicker.maxSelectableMonth = 5;
						datePicker.pickMode = datePicker.pickMonthYear;
						datePicker.open();
					}
				}
			}

			// ColumnLayout {
			// 	RowLayout {
			// 		Layout.margins: Kirigami.Units.gridUnit * 0.8
			// 		Layout.leftMargin: Kirigami.Units.gridUnit * 1.2
			//
			// 		PlasmaComponents.Label {
			// 			Layout.fillWidth: true
			//
			// 			text: "Task"
			// 		}
			//
			// 		PlasmaComponents.ComboBox {
			//
			// 			model: [
			// 				{ value: "poweroff", text: i18n("Shutdown") },
			// 				{ value: "reboot", text: i18n("Reboot") },
			// 				{ value: "suspend", text: i18n("Suspend") },
			// 				{ value: "hibernate", text: i18n("Hibernate") },
			// 				{ value: "command", text: i18n("Custom command") },
			// 			]
			//
			// 			textRole: "text"
			// 			valueRole: "value"
			// 		}
			// 	}
			//
			// 	RowLayout {
			// 		Layout.margins: Kirigami.Units.gridUnit * 0.8
			// 		Layout.leftMargin: Kirigami.Units.gridUnit * 1.2
			//
			// 		PlasmaComponents.Label {
			// 			Layout.fillWidth: true
			// 			text: i18n("When schedule")
			// 		}
			//
			// 		PlasmaComponents.Button {
			// 			text: i18n("Select date")
			// 		}
			// 	}
			//
			// 	PlasmaComponents.Button {
			// 		Layout.alignment: Qt.AlignHCenter
			// 		// anchors.bottom: parent.bottom
			// 		text: i18n("Save")
			// 	}	
			// }
		}
	}
}

        // ColumnLayout {
        //     PlasmaComponents.Button {
        //         Layout.alignment: Qt.AlignHCenter
        //         Layout.fillWidth: true
        //         contentItem: RowLayout {
        //             Kirigami.Icon {
        //                 source: "gtk-add"
        //             }
        //
        //             PlasmaComponents.Label {
        //                 text: i18n("New Task")
        //                 horizontalAlignment: Text.AlignHCenter
        //                 verticalAlignment: Text.AlignVCenter
        //             }
        //         }
        //         onClicked: {
        //             root.addTask(new Date(Date.now() + 10 * 1000), "task #" + (root.tasks.length + 1));
        //         }
        //     }
        //
        //     PlasmaComponents.ScrollView {
        //         Layout.fillWidth: true
        //         Layout.fillHeight: true
        //
        //         ListView {
        //             id: taskList
        //             model: root.tasks
        //             clip: true
        //
        //             delegate: PlasmaComponents.ItemDelegate {
        //                 id: delegate
        //                 required property var modelData
        //                 required property int index
        //
        //                 width: ListView.view.width
        //
        //                 contentItem: RowLayout {
        //                     spacing: Kirigami.Units.largeSpacing
        //
        //                     HoverHandler {
        //                         id: rowHover
        //                     }
        //
        //                     RowLayout {
        //                         Layout.fillWidth: true
        //
        //                         PlasmaComponents.Label {
        //                             Layout.fillWidth: true
        //                             text: delegate.modelData.msg
        //                         }
        //                         PlasmaComponents.Label {
        //                             text: formatRemaining(delegate.modelData.when_schedule, root.now)
        //                         }
        //                     }
        //
        //                     PlasmaComponents.ToolButton {
        //                         icon.name: "edit-delete"
        //                         opacity: rowHover.hovered ? 1 : 0
        //                         enabled: opacity > 0
        //                         PlasmaComponents.ToolTip.text: i18n("Cancel")
        //                         PlasmaComponents.ToolTip.visible: hovered
        //                         PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
        //                         onClicked: root.removeTask(delegate.index)
        //
        //                         Behavior on opacity {
        //                             NumberAnimation {
        //                                 duration: Kirigami.Units.shortDuration
        //                             }
        //                         }
        //                     }
        //                 }
        //             }
        //         }
        //
        //         Kirigami.PlaceholderMessage {
        //             anchors.centerIn: parent
        //             visible: root.tasks.length === 0
        //             text: i18n("No scheduled tasks")
        //             width: parent.width - Kirigami.Units.gridUnit * 2
        //             height: parent.height - Kirigami.Units.gridUnit * 2
        //         }
        //     }
        // }
        //
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
//     }
