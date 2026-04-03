const resourceName = 'andrew-notepad';
const app = document.getElementById('app');
const notepadPanel = document.getElementById('notepad-panel');
const paperPanel = document.getElementById('paper-panel');
const noteTitle = document.getElementById('note-title');
const noteText = document.getElementById('note-text');
const readText = document.getElementById('read-text');
const saveState = document.getElementById('save-state');
const saveBtn = document.getElementById('save-btn');
const tearBtn = document.getElementById('tear-btn');
const closeBtn = document.getElementById('close-btn');
const closePaperBtn = document.getElementById('close-paper');

let mode = null;
let lastSavedText = '';
let saveTimeout = null;
let pendingSave = false;

function post(action, data = {}) {
    return fetch(`https://${resourceName}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
    });
}

function setVisible(element, visible) {
    element.classList.toggle('hidden', !visible);
    element.setAttribute('aria-hidden', String(!visible));
}

function setStatus(text, state = 'dirty') {
    saveState.textContent = text;
    saveState.dataset.state = state;
}

function closeAll() {
    mode = null;
    setVisible(app, false);
    setVisible(notepadPanel, false);
    setVisible(paperPanel, false);
    readText.textContent = '';
}

function markDirty() {
    setStatus('Ungespeichert', 'dirty');
}

async function saveDraft(showFeedback = true) {
    const text = noteText.value;

    if (text === lastSavedText && !pendingSave) {
        setStatus('Bereits gespeichert', 'saved');
        return true;
    }

    pendingSave = false;
    await post('saveDraft', { text });
    lastSavedText = text;
    setStatus('Gespeichert', 'saved');

    if (showFeedback) {
        post('notify', { message: 'Notiz gespeichert.', type: 'success' });
    }

    return true;
}

function queueAutoSave() {
    pendingSave = true;
    markDirty();

    if (saveTimeout) {
        window.clearTimeout(saveTimeout);
    }

    saveTimeout = window.setTimeout(() => {
        saveDraft(false).catch(() => {
            setStatus('Speichern fehlgeschlagen', 'dirty');
        });
    }, 700);
}

window.addEventListener('message', (event) => {
    const data = event.data || {};

    if (data.action === 'openNotepad') {
        mode = 'write';
        noteTitle.textContent = data.title || 'Notizblock';
        noteText.placeholder = data.placeholder || 'Schreibe hier deine Notiz...';
        noteText.value = data.text || '';
        lastSavedText = noteText.value;
        pendingSave = false;
        setStatus(lastSavedText.length > 0 ? 'Gespeichert' : 'Bereit', lastSavedText.length > 0 ? 'saved' : 'dirty');
        setVisible(app, true);
        setVisible(notepadPanel, true);
        setVisible(paperPanel, false);
        window.setTimeout(() => noteText.focus(), 50);
        return;
    }

    if (data.action === 'readNote') {
        mode = 'read';
        readText.textContent = data.text || '';
        setVisible(app, true);
        setVisible(notepadPanel, false);
        setVisible(paperPanel, true);
        return;
    }

    if (data.action === 'closeAll') {
        closeAll();
    }
});

closeBtn.addEventListener('click', async () => {
    await post('close');
    closeAll();
});

closePaperBtn.addEventListener('click', async () => {
    await post('close');
    closeAll();
});

saveBtn.addEventListener('click', () => {
    saveDraft(true).catch(() => {
        setStatus('Speichern fehlgeschlagen', 'dirty');
    });
});

tearBtn.addEventListener('click', async () => {
    const text = noteText.value.trim();
    if (!text) {
        post('notify', { message: 'Die Notiz ist leer.', type: 'error' });
        return;
    }

    await saveDraft(false);
    await post('tearPage', { text: noteText.value });
});

noteText.addEventListener('input', queueAutoSave);

window.addEventListener('keydown', async (event) => {
    if (event.key === 'Escape') {
        await post('close');
        closeAll();
        return;
    }

    if (mode !== 'write') return;

    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 's') {
        event.preventDefault();
        saveDraft(true).catch(() => {
            setStatus('Speichern fehlgeschlagen', 'dirty');
        });
    }
});
