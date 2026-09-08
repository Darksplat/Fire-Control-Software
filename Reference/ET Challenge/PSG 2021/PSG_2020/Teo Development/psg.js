var flags = {
  "centre_set": false,
  "nw_set": false
};

var limits = {};

var calibrating = false;

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

  document.getElementById(tag+"-value").value = value;
  limits[tag] = value;
}

function configure_orientation_buttons(axis, dir) {
  const tag = "psg-"+axis+"-"+dir;

  document.getElementById(tag+"-copy").onclick = function(e) {
    const value = document.getElementById("psg-"+axis).value;

    document.getElementById(tag+"-value").value = value;
    limits[tag] = parseInt(value);
  }

  document.getElementById(tag+"-value").onchange = function(e) {
    limits[tag] = parseInt(document.getElementById(tag+"-value").value);
  }

  document.getElementById(tag+"-clear").onclick = function(e) {
    document.getElementById(tag+"-value").value = "";
    delete limits[tag];
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

function turretAim(x, y, fire) {
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
    turretAim(x, y, true);
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

window.onload = function() {
  document.getElementById("psg-calibrate").setAttribute("disabled", "");

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

  // Populate with whatever configuration is set
  fetch(
    new Request("calibration")
  )
  .then(response => response.json())
  .then(data => {
    document.getElementById("psg-nw-x").value = data["nw"]["x"];
    document.getElementById("psg-nw-y").value = data["nw"]["y"];
    document.getElementById("psg-centre-x").value = data["centre"]["x"];
    document.getElementById("psg-centre-y").value = data["centre"]["y"];
    load_orientation("pan", "left", data["pan_left"]);
    load_orientation("pan", "right", data["pan_right"]);
    load_orientation("tilt", "up", data["tilt_up"]);
    load_orientation("tilt", "down", data["tilt_down"]);
  })
  .catch(error => {
    console.log(error);
  });

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
    calibrating = false;
    document.getElementById("psg-calibrate").setAttribute("disabled", "");
//    document.getElementById("psg-move").removeAttribute("disabled");
//    document.getElementById("psg-fire").removeAttribute("disabled");
  };

  document.getElementById("psg-mode-calibrating").onchange = function(e) {
    calibrating = true;
    document.getElementById("psg-calibrate").removeAttribute("disabled");
//    document.getElementById("psg-move").setAttribute("disabled", "");
//    document.getElementById("psg-fire").setAttribute("disabled", "");
  };

  document.getElementById("psg-move").onclick = function(e) {
    const pan_element = document.getElementById("psg-pan");
    const tilt_element = document.getElementById("psg-tilt");

    fetch(
      window.location.href + "/move", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          "pan": parseInt(document.getElementById("psg-pan").value),
          "tilt": parseInt(document.getElementById("psg-tilt").value)
        })
    })
    .catch(error => {
      console.log(error);
    });

    current_pan = parseInt(pan_element.value);
    current_tilt = parseInt(tilt_element.value);

    document.getElementById("psg-move").classList.remove("psg-move-ready");
    pan_element.classList.remove("psg-orientation-changed");
    tilt_element.classList.remove("psg-orientation-changed");
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
    videoPortClickStart(e.offsetX, e.offsetY);
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
    if (calibrating) {
      if (!flags["centre_set"]) {
        document.getElementById("psg-centre-x").value = e.offsetX;
        document.getElementById("psg-centre-y").value = e.offsetY;
      }

      if (!flags["nw_set"]) {
        document.getElementById("psg-nw-x").value = e.offsetX;
        document.getElementById("psg-nw-y").value = e.offsetY;
      }
    }

    videoPortClickEnd(e.offsetX, e.offsetY);
  }

  configure_coord_buttons("centre");
  configure_coord_buttons("nw");

  configure_orientation_buttons("pan", "left");
  configure_orientation_buttons("pan", "right");
  configure_orientation_buttons("tilt", "up");
  configure_orientation_buttons("tilt", "down");

  document.getElementById("psg-calibrate").onclick = function(e) {
    fetch(
      window.location.href + "/calibrate", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          "nw": {
            "x": parseInt(document.getElementById("psg-nw-x").value),
            "y": parseInt(document.getElementById("psg-nw-y").value)
          },
          "centre": {
          "x": parseInt(document.getElementById("psg-centre-x").value),
          "y": parseInt(document.getElementById("psg-centre-y").value)
          },
          "pan_left": limits["psg-pan-left"],
          "pan_right": limits["psg-pan-right"],
          "tilt_up": limits["psg-tilt-up"],
          "tilt_down": limits["psg-tilt-down"]
        }
      )
    })
    .catch(error => {
      console.log(error);
    });
  };

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


