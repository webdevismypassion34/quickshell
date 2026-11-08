import ".."

// field<{ key: string, label: string, min?: number, max?: number }>

SettingsRow {
  id: root

  required property var target
  required property var field

  label: field.label

  NumberInput {
    text: root.target[root.field.key]
    min: field.min ?? -Infinity
    max: field.max ?? Infinity

    onAccepted: root.target[root.field.key] = +text
  }
}
