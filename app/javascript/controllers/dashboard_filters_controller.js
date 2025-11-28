import { Controller } from "@hotwired/stimulus"

// stimulus for filtering bit frustrating, this is easy in React

export default class extends Controller {
  static targets = ["status", "employee"];

  connect() {
    console.log('hello')
  }

  filterStatus() {
    const status = this.statusTarget.value

    let url = window.location.pathname
    if (status === "all") {
      window.location.href = url
    } else {
       window.location.href = url += `?status=${status}`
    }
  }

  filterEmployee() {
    const employee = this.employeeTarget.value

    let url = window.location.pathname
    if (employee === "all") {
      window.location.href = url
    } else {
       window.location.href = url += `?employee=${employee}`
    }
  }
}
