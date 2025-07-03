// deno-fmt-ignore-file
// deno-lint-ignore-file
// This code was bundled using `deno bundle` and it's not recommended to edit it manually

function createFlexContainer(id, options = {}) {
    const { flexDirection ="row" , justify ="flex-start" , alignContent ="center" , align ="stretch" , gap ="8px" , padding ="0" , margin ="0" , width ="100%" , height ="auto" , background ="transparent" , border ="none" , borderRadius ="0" , overflow ="visible"  } = options;
    const container = document.createElement("div");
    container.setAttribute("id", id);
    container.setAttribute("style", `display: flex; ` + `flex-direction: ${flexDirection}; ` + `justify-content: ${justify}; ` + `align-content: ${alignContent}; ` + `align-items: ${align}; ` + `gap: ${gap}; ` + `padding: ${padding}; ` + `margin: ${margin}; ` + `width: ${width}; ` + `height: ${height}; ` + `background: ${background}; ` + `border: ${border}; ` + `border-radius: ${borderRadius}; ` + `overflow: ${overflow}; ` + `box-sizing: border-box;`);
    return container;
}
function createDropdown(id, labelText, options, config = {}) {
    const { selectedValue ="" , width ="100%" , styleOverrides =""  } = config;
    const container = document.createElement("div");
    container.setAttribute("style", `display: flex; ` + `flex-direction: column; ` + `gap: 4px; ` + `width: ${width};`);
    const label = document.createElement("label");
    label.setAttribute("for", id);
    label.textContent = labelText;
    label.setAttribute("style", `font-size: 10px; ` + `color: #374151; ` + `margin-bottom: 2px;`);
    const select = document.createElement("select");
    select.setAttribute("id", id);
    select.setAttribute("style", `width: 100%; ` + `padding: 8px 12px; ` + `border: 1px solid #d1d5db; ` + `border-radius: 6px; ` + `background: white; ` + `font-size: 12px; ` + `color: #374151; ` + `outline: none; ` + `transition: border-color 0.2s, box-shadow 0.2s; ` + styleOverrides);
    if (Array.isArray(options) && options.length > 0) {
        options.forEach(([value, text])=>{
            const option = document.createElement("option");
            option.value = value;
            option.textContent = text;
            if (value === selectedValue) {
                option.selected = true;
            }
            select.appendChild(option);
        });
    }
    container.appendChild(label);
    container.appendChild(select);
    return container;
}
function createContextMenu(id, items) {
    const menu = document.createElement("div");
    menu.setAttribute("id", id);
    menu.setAttribute("style", `position: fixed; ` + `display: none; ` + `z-index: 9999; ` + `background: white; ` + `border: 1px solid #d1d5db; ` + `border-radius: 8px; ` + `box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2); ` + `overflow: hidden;`);
    items.forEach((item)=>{
        const menuItem = document.createElement("div");
        menuItem.className = "context-menu-item";
        menuItem.setAttribute("data-value", item.value);
        menuItem.textContent = item.label;
        menuItem.setAttribute("style", `padding: 4px 6px; ` + `cursor: pointer; ` + `color: #000000; ` + `font-size: 12px; ` + `border-bottom: 1px solid #f3f4f6; ` + `user-select: none;`);
        menuItem.addEventListener('mouseenter', ()=>{
            menuItem.style.backgroundColor = '#f3f4f6';
        });
        menuItem.addEventListener('mouseleave', ()=>{
            menuItem.style.backgroundColor = 'transparent';
        });
        menu.appendChild(menuItem);
    });
    return menu;
}
function createButton(id, text, options = {}) {
    const { variant ="primary" , size ="medium" , width ="auto" , action =null  } = options;
    const colors = {
        primary: {
            bg: "#0f75b5",
            hover: "#128edb",
            text: "white"
        },
        secondary: {
            bg: "#ffffff",
            hover: "#128edb",
            text: "black"
        }
    };
    const sizes = {
        small: {
            padding: "4px 8px",
            font: "10px"
        },
        medium: {
            padding: "6px 12px",
            font: "12px"
        },
        large: {
            padding: "8px 16px",
            font: "14px"
        }
    };
    const colorScheme = colors[variant];
    const sizeScheme = sizes[size];
    const button = document.createElement("button");
    button.setAttribute("id", id);
    button.setAttribute("type", "button");
    button.textContent = text;
    button.setAttribute("style", `padding: ${sizeScheme.padding}; ` + `font-size: ${sizeScheme.font}; ` + `border: none; ` + `border-radius: 6px; ` + `background: ${colorScheme.bg}; ` + `color: ${colorScheme.text}; ` + `width: ${width}; ` + `outline: none; ` + `cursor: pointer; ` + `transition: background-color 0.2s;`);
    button.addEventListener('click', ()=>{
        action();
    });
    button.addEventListener('mouseenter', ()=>{
        button.style.background = colorScheme.hover;
    });
    button.addEventListener('mouseleave', ()=>{
        button.style.background = colorScheme.bg;
    });
    return button;
}
function createToggleButton(id, text, options = {}) {
    const { size ="small" , width ="auto" , initialState =false , onToggle =null  } = options;
    const sizes = {
        small: {
            padding: "4px 8px",
            font: "10px"
        },
        medium: {
            padding: "6px 12px",
            font: "12px"
        },
        large: {
            padding: "8px 16px",
            font: "14px"
        }
    };
    const colorScheme = {
        bg: "#ffffff",
        active: "#858585",
        hover: "#128edb",
        text: "black"
    };
    const sizeScheme = sizes[size];
    const button = document.createElement("button");
    button.setAttribute("id", id);
    button.setAttribute("type", "button");
    button.textContent = text;
    button.setAttribute("data-toggled", initialState.toString());
    const updateButtonStyle = (isToggled)=>{
        const bgColor = isToggled ? colorScheme.active : colorScheme.bg;
        button.setAttribute("style", `font-size: ${sizeScheme.font}; ` + `padding: ${sizeScheme.padding}; ` + `border: none; ` + `border-radius: 6px; ` + `background: ${bgColor}; ` + `color: ${colorScheme.text}; ` + `width: ${width}; ` + `outline: none; ` + `cursor: pointer; ` + `transition: background-color 0.2s; ` + `opacity: ${isToggled ? '0.8' : '1'};`);
    };
    updateButtonStyle(initialState);
    button.addEventListener('click', ()=>{
        const currentState = button.getAttribute("data-toggled") === "true";
        const newState = !currentState;
        button.setAttribute("data-toggled", newState.toString());
        updateButtonStyle(newState);
        if (onToggle) {
            onToggle(newState, button);
        }
    });
    button.addEventListener('mouseenter', ()=>{
        if (button.getAttribute("data-toggled") !== "true") {
            button.style.background = colorScheme.hover;
        }
    });
    button.addEventListener('mouseleave', ()=>{
        const isToggled = button.getAttribute("data-toggled") === "true";
        button.style.background = isToggled ? colorScheme.active : colorScheme.bg;
    });
    return button;
}
function createNavbar(id, options = {}) {
    const { height ="30px" , background ="#ffffff" , borderBottom ="1.5px solid #000000" , padding ="0 16px" , title ="Biochemical Visualization"  } = options;
    const navbar = document.createElement("nav");
    navbar.setAttribute("id", id);
    navbar.setAttribute("style", `width: 100%; ` + `height: ${height}; ` + `background: ${background}; ` + `border-bottom: ${borderBottom}; ` + `padding: ${padding}; ` + `display: flex; ` + `align-items: stretch; ` + `justify-content: space-between; ` + `box-sizing: border-box; ` + `flex-shrink: 0;`);
    const titleElement = document.createElement("h1");
    titleElement.textContent = title;
    titleElement.setAttribute("style", `margin: 0; ` + `font-size: 12px; ` + `font-weight: 600; ` + `color: #000000;`);
    const actionsContainer = document.createElement("div");
    actionsContainer.setAttribute("id", "navbar-actions");
    actionsContainer.setAttribute("style", `display: flex; ` + `gap: 12px; ` + `align-items: center;`);
    navbar.appendChild(titleElement);
    navbar.appendChild(actionsContainer);
    return navbar;
}
function createBaseLayout(id, options = {}) {
    const { navbarId ="main-navbar" , contentId ="main-content"  } = options;
    const mainLayout = document.createElement("div");
    mainLayout.setAttribute("id", id);
    mainLayout.setAttribute("style", `width: 100%; ` + `height: 100%; ` + `display: flex; ` + `flex-direction: column; ` + `overflow: hidden;`);
    const navbar = createNavbar(navbarId);
    const contentArea = document.createElement("div");
    contentArea.setAttribute("id", contentId);
    contentArea.setAttribute("style", `flex: 1; ` + `display: flex; ` + `overflow: hidden;`);
    const cameraToggleButton = createToggleButton("camera-toggle", "Camera", {
        size: "medium",
        onToggle: (isToggled, button)=>{
            const scene_div = document.getElementById("bv-scene-1-div");
            if (isToggled) {
                scene_div.dispatchEvent(new CustomEvent("freeze-camera"));
            } else {
                scene_div.dispatchEvent(new CustomEvent("unfreeze-camera"));
            }
        }
    });
    const optimizeButton = createButton("optimize-button", "Optimize", {
        colors: "secondary",
        size: "medium",
        action: ()=>{
            document.dispatchEvent(new CustomEvent("optimize-structure"));
        }
    });
    const actionsContainer = navbar.querySelector("div");
    actionsContainer.appendChild(cameraToggleButton);
    actionsContainer.appendChild(optimizeButton);
    mainLayout.appendChild(navbar);
    mainLayout.appendChild(contentArea);
    return mainLayout;
}
function createSecondaryLayout(leftId, rightId, options = {}) {
    const { leftWidth ="80%" , rightWidth ="20%" , gap ="0px"  } = options;
    const leftColumn = document.createElement("div");
    leftColumn.setAttribute("id", leftId);
    leftColumn.setAttribute("style", `width: ${leftWidth}; ` + `height: 100%; ` + `overflow: hidden; ` + `padding-right: ${gap};`);
    const rightColumn = document.createElement("div");
    rightColumn.setAttribute("id", rightId);
    rightColumn.setAttribute("style", `width: ${rightWidth}; ` + `height: 100%; ` + `overflow: auto; ` + `background: #f8f9fa; ` + `border-left: 1px solid #e5e7eb;`);
    return {
        left: leftColumn,
        right: rightColumn
    };
}
function createControlsContainer(id, options = {}) {
    const { width ="100%" , height ="auto" , padding ="16px" , background ="#ffffff" , border ="none" , borderRadius ="0px"  } = options;
    const container = createFlexContainer(id, {
        flexDirection: "column",
        width: width,
        height: height,
        padding: padding,
        background: background,
        border: border,
        borderRadius: borderRadius,
        gap: "12px"
    });
    const dropdownsSection = createFlexContainer(id + "-dropdowns", {
        flexDirection: "column",
        width: "100%",
        height: "auto",
        gap: "12px",
        overflow: "auto"
    });
    const buttonSection = createFlexContainer(id + "-buttons", {
        flexDirection: "row",
        justify: "center",
        width: "100%",
        margin: "4px",
        height: "auto",
        padding: "8px 0 0 0",
        border: "0px solid #ffffff"
    });
    container.appendChild(dropdownsSection);
    container.appendChild(buttonSection);
    return container;
}
function createSystemContainer(systems) {
    const container = createFlexContainer("system-container", {
        flexDirection: "column",
        justify: "center",
        width: "100%",
        height: "auto",
        padding: "16px",
        background: "#f3f4f6",
        border: "1px solid #000000",
        borderRadius: "0px",
        gap: "8px",
        margin: "12px 0"
    });
    const title = document.createElement("h2");
    title.textContent = "Systems";
    title.style.cssText = `
        margin: 0 0 8px 0;
        font-size: 16px;
        font-weight: 600;
        color: #000000;
    `;
    const systemsList = document.createElement("div");
    systemsList.setAttribute("id", "systems-list");
    systemsList.setAttribute("style", `width: 100%; ` + `height: auto; ` + `margin: 0;` + `overflow-y: auto; ` + `border: 1px solid #d1d5db; ` + `border-radius: 6px; ` + `background: white; ` + `padding: 8px 16px;` + `box-sizing: border-box;`);
    if (Array.isArray(systems)) {
        systems.forEach((sysId)=>{
            const systemItem = document.createElement("div");
            systemItem.setAttribute("style", `display: flex; ` + `align-items: center; ` + `gap: 8px; ` + `padding: 4px 0; ` + `margin-bottom: 4px; ` + `pointer-events: auto;`);
            const checkbox = document.createElement("input");
            checkbox.setAttribute("type", "checkbox");
            checkbox.setAttribute("id", `system-checkbox-${sysId}`);
            checkbox.setAttribute("value", sysId);
            checkbox.checked = true;
            checkbox.setAttribute("style", `margin: 0; ` + `cursor: pointer; ` + `pointer-events: auto; ` + `z-index: 1;`);
            const label = document.createElement("label");
            label.setAttribute("for", `system-checkbox-${sysId}`);
            label.textContent = `System ${sysId}`;
            label.setAttribute("style", `font-size: 12px; ` + `color: #374151; ` + `cursor: pointer; ` + `user-select: none; ` + `margin: 0;`);
            systemItem.appendChild(checkbox);
            systemItem.appendChild(label);
            systemsList.appendChild(systemItem);
        });
    }
    container.appendChild(title);
    container.appendChild(systemsList);
    return container;
}
function getBaseLayout() {
    return createBaseLayout("main-layout");
}
function getSecondaryLayout() {
    return createSecondaryLayout("secondary-left", "secondary-right");
}
function getControlsContainer() {
    return createControlsContainer("controls-container");
}
function getReprTypeContextMenu() {
    return createContextMenu("context-menu-repr-type", [
        {
            value: "BALL_AND_STICK",
            label: "Ball & Stick"
        },
        {
            value: "STICK",
            label: "Stick"
        },
        {
            value: "VAN_DER_WAALS",
            label: "Van der Waals"
        }
    ]);
}
function getReprTypeDropdown() {
    const options = [
        [
            "BALL_AND_STICK",
            "Ball and Stick"
        ],
        [
            "STICK",
            "Stick"
        ],
        [
            "VAN_DER_WAALS",
            "Van der Waals"
        ]
    ];
    return createDropdown("repr-type-select", "Representation: ", options);
}
function getBackgroundDropdown() {
    const options = [
        [
            "black",
            "Black"
        ],
        [
            "white",
            "White"
        ],
        [
            "gray",
            "Gray"
        ],
        [
            "lightgray",
            "Light Gray"
        ]
    ];
    return createDropdown("background-color-select", "Background Color: ", options);
}
function getReflectionDropdown() {
    const options = [
        [
            "0.0",
            "None"
        ],
        [
            "0.5",
            "Medium"
        ],
        [
            "1.0",
            "High"
        ]
    ];
    return createDropdown("reflection-select", "Reflection: ", options);
}
function getChangeButton() {
    return createButton("change-button", "Change", {
        width: "80%",
        action: ()=>{
            document.dispatchEvent(new Event("change-event"));
        }
    });
}
function getAdditionalContainer1() {
    return createFlexContainer("additional-container-1", {
        flexDirection: "column",
        width: "100%",
        height: "auto",
        padding: "16px",
        background: "#f3f4f6",
        border: "1px solid #000000",
        borderRadius: "0px",
        gap: "8px",
        margin: "12px 0"
    });
}
function getSystemContainer(systems) {
    return createSystemContainer(systems);
}
export { createButton as createButton };
export { getBaseLayout as getBaseLayout };
export { getSecondaryLayout as getSecondaryLayout };
export { getControlsContainer as getControlsContainer };
export { getReprTypeContextMenu as getReprTypeContextMenu };
export { getReprTypeDropdown as getReprTypeDropdown };
export { getBackgroundDropdown as getBackgroundDropdown };
export { getReflectionDropdown as getReflectionDropdown };
export { getChangeButton as getChangeButton };
export { getAdditionalContainer1 as getAdditionalContainer1 };
export { getSystemContainer as getSystemContainer };

