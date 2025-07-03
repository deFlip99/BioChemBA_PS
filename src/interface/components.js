import { 
    createBaseLayout, 
    createSecondaryLayout, 
    createControlsContainer,
    createContextMenu,
    createDropdown,
    createButton,
    createFlexContainer,
    createSystemContainer,
    createToggleButton
} from './interface_utils.js';


export function getBaseLayout() {
    return createBaseLayout("main-layout");
}

export function getSecondaryLayout() {
    return createSecondaryLayout("secondary-left", "secondary-right");
}

export function getControlsContainer() {
    return createControlsContainer("controls-container");
}

export function getReprTypeContextMenu() {
    return createContextMenu("context-menu-repr-type", [
        { value: "BALL_AND_STICK", label: "Ball & Stick" },
        { value: "STICK", label: "Stick" },
        { value: "VAN_DER_WAALS", label: "Van der Waals" }
    ]);
}

export function getReprTypeDropdown() {
    const options = [
        ["BALL_AND_STICK", "Ball and Stick"],
        ["STICK", "Stick"],
        ["VAN_DER_WAALS", "Van der Waals"]
    ];
    return createDropdown("repr-type-select", "Representation: ", options);
}

export function getBackgroundDropdown() {
    const options = [
        ["black", "Black"],
        ["white", "White"],
        ["gray", "Gray"],
        ["lightgray", "Light Gray"]
    ];
    return createDropdown("background-color-select", "Background Color: ", options);
}

export function getReflectionDropdown() {
    const options = [
        ["0.0", "None"],
        ["0.5", "Medium"],
        ["1.0", "High"]
    ];
    return createDropdown("reflection-select", "Reflection: ", options);
}

export function getChangeButton() {
    return createButton("change-button", "Change", {
        width: "80%",
        action: () => {
            document.dispatchEvent(new Event("change-event"));
        }
    });
}


export function getAdditionalContainer1() {
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


export function getSystemContainer(systems) {
    return createSystemContainer(systems);
}

export {createButton}