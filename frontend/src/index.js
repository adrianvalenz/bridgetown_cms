/* Use in your app by simply adding to your app's index.js:

import BridgetownCms from "bridgetown_cms"

BridgetownCms()
*/

import React from "react";
import ReactDOM from "react-dom";
import AdminDashboard from "./components/AdminDashboard";

export { AdminDashboard };

export function mountAdminDashboard(elementId) {
  ReactDOM.render(<AdminDashboard />, document.getElementById(elementId));
}

document.addEventListener("DOMContentLoaded", () => {
  const elementId = "admin-dashboard";
  if (document.getElementById(elementId)) {
    mountAdminDashboard(elementId);
  }
})

export default function() {
  console.log("Success! BridgetownCMS has been loaded.")
}
