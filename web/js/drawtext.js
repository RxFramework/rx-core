let lastPromptRaw = "";
let currentPosition = "left";

const ui = {
    container: () => document.getElementById("drawtext-container"),
    panel: () => document.getElementById("help-text-ui"),
    content: () => document.getElementById("help-text-content"),
};

const escapeHtml = (str) => {
    if (str == null) return "";
    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;");
};

/** Parse one line like ds-advancedgarage (supports [E], E - text, Press E …, ~INPUT_CONTEXT~) */
const formatPromptLine = (raw) => {
    let line = (raw || "").trim();
    if (!line) return "";

    line = line.replace(/~INPUT_CONTEXT~/g, "E").replace(/~INPUT_DETONATE~/g, "G");
    line = line.replace(/~[a-zA-Z]~/g, "").trim();

    const inlineBracket = line.match(/\[([^\]]+)\]\s*(.*)?/);
    if (inlineBracket && !line.match(/^\[/)) {
        const rest = inlineBracket[2] ? ` ${escapeHtml(inlineBracket[2].trim())}` : "";
        return `<span class="key-hint">${escapeHtml(inlineBracket[1])}</span>${rest}`;
    }

    const bracket = line.match(/^\[([^\]]+)\]\s*(.*)$/);
    if (bracket) {
        const rest = bracket[2] ? ` ${escapeHtml(bracket[2])}` : "";
        return `<span class="key-hint">${escapeHtml(bracket[1])}</span>${rest}`;
    }

    const parts = line.split(/\s+/);
    if (parts.length >= 3 && parts[1] === "-") {
        const rest = parts.slice(2).join(" ");
        return `<span class="key-hint">${escapeHtml(parts[0])}</span> - ${escapeHtml(rest)}`;
    }

    const pressMatch = line.match(/^(Press|press)\s+(\S+)\s+(.*)$/);
    if (pressMatch) {
        return `${escapeHtml(pressMatch[1])} <span class="key-hint">${escapeHtml(pressMatch[2])}</span> ${escapeHtml(pressMatch[3])}`;
    }

    if (parts.length >= 2) {
        parts[1] = `<span class="key-hint">${escapeHtml(parts[1])}</span>`;
        return parts.join(" ");
    }

    return escapeHtml(line);
};

const setPromptContent = (content, text) => {
    if (!content) return;
    const rawFull = (typeof text === "string" ? text : "").trim();
    const blocks = rawFull
        .split(/\n+/)
        .map((line) => {
            const html = formatPromptLine(line);
            if (!html) return "";
            return `<div class="help-text-stack-line">${html}</div>`;
        })
        .filter(Boolean);
    content.innerHTML = blocks.join("");
};

const applyPosition = (panel, position) => {
    if (!panel) return;
    panel.classList.remove("pos-left", "pos-right", "pos-top");
    if (position === "right") panel.classList.add("pos-right");
    else if (position === "top") panel.classList.add("pos-top");
};

const drawText = async (textData) => {
    const container = ui.container();
    const panel = ui.panel();
    const content = ui.content();
    if (!container || !panel || !content) return;

    const raw = textData?.text ?? "";
    if (panel.classList.contains("show") && raw === lastPromptRaw) return;

    lastPromptRaw = raw;
    currentPosition = textData?.position || "left";
    applyPosition(panel, currentPosition);
    setPromptContent(content, raw);

    container.classList.add("is-visible");
    panel.setAttribute("aria-hidden", "false");
    panel.classList.remove("hide", "pressed");
    await sleep(50);
    panel.classList.add("show");
};

const changeText = async (textData) => {
    const panel = ui.panel();
    const content = ui.content();
    if (!panel || !content) return;

    panel.classList.add("pressed");
    await sleep(200);
    panel.classList.remove("pressed");
    await drawText(textData);
};

const hideText = async () => {
    const container = ui.container();
    const panel = ui.panel();
    const content = ui.content();
    if (!panel || !container) return;

    lastPromptRaw = "";
    panel.classList.remove("show", "pressed");
    panel.classList.add("hide");
    panel.setAttribute("aria-hidden", "true");

    await sleep(200);
    panel.classList.remove("hide");
    if (content) content.innerHTML = "";
    container.classList.remove("is-visible");
};

const keyPressed = () => {
    const panel = ui.panel();
    if (!panel) return;
    panel.classList.add("pressed");
    setTimeout(() => {
        hideText();
    }, 150);
};

window.addEventListener("message", (event) => {
    const data = event.data;
    const action = data.action;
    const textData = data.data;
    switch (action) {
        case "DRAW_TEXT":
            return drawText(textData);
        case "CHANGE_TEXT":
            return changeText(textData);
        case "HIDE_TEXT":
            return hideText();
        case "KEY_PRESSED":
            return keyPressed();
        default:
            return;
    }
});

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
