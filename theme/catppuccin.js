// run on https://catppuccin.com/palette/ to grab all themes

document.querySelectorAll('.flavor').forEach(flavor => {
  const ignoreList = [
    'Color',
    'Rosewater',
    'Flamingo',
    'Maroon',
    'Sky',
    'Sapphire',
    'Lavender',
    'Pink',
  ];
  const colors = {};
  flavor.querySelectorAll('tr').forEach(v => {
    const color = v.cells[0].textContent.trim();
    if (ignoreList.includes(color)) return;
    colors[color] = v.cells[1].textContent.trim();
  });
  console.log(
    `-------------------- ${flavor.querySelector('h2').textContent.trim().toUpperCase()} --------------------`
  );
  console.log(
    Object.entries(colors)
      .map(
        ([color, hex]) =>
          `readonly property color ${color.toLowerCase().replace(' ', '').replace('mauve', 'purple').replace('peach', 'orange')}: "${hex}"`
      )
      .join('\n')
  );
});
