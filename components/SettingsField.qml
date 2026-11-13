import ".."

// field<{ key: string, label: string, min?: number, max?: number }>

SettingsRow {
  id: root

  required property var target
  required property var field

  label: field.label

  function commit() {
    root.target[root.field.key] = +numberInput.text
  }

  NumberInput {
    id: numberInput

    text: root.target[root.field.key]
    min: root.field.min ?? -Infinity
    max: root.field.max ?? Infinity
  }
}
