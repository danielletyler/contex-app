// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import * as echarts from 'echarts';
import Chart from "chart.js/auto"

let Hooks = {}
Hooks.EChart = {
  mounted() {
    selector = "#" + this.el.id
    this.chart = echarts.init(this.el.querySelector(selector + "-chart"))
    option = JSON.parse(this.el.querySelector(selector + "-data").textContent)
    this.chart.setOption(option)
  },
  updated() {
     selector = "#" + this.el.id
     option = JSON.parse(this.el.querySelector(selector + "-data").textContent)
     this.chart.setOption(option)
   }
}

Hooks.BarChartJS =  {
  mounted() {
    const ctx = this.el;
    const chart = new Chart(ctx, {});
    this.handleEvent("new-chart", function(payload){
      chart.config._config = payload.config
      chart.update();
    })
    this.handleEvent("update-points", function(payload){
      console.log(chart)
      chart.data.datasets[0].data = payload.points;
      chart.data.labels = ['1', '2', '3', '4', '5'];
      chart.update();
    })
  }
}

Hooks.PieChartJS =  {
  config() {return JSON.parse(this.el.dataset.config);},
  mounted() {
    const ctx = this.el;
    const chart = new Chart(ctx, this.config());
    this.handleEvent("update-data", function(payload){
      chart.data.datasets[0].data = payload.data;
      chart.update();
    })
  },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

