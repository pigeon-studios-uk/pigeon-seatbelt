// Pigeon Seatbelt: the indicator and sounds.
//
// client/main.lua sends three messages:
//   { type: 'config', indicator: {...}, chimeVolume, clickVolume }  once, at start
//   { type: 'alerts', indicator: bool, chime: bool }               when either changes
//   { type: 'click', on: bool }                                    on buckling or unbuckling
// The sounds are made here with Web Audio, so there are no sound files. Only this player hears them.

const indicator = document.getElementById('indicator');
let audio = null;
let chimeTimer = null;
let chimeVolume = 0.35;
let clickVolume = 0.5;

function context() {
    if (!audio) audio = new (window.AudioContext || window.webkitAudioContext)();
    if (audio.state === 'suspended') audio.resume();
    return audio;
}

// A short tone that fades out.
function tone(frequency, start, length, volume, type) {
    const ctx = context();
    const oscillator = ctx.createOscillator();
    const gain = ctx.createGain();
    oscillator.type = type || 'sine';
    oscillator.frequency.value = frequency;
    gain.gain.setValueAtTime(0, ctx.currentTime + start);
    gain.gain.linearRampToValueAtTime(volume, ctx.currentTime + start + 0.005);
    gain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + start + length);
    oscillator.connect(gain).connect(ctx.destination);
    oscillator.start(ctx.currentTime + start);
    oscillator.stop(ctx.currentTime + start + length + 0.02);
}

// Buckling: two quick clicks, rising. Unbuckling: one, falling.
function click(on) {
    if (clickVolume <= 0) return;
    if (on) {
        tone(1800, 0, 0.04, clickVolume, 'square');
        tone(2400, 0.07, 0.05, clickVolume, 'square');
    } else {
        tone(1400, 0, 0.06, clickVolume * 0.8, 'square');
    }
}

// A car's seatbelt chime: a soft two-note ding, once a second.
function ding() {
    tone(880, 0, 0.45, chimeVolume);
    tone(1320, 0, 0.3, chimeVolume * 0.35);
}

function setChime(on) {
    if (on && !chimeTimer && chimeVolume > 0) {
        ding();
        chimeTimer = setInterval(ding, 1000);
    } else if (!on && chimeTimer) {
        clearInterval(chimeTimer);
        chimeTimer = null;
    }
}

// Corner and offset, with offsets given in pixels at 1080p.
function place(settings) {
    const corner = settings.position || 'bottom-right';
    const x = ((Number(settings.offsetX) || 0) / 1080) * 100 + 'vh';
    const y = ((Number(settings.offsetY) || 0) / 1080) * 100 + 'vh';
    indicator.style.top = indicator.style.bottom = indicator.style.left = indicator.style.right = '';
    indicator.style[corner.startsWith('top') ? 'top' : 'bottom'] = y;
    indicator.style[corner.endsWith('left') ? 'left' : 'right'] = x;
}

window.addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.type === 'config') {
        place(data.indicator || {});
        chimeVolume = Math.max(0, Math.min(1, Number(data.chimeVolume ?? 0.35)));
        clickVolume = Math.max(0, Math.min(1, Number(data.clickVolume ?? 0.5)));
    } else if (data.type === 'alerts') {
        indicator.classList.toggle('shown', !!data.indicator);
        setChime(!!data.chime);
    } else if (data.type === 'click') {
        click(!!data.on);
    }
});
