// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin');
const colors = require("tailwindcss/colors");

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
    '../deps/petal_components/**/*.*ex'],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        primary: colors.purple,
        secondary: colors.yellow
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ]
}
