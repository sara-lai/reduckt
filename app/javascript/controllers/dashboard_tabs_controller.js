import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabButton", "tabPane"]

  call(event) {
    event.preventDefault()
    const clickedTab = event.currentTarget
    const targetPanel = clickedTab.dataset.tab // eg the data-tab="expenses"

    this.tabButtonTargets.forEach(btn => btn.classList.remove("active"))
    clickedTab.classList.add("active")

    this.tabPaneTargets.forEach(pane => {
      if (pane.id === `${targetPanel}-panel`) {
        pane.classList.add("active")
      } else {
        pane.classList.remove("active")
      }
    })
  }
}
