var flags = {
  "centre_set": false,
  "nw_set": false
};

var limits = {};

const CALIBRATION_NUM_ROWS = 5
const CALIBRATION_NUM_COLS = 5

var calibrating = false;
var calibration = {
  "pan_left": 180,
  "pan_right": 0,
  "tilt_up": 0,
  "tilt_down": 180,
  "grid": {
    "x": [
      [ -1, -1, -1, -1, -1 ],
      [ -1, -1, -1, -1, -1 ],
      [ -1, -1, -1, -1, -1 ],
      [ -1, -1, -1, -1, -1 ],
      [ -1, -1, -1, -1, -1 ]
    ],
    "y": [
      [ -1, -1, -1, -1, -1 ],
      [ -1, -1, -1, -1, -1 ],
      [ -1, -1, -1, -1, -1 ],
      [ -1, -1, -1, -1, -1 ],
      [ -1, -1, -1, -1, -1 ]
    ],
    "pan": [ -1, -1, -1, -1, -1 ],
    "tilt": [ -1, -1, -1, -1, -1 ]
  }
}

var calibrating_row = null;
var calibrating_col = null;

var current_pan = 90;
var current_tilt = 90;

var event_source;

function configure_coord_buttons(loc) {
  document.getElementById("psg-"+loc+"-set").onclick = function(e) {
    flags[loc+"_set"] = true;
  }

  document.getElementById("psg-"+loc+"-clear").onclick = function(e) {
    document.getElementById("psg-"+loc+"-x").value = "";
    document.getElementById("psg-"+loc+"-y").value = "";
    flags[loc+"_set"] = false;
  }
}

function load_orientation(axis, dir, value) {
  const tag = "psg-"+axis+"-"+dir;
  const index = axis+"_"+dir;

  document.getElementById(tag+"-value").value = value;
  calibration[index] = value;
}

function configure_orientation_buttons(axis, dir) {
  const tag = "psg-"+axis+"-"+dir;
  const index = axis+"_"+dir;

  document.getElementById(tag+"-copy").onclick = function(e) {
    const value = document.getElementById("psg-"+axis).value;

    document.getElementById(tag+"-value").value = value;
    calibration[index] = parseInt(value);
  }

  document.getElementById(tag+"-value").onchange = function(e) {
    calibration[index] = parseInt(document.getElementById(tag+"-value").value);
  }

  document.getElementById(tag+"-clear").onclick = function(e) {
    document.getElementById(tag+"-value").value = "";
    calibration[index] = -1;
  }
}

function have_move_values_changed() {
  var changed = false;

  const pan_input = document.getElementById("psg-pan");
  const tilt_input = document.getElementById("psg-tilt");

  if (pan_input.value != current_pan) {
    changed = true;

    if (!pan_input.classList.contains("psg-orientation-changed")) {
      pan_input.classList.add("psg-orientation-changed");
    }
  } else {
    pan_input.classList.remove("psg-orientation-changed");
  }

  if (tilt_input.value != current_tilt) {
    changed = true;

    if (!tilt_input.classList.contains("psg-orientation-changed")) {
      tilt_input.classList.add("psg-orientation-changed");
    }
  } else {
    tilt_input.classList.remove("psg-orientation-changed");
  }

  const move_button = document.getElementById("psg-move");

  if (changed) {
    if (!move_button.classList.contains("psg-move-ready")) {
      move_button.classList.add("psg-move-ready");
    }
  } else {
    move_button.classList.remove("psg-move-ready");
  }
}

function addOption(select, option_name) {
  var option = document.createElement("option");

  option.value = option_name;
  option.innerHTML = option_name;

  select.appendChild(option);
}

function updateConfiguration() {
  var configuration = {
    "tracking": document.getElementById("psg-tracking-enabled").checked,
    "autofire": document.getElementById("psg-autofire-enabled").checked,
    "alwaysfire": document.getElementById("psg-alwaysfire-enabled").checked,
    "scanwhenidle": document.getElementById("psg-scanwhenidle-enabled").checked,
    "shoot_colours": [],
    "safe_colours": []
  }

  var shootable = document.getElementById("psg-shoot-colour");
  var safe = document.getElementById("psg-safe-colour");

  if (shootable.value != "all") {
    configuration["shoot_colours"].push(shootable.value);
  }

  if (safe.value != "none") {
    configuration["safe_colours"].push(safe.value);
  }

  fetch(
    window.location.href + "/controls", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(configuration)
  })
  .catch(error => {
    console.log(error);
  });
}

function aimTurret(x, y, fire) {
  if (fire) {
    document.getElementById("psg-fire").classList.add("psg-fire-firing");
  }

  fetch(
    window.location.href + "/aim", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        "x": parseInt(x),
        "y": parseInt(y),
        "move_and_fire": fire
      })
  })
  .then(response => response.json())
  .then(data => {
    document.getElementById("psg-pan").value = data["pan"],
    document.getElementById("psg-tilt").value = data["tilt"]
  })
  .catch(error => {
    console.log(error);
  });
}

function moveTurret(pan, tilt) {
    fetch(
      window.location.href + "/move", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          "pan": pan,
          "tilt": tilt
        })
    })
    .catch(error => {
      console.log(error);
    });

    current_pan = pan;
    current_tilt = tilt;

    let pan_element = document.getElementById("psg-pan");
    let tilt_element = document.getElementById("psg-tilt");

    pan_element.value = pan;
    tilt_element.value = tilt;

    document.getElementById("psg-move").classList.remove("psg-move-ready");
    pan_element.classList.remove("psg-orientation-changed");
    tilt_element.classList.remove("psg-orientation-changed");
}

function startFiring() {
  document.getElementById("psg-fire").classList.add("psg-fire-firing");

  fetch(
    window.location.href + "/fire", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        "firing": true
      })
    }
  )
  .catch(error => {
    console.log(error);
  });
}

function stopFiring() {
  var fire_button = document.getElementById("psg-fire");

  if (!fire_button.classList.contains("psg-fire-firing")) {
    return;
  }

  if (!isAlwaysFiring()) {
    fire_button.classList.remove("psg-fire-firing");

    fetch(
      window.location.href + "/fire", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          "firing": false
        })
      }
    )
    .catch(error => {
      console.log(error);
    });
  }
}

function videoPortClickStart(x, y) {
  if (!calibrating && document.getElementById("psg-click-to-fire").checked) {
    aimTurret(x, y, true);
  }
}

function isAlwaysFiring() {
  return document.getElementById("psg-alwaysfire-enabled").checked;
}

function videoPortClickEnd(x, y) {
  if (!calibrating && !isAlwaysFiring()) {
    stopFiring();
    document.getElementById("psg-fire").classList.remove("psg-fire-firing");
  }
}

function setCalibrationVisibility(visibility) {
  //document.getElementById("psg-calibration").style.visibility = visibility;

  //document.getElementById("psg-calibration").hidden = (visibility == "hidden");
  document.getElementById("psg-calibration").style.display = (visibility == "hidden" ? "none" : "grid");
  document.getElementById("psg-calibration-pan-left").style.visibility = visibility;
  document.getElementById("psg-calibration-pan-right").style.visibility = visibility;
  document.getElementById("psg-calibration-tilt-up").style.visibility = visibility;
  document.getElementById("psg-calibration-tilt-down").style.visibility = visibility;
}

function configureGridPoint(row, col) {
  let grid_id = "psg-calibration-grid-" + row + "-" + col;
  let x_element = document.getElementById(grid_id + "-x");
  let y_element = document.getElementById(grid_id + "-y");

  x_element.onchange = function(e) {
    calibration["grid"]["x"][row][col] = parseInt(x_element.value);
  }

  y_element.onchange = function(e) {
    calibration["grid"]["y"][row][col] = parseInt(y_element.value);
  }
}

function loadGridPoint(row, col, x, y) {
  let grid_id = "psg-calibration-grid-" + row + "-" + col;

  document.getElementById(grid_id + "-x").value = x;
  document.getElementById(grid_id + "-y").value = y;
}

function loadCalibration() {
  fetch(
    new Request("calibration")
  )
  .then(response => response.json())
  .then(data => {
    if (data != "") {
      calibration = data;
    }

    grid_x = calibration["grid"]["x"];
    grid_y = calibration["grid"]["y"];

    for (let row = 0; row < CALIBRATION_NUM_ROWS; row++) {
      for (let col = 0; col < CALIBRATION_NUM_COLS; col++) {
        loadGridPoint(row, col, grid_x[row][col], grid_y[row][col]);
      }
    }

    load_orientation("pan", "left", calibration["pan_left"]);
    load_orientation("pan", "right", calibration["pan_right"]);
    load_orientation("tilt", "up", calibration["tilt_up"]);
    load_orientation("tilt", "down", calibration["tilt_down"]);
  })
  .catch(error => {
    console.log(error);
  });
}

function moveTurretToGridPoint() {
  let pan = calibration["grid"]["pan"][calibrating_col];
  let tilt = calibration["grid"]["tilt"][calibrating_row];

  moveTurret(pan, tilt);
}

function calibrateGridPoint(x, y) {
  let grid_id = "psg-calibration-grid-" + calibrating_row + "-" + calibrating_col;

  document.getElementById(grid_id + "-x").value = x;
  document.getElementById(grid_id + "-y").value = y;

  calibration["grid"]["x"][calibrating_row][calibrating_col] = x;
  calibration["grid"]["y"][calibrating_row][calibrating_col] = y;
}

function nextGridPoint() {
  if (calibrating_col == CALIBRATION_NUM_COLS - 1) {
    if (calibrating_row == CALIBRATION_NUM_ROWS - 1) {
      // We're done!
      calibrating_row = null;
      calibrating_col = null;

      return false;
    } else {
      calibrating_row++;
      calibrating_col = 0;
    }
  } else {
    calibrating_col++;
  }

  moveTurretToGridPoint();
  return true;
}

function initiateCalibration() {
  let pan_left = calibration["pan_left"];
  let pan_right = calibration["pan_right"];
  let tilt_up = calibration["tilt_up"];
  let tilt_down = calibration["tilt_down"];

  let pan_range = pan_left - pan_right;
  let tilt_range = tilt_down - tilt_up;

  let pan_step = Math.round(pan_range/4);
  let tilt_step = Math.round(tilt_range/4);

  calibration["grid"]["pan"][4] = pan_right;
  calibration["grid"]["pan"][3] = pan_right + pan_step;
  calibration["grid"]["pan"][2] = pan_right + pan_step * 2;
  calibration["grid"]["pan"][1] = pan_right + pan_step * 3;
  calibration["grid"]["pan"][0] = pan_left;

  calibration["grid"]["tilt"][0] = tilt_up;
  calibration["grid"]["tilt"][1] = tilt_up + tilt_step;
  calibration["grid"]["tilt"][2] = tilt_up + tilt_step * 2;
  calibration["grid"]["tilt"][3] = tilt_up + tilt_step * 3;
  calibration["grid"]["tilt"][4] = tilt_down;

  calibrating_row = 0;
  calibrating_col = 0;

  alwaysFire(true);
  moveTurretToGridPoint(0, 0);
}

function finaliseCalibration() {
  calibrating_row = null;
  calibrating_col = null;
  document.getElementById("psg-calibration-start").disabled = false;
  document.getElementById("psg-calibration-stop").disabled = true;
  alwaysFire(false);
}

function alwaysFire(enabled) {
    let element = document.getElementById("psg-alwaysfire-enabled");

    let currently_enabled = enabled.checked;

    if (currently_enabled == enabled) {
      return;
    }

    element.checked = enabled;

    updateConfiguration();

    if (enabled) {
      document.getElementById("psg-fire").classList.add("psg-fire-firing");
    } else {
      document.getElementById("psg-fire").classList.remove("psg-fire-firing");
    }
}

function showCameraConfiguration(show) {
  document.getElementById("psg-picam-configuration").style.display = (show ? "grid" : "none");
}

function loadCameraConfiguration() {
  fetch(
    window.location.href + "/camera_configuration", {
      method: "GET",
      headers: {
        "Content-Type": "application/json"
      }
  })
  .then(response => response.json())
  .then(data => {
    if (data["type"] != "picam") {
      // If it's not a PiCam, we hide the switch, as no camera configuration available
      document.getElementById("psg-camera-switch").style.visibility = "hidden";
    } else {
      document.getElementById("psg-picam-brightness-value").value = data["brightness"];
      document.getElementById("psg-picam-brightness-slider").value = data["brightness"];
      document.getElementById("psg-picam-contrast-value").value = data["contrast"];
      document.getElementById("psg-picam-contrast-slider").value = data["contrast"];
      document.getElementById("psg-picam-saturation-value").value = data["saturation"];
      document.getElementById("psg-picam-saturation-slider").value = data["saturation"];
      document.getElementById("psg-picam-exposure-value").value = data["exposure_mode"];
      document.getElementById("psg-picam-iso-value").value = data["ISO"];
      document.getElementById("psg-picam-awb-value").value = data["awb_mode"];
    }
  })
  .catch(error => {
    console.log(error);
  });
}

function saveCameraConfiguration() {
  let data = {
    "brightness": parseInt(document.getElementById("psg-picam-brightness-value").value),
    "contrast": parseInt(document.getElementById("psg-picam-contrast-value").value),
    "saturation": parseInt(document.getElementById("psg-picam-saturation-value").value),
    "exposure_mode": document.getElementById("psg-picam-exposure-value").value,
    "ISO": document.getElementById("psg-picam-iso-value").value,
    "awb_mode": document.getElementById("psg-picam-awb-value").value
  };

  if (data["ISO"] != "auto") {
    data["ISO"] = parseInt(data["ISO"])
  }

  fetch(
    window.location.href + "/camera_configuration", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(data)
  })
  .catch(error => {
    console.log(error);
  });
}

window.onload = function() {
  setCalibrationVisibility("hidden");
  document.getElementById("psg-calibration-start").disabled = false;
  document.getElementById("psg-calibration-stop").disabled = true;
  showCameraConfiguration(false);

  var shootable = document.getElementById("psg-shoot-colour");
  var safe = document.getElementById("psg-safe-colour");

  fetch(
    window.location.href + "/trackablecolours", {
      method: "GET",
      headers: {
        "Content-Type": "application/json"
      }
  })
  .then(response => response.json())
  .then(data => {
    data.forEach(function(colour) {
      addOption(shootable, colour);
      addOption(safe, colour);
    });
  })
  .catch(error => {
    console.log(error);
  });

  fetch(
    window.location.href + "/controls", {
      method: "GET",
      headers: {
        "Content-Type": "application/json"
      }
  })
  .then(response => response.json())
  .then(data => {
    document.getElementById("psg-autofire-enabled").checked = data["autofire"];
    document.getElementById("psg-tracking-enabled").checked = data["tracking"];
    document.getElementById("psg-alwaysfire-enabled").checked = data["alwaysfire"];
    document.getElementById("psg-scanwhenidle-enabled").checked = data["scanwhenidle"];

    if (data["shoot_colours"].length > 0) {
      shootable.value = data["shoot_colours"].shift();
    }

    if (data["safe_colours"].length > 0) {
      safe.value = data["safe_colours"].shift();
    }
  })
  .catch(error => {
    console.log(error);
  });

  shootable.onchange = function(e) {
    updateConfiguration();
  }

  safe.onchange = function(e) {
    updateConfiguration();
  }

  document.getElementById("psg-autofire-enabled").onchange = function(e) {
    updateConfiguration();
  }

  document.getElementById("psg-alwaysfire-enabled").onchange = function(e) {
    updateConfiguration();

    if (e.target.checked) {
      document.getElementById("psg-fire").classList.add("psg-fire-firing");
    } else {
      document.getElementById("psg-fire").classList.remove("psg-fire-firing");
    }
  }

  document.getElementById("psg-tracking-enabled").onchange = function(e) {
    updateConfiguration();
  }

  document.getElementById("psg-scanwhenidle-enabled").onchange = function(e) {
    updateConfiguration();
  }

  document.getElementById("psg-configure-camera").onchange = function(e) {
    showCameraConfiguration(document.getElementById("psg-configure-camera").checked);
  }

  document.getElementById("psg-picam-brightness-value").onchange = function(e) {
    document.getElementById("psg-picam-brightness-slider").value = e.target.value;

    saveCameraConfiguration();
  }

  document.getElementById("psg-picam-brightness-slider").onchange = function(e) {
    document.getElementById("psg-picam-brightness-value").value = e.target.value;

    saveCameraConfiguration();
  }

  document.getElementById("psg-picam-contrast-value").onchange = function(e) {
    document.getElementById("psg-picam-contrast-slider").value = e.target.value;

    saveCameraConfiguration();
  }

  document.getElementById("psg-picam-contrast-slider").onchange = function(e) {
    document.getElementById("psg-picam-contrast-value").value = e.target.value;

    saveCameraConfiguration();
  }

  document.getElementById("psg-picam-saturation-value").onchange = function(e) {
    document.getElementById("psg-picam-saturation-slider").value = e.target.value;

    saveCameraConfiguration();
  }

  document.getElementById("psg-picam-saturation-slider").onchange = function(e) {
    document.getElementById("psg-picam-saturation-value").value = e.target.value;

    saveCameraConfiguration();
  }

  document.getElementById("psg-picam-exposure-value").onchange = function(e) {
    saveCameraConfiguration();
  }

  document.getElementById("psg-picam-iso-value").onchange = function(e) {
    saveCameraConfiguration();
  }

  document.getElementById("psg-picam-awb-value").onchange = function(e) {
    saveCameraConfiguration();
  }


  fetch(
    new Request("turret_position")
  )
  .then(response => response.json())
  .then(data => {
    current_pan = data["pan"];
    current_tilt = data["tilt"];
    document.getElementById("psg-pan").value = current_pan;
    document.getElementById("psg-tilt").value = current_tilt;
  })
  .catch(error => {
    console.log(error);
  });

  window.setInterval(have_move_values_changed, 100);

  document.getElementById("psg-mode-active").onchange = function(e) {
    finaliseCalibration();
    calibrating = false;
    setCalibrationVisibility("hidden");
  };

  document.getElementById("psg-mode-calibrating").onchange = function(e) {
    calibrating = true;
    setCalibrationVisibility("visible");
  };

  document.getElementById("psg-move").onclick = function(e) {
    const pan_element = document.getElementById("psg-pan");
    const tilt_element = document.getElementById("psg-tilt");

    pan = parseInt(pan_element.value);
    tilt = parseInt(tilt_element.value);

    moveTurret(pan, tilt);
  };

  document.getElementById("psg-fire").onmousedown = function(e) {
    startFiring();
  };

  document.getElementById("psg-fire").onmouseout = function(e) {
    stopFiring();
  }

  document.getElementById("psg-fire").onmouseup = function(e) {
    stopFiring();
  };

  document.getElementById("psg-video-port").onmousedown = function(e) {
    if (calibrating) {
      calibrateGridPoint(e.offsetX, e.offsetY);
      
      if (!nextGridPoint()) {
        finaliseCalibration();
        return;
      }

      moveTurretToGridPoint();
    } else {
      videoPortClickStart(e.offsetX, e.offsetY);
    }
  }

  document.getElementById("psg-video-port").onmousemove = function(e) {
    /* console.log("mouse move"); */
    e.stopPropagation();
    e.preventDefault();
  }

  document.getElementById("psg-video-port").onmouseout = function(e) {
    if (!calibrating) {
      videoPortClickEnd(e.offsetX, e.offsetY);
    }
  }

  document.getElementById("psg-video-port").onmouseup = function(e) {
    videoPortClickEnd(e.offsetX, e.offsetY);
  }

  for (let row = 0; row < CALIBRATION_NUM_ROWS; row++) {
    for (let col = 0; col < CALIBRATION_NUM_COLS; col++) {
      configureGridPoint(row, col);
    }
  }

  configure_orientation_buttons("pan", "left");
  configure_orientation_buttons("pan", "right");
  configure_orientation_buttons("tilt", "up");
  configure_orientation_buttons("tilt", "down");

  // Populate with whatever configuration is set
  loadCalibration();

  document.getElementById("psg-calibration-save").onclick = function(e) {
    fetch(
      window.location.href + "/calibrate", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(calibration)
      }
    )
    .catch(error => {
      console.log(error);
    });
  };

  document.getElementById("psg-calibration-reset").onclick = function(e) {
    finaliseCalibration();
    loadCalibration();
  }

  document.getElementById("psg-calibration-start").onclick = function(e) {
    document.getElementById("psg-calibration-start").disabled = true;
    document.getElementById("psg-calibration-stop").disabled = false;
    initiateCalibration();
  }

  document.getElementById("psg-calibration-stop").onclick = function(e) {
    finaliseCalibration();
  }

  event_source = new EventSource("/events");

  event_source.onmessage = function(e) {
    var data = JSON.parse(e.data);
    console.log(data.pan + ", " + data.tilt + (data.firing ? " [firing]" : ""));

    document.getElementById("psg-pan").value = data.pan;
    document.getElementById("psg-tilt").value = data.tilt;

    if (!isAlwaysFiring()) {
      if (data.firing) {
        document.getElementById("psg-fire").classList.add("psg-fire-firing");
      } else {
        document.getElementById("psg-fire").classList.remove("psg-fire-firing");
      }
    }
  }

  //event_source.onerror = function(error) {
  //  console.log(error);
  //}
}


