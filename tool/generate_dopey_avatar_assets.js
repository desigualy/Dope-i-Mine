const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const ROOT = path.resolve(__dirname, '..');
const OUT_DIR = path.join(ROOT, 'assets', 'avatar', 'dopey');
const CANONICAL_SIZE = 1024;
const OUTPUT_SIZES = [1024, 512, 256, 128, 64];

const MOODS = [
    'neutral',
    'happy',
    'focused',
    'overwhelmed',
    'encouraging',
    'proud',
    'celebration',
    'calm',
];

const COLORS = {
    ink: hex('#102033'),
    inkSoft: hex('#20354a'),
    white: hex('#ffffff'),
    headTop: hex('#90fff1'),
    headMid: hex('#2dd4bf'),
    headBottom: hex('#0f9f91'),
    headCalmTop: hex('#b8eee8'),
    headCalmBottom: hex('#6fbab1'),
    outline: hex('#0f766e'),
    outlineDark: hex('#134e4a'),
    blush: hex('#f9a8d4'),
    shoulderTop: hex('#4c1d95'),
    shoulderBottom: hex('#111827'),
    accent: hex('#a78bfa'),
    gold: hex('#fbbf24'),
    red: hex('#fb7185'),
    sky: hex('#38bdf8'),
    green: hex('#34d399'),
};

function hex(value) {
    const normalized = value.replace('#', '');
    return [
        parseInt(normalized.slice(0, 2), 16),
        parseInt(normalized.slice(2, 4), 16),
        parseInt(normalized.slice(4, 6), 16),
    ];
}

function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

function mix(a, b, t) {
    const amount = clamp(t, 0, 1);
    return [
        Math.round(a[0] + (b[0] - a[0]) * amount),
        Math.round(a[1] + (b[1] - a[1]) * amount),
        Math.round(a[2] + (b[2] - a[2]) * amount),
    ];
}

function shade(color, amount) {
    return amount >= 0 ? mix(color, COLORS.white, amount) : mix(color, [0, 0, 0], -amount);
}

function ensureDir(dir) {
    fs.mkdirSync(dir, { recursive: true });
}

class Canvas {
    constructor(size) {
        this.width = size;
        this.height = size;
        this.data = Buffer.alloc(size * size * 4);
        this.scale = size / CANONICAL_SIZE;
    }

    s(value) {
        return value * this.scale;
    }

    blendPixel(x, y, color, alpha = 255) {
        const ix = Math.round(x);
        const iy = Math.round(y);
        if (ix < 0 || iy < 0 || ix >= this.width || iy >= this.height || alpha <= 0) {
            return;
        }

        const i = (iy * this.width + ix) * 4;
        const srcA = clamp(alpha, 0, 255) / 255;
        const dstA = this.data[i + 3] / 255;
        const outA = srcA + dstA * (1 - srcA);

        if (outA <= 0) {
            return;
        }

        this.data[i] = Math.round((color[0] * srcA + this.data[i] * dstA * (1 - srcA)) / outA);
        this.data[i + 1] = Math.round((color[1] * srcA + this.data[i + 1] * dstA * (1 - srcA)) / outA);
        this.data[i + 2] = Math.round((color[2] * srcA + this.data[i + 2] * dstA * (1 - srcA)) / outA);
        this.data[i + 3] = Math.round(outA * 255);
    }

    ellipse(cx, cy, rx, ry, color, options = {}) {
        const alpha = options.alpha ?? 255;
        const rotation = options.rotation ?? 0;
        const gradientTop = options.gradientTop;
        const gradientBottom = options.gradientBottom;
        const highlight = options.highlight ?? 0;
        const c = Math.cos(rotation);
        const s = Math.sin(rotation);
        const pcx = this.s(cx);
        const pcy = this.s(cy);
        const prx = this.s(rx);
        const pry = this.s(ry);
        const pad = 3;
        const minX = Math.floor(pcx - Math.max(prx, pry) - pad);
        const maxX = Math.ceil(pcx + Math.max(prx, pry) + pad);
        const minY = Math.floor(pcy - Math.max(prx, pry) - pad);
        const maxY = Math.ceil(pcy + Math.max(prx, pry) + pad);

        for (let y = minY; y <= maxY; y += 1) {
            for (let x = minX; x <= maxX; x += 1) {
                const dx = x - pcx;
                const dy = y - pcy;
                const localX = dx * c + dy * s;
                const localY = -dx * s + dy * c;
                const d = (localX * localX) / (prx * prx) + (localY * localY) / (pry * pry);
                const coverage = clamp((1.015 - d) / 0.025, 0, 1);
                if (coverage <= 0) continue;

                let fill = color;
                if (gradientTop && gradientBottom) {
                    const t = clamp((localY / pry + 1) / 2, 0, 1);
                    fill = mix(gradientTop, gradientBottom, t);
                }

                if (highlight > 0) {
                    const hx = localX / prx + 0.35;
                    const hy = localY / pry + 0.42;
                    const light = clamp(1 - Math.sqrt(hx * hx + hy * hy), 0, 1) * highlight;
                    fill = shade(fill, light);
                }

                this.blendPixel(x, y, fill, alpha * coverage);
            }
        }
    }

    line(x1, y1, x2, y2, width, color, alpha = 255) {
        const px1 = this.s(x1);
        const py1 = this.s(y1);
        const px2 = this.s(x2);
        const py2 = this.s(y2);
        const pw = this.s(width);
        const minX = Math.floor(Math.min(px1, px2) - pw - 2);
        const maxX = Math.ceil(Math.max(px1, px2) + pw + 2);
        const minY = Math.floor(Math.min(py1, py2) - pw - 2);
        const maxY = Math.ceil(Math.max(py1, py2) + pw + 2);
        const vx = px2 - px1;
        const vy = py2 - py1;
        const lenSq = vx * vx + vy * vy || 1;

        for (let y = minY; y <= maxY; y += 1) {
            for (let x = minX; x <= maxX; x += 1) {
                const t = clamp(((x - px1) * vx + (y - py1) * vy) / lenSq, 0, 1);
                const cx = px1 + vx * t;
                const cy = py1 + vy * t;
                const dist = Math.hypot(x - cx, y - cy);
                const coverage = clamp(pw / 2 + 1 - dist, 0, 1);
                if (coverage > 0) this.blendPixel(x, y, color, alpha * coverage);
            }
        }
    }

    arc(cx, cy, rx, ry, start, end, width, color, alpha = 255) {
        const steps = Math.max(10, Math.ceil(Math.abs(end - start) * Math.max(rx, ry) / 12));
        let previous = null;
        for (let i = 0; i <= steps; i += 1) {
            const t = start + (end - start) * (i / steps);
            const point = [cx + Math.cos(t) * rx, cy + Math.sin(t) * ry];
            if (previous) this.line(previous[0], previous[1], point[0], point[1], width, color, alpha);
            previous = point;
        }
    }

    polygon(points, color, alpha = 255) {
        const scaled = points.map(([x, y]) => [this.s(x), this.s(y)]);
        const minX = Math.floor(Math.min(...scaled.map((p) => p[0])));
        const maxX = Math.ceil(Math.max(...scaled.map((p) => p[0])));
        const minY = Math.floor(Math.min(...scaled.map((p) => p[1])));
        const maxY = Math.ceil(Math.max(...scaled.map((p) => p[1])));
        for (let y = minY; y <= maxY; y += 1) {
            for (let x = minX; x <= maxX; x += 1) {
                if (pointInPolygon(x, y, scaled)) this.blendPixel(x, y, color, alpha);
            }
        }
    }
}

function pointInPolygon(x, y, points) {
    let inside = false;
    for (let i = 0, j = points.length - 1; i < points.length; j = i, i += 1) {
        const xi = points[i][0];
        const yi = points[i][1];
        const xj = points[j][0];
        const yj = points[j][1];
        const intersect = yi > y !== yj > y && x < ((xj - xi) * (y - yi)) / (yj - yi || 1) + xi;
        if (intersect) inside = !inside;
    }
    return inside;
}

function drawBase(canvas, mood) {
    const calm = mood === 'calm';
    const top = calm ? COLORS.headCalmTop : COLORS.headTop;
    const bottom = calm ? COLORS.headCalmBottom : COLORS.headBottom;
    const shoulderTop = calm ? mix(COLORS.shoulderTop, [140, 150, 170], 0.35) : COLORS.shoulderTop;
    const shoulderBottom = calm ? mix(COLORS.shoulderBottom, [120, 130, 150], 0.18) : COLORS.shoulderBottom;
    const alpha = calm ? 230 : 255;

    if (mood === 'celebration') drawCelebrationArms(canvas);
    if (mood === 'encouraging') drawThumb(canvas);

    canvas.ellipse(512, 832, 330, 170, COLORS.outlineDark, { alpha: 230 });
    canvas.ellipse(512, 815, 300, 155, shoulderBottom, {
        alpha,
        gradientTop: shoulderTop,
        gradientBottom: shoulderBottom,
        highlight: calm ? 0.08 : 0.16,
    });
    canvas.ellipse(512, 698, 86, 86, COLORS.outlineDark, { alpha: 230 });
    canvas.ellipse(512, 686, 72, 82, bottom, { alpha, gradientTop: top, gradientBottom: bottom, highlight: 0.16 });

    canvas.ellipse(512, 440, 292, 314, COLORS.outlineDark, { alpha: 245 });
    canvas.ellipse(512, 426, 270, 292, bottom, {
        alpha,
        gradientTop: top,
        gradientBottom: bottom,
        highlight: calm ? 0.18 : 0.28,
    });

    canvas.ellipse(402, 264, 46, 54, shade(top, -0.08), { alpha: 170, rotation: -0.35 });
    canvas.ellipse(622, 264, 46, 54, shade(top, -0.08), { alpha: 170, rotation: 0.35 });
    canvas.ellipse(414, 332, 34, 18, COLORS.white, { alpha: calm ? 44 : 72, rotation: -0.35 });
}

function drawOpenEye(canvas, cx, cy, mood = 'neutral') {
    const narrowed = mood === 'focused';
    const rx = narrowed ? 52 : 45;
    const ry = narrowed ? 20 : 38;
    canvas.ellipse(cx, cy, rx, ry, COLORS.white, { alpha: 240 });
    canvas.ellipse(cx, cy + (narrowed ? 2 : 3), narrowed ? 15 : 19, narrowed ? 14 : 22, COLORS.ink, { alpha: 250 });
    canvas.ellipse(cx - 7, cy - 7, 5, 5, COLORS.white, { alpha: 200 });
    if (narrowed) {
        canvas.line(cx - 60, cy - 26, cx + 58, cy - 8, 14, COLORS.inkSoft, 235);
    }
}

function drawClosedEye(canvas, cx, cy, width = 55, alpha = 245) {
    canvas.arc(cx, cy, width, 35, Math.PI + 0.12, Math.PI * 2 - 0.12, 13, COLORS.ink, alpha);
}

function drawSpiralEye(canvas, cx, cy) {
    let previous = null;
    for (let i = 0; i <= 70; i += 1) {
        const t = i / 70;
        const angle = t * Math.PI * 4.6;
        const radius = 4 + t * 42;
        const point = [cx + Math.cos(angle) * radius, cy + Math.sin(angle) * radius];
        if (previous) canvas.line(previous[0], previous[1], point[0], point[1], 9, COLORS.ink, 245);
        previous = point;
    }
}

function drawSmile(canvas, cx, cy, rx, ry, width = 13, alpha = 245) {
    canvas.arc(cx, cy, rx, ry, 0.12, Math.PI - 0.12, width, COLORS.ink, alpha);
}

function drawBlush(canvas, alpha = 82) {
    canvas.ellipse(350, 544, 52, 28, COLORS.blush, { alpha, rotation: -0.18 });
    canvas.ellipse(674, 544, 52, 28, COLORS.blush, { alpha, rotation: 0.18 });
}

function drawThumb(canvas) {
    canvas.line(696, 730, 792, 614, 58, COLORS.outlineDark, 245);
    canvas.line(696, 730, 792, 614, 42, COLORS.headBottom, 255);
    canvas.ellipse(826, 592, 54, 45, COLORS.outlineDark, { alpha: 245, rotation: -0.45 });
    canvas.ellipse(823, 592, 40, 32, COLORS.headTop, { alpha: 255, rotation: -0.45 });
    canvas.line(830, 570, 870, 520, 34, COLORS.outlineDark, 245);
    canvas.line(830, 570, 870, 520, 22, COLORS.headTop, 255);
    canvas.ellipse(880, 505, 20, 26, COLORS.headTop, { alpha: 255, rotation: -0.45 });
}

function drawCelebrationArms(canvas) {
    canvas.line(324, 738, 222, 438, 64, COLORS.outlineDark, 245);
    canvas.line(324, 738, 222, 438, 46, COLORS.headBottom, 255);
    canvas.ellipse(212, 392, 54, 48, COLORS.outlineDark, { alpha: 245, rotation: -0.35 });
    canvas.ellipse(212, 392, 39, 34, COLORS.headTop, { alpha: 255, rotation: -0.35 });

    canvas.line(700, 738, 804, 438, 64, COLORS.outlineDark, 245);
    canvas.line(700, 738, 804, 438, 46, COLORS.headBottom, 255);
    canvas.ellipse(814, 392, 54, 48, COLORS.outlineDark, { alpha: 245, rotation: 0.35 });
    canvas.ellipse(814, 392, 39, 34, COLORS.headTop, { alpha: 255, rotation: 0.35 });
}

function drawConfetti(canvas) {
    const pieces = [
        [256, 188, COLORS.gold, -0.5],
        [340, 124, COLORS.sky, 0.3],
        [484, 136, COLORS.red, -0.2],
        [610, 116, COLORS.green, 0.7],
        [742, 194, COLORS.accent, -0.8],
        [782, 292, COLORS.gold, 0.4],
        [216, 302, COLORS.red, 0.8],
    ];
    for (const [x, y, color, rot] of pieces) {
        canvas.polygon(
            [
                [x - 18, y - 7],
                [x + 18, y - 7],
                [x + 18, y + 7],
                [x - 18, y + 7],
            ].map(([px, py]) => rotatePoint(px, py, x, y, rot)),
            color,
            235,
        );
    }
    drawStar(canvas, 176, 226, 28, COLORS.gold);
    drawStar(canvas, 846, 236, 24, COLORS.sky);
}

function rotatePoint(x, y, cx, cy, angle) {
    const c = Math.cos(angle);
    const s = Math.sin(angle);
    return [cx + (x - cx) * c - (y - cy) * s, cy + (x - cx) * s + (y - cy) * c];
}

function drawStar(canvas, cx, cy, radius, color) {
    canvas.line(cx - radius, cy, cx + radius, cy, 8, color, 235);
    canvas.line(cx, cy - radius, cx, cy + radius, 8, color, 235);
}

function drawMood(canvas, mood) {
    drawBase(canvas, mood);

    switch (mood) {
        case 'neutral':
            drawOpenEye(canvas, 416, 456);
            drawOpenEye(canvas, 608, 456);
            drawSmile(canvas, 512, 588, 76, 42);
            drawBlush(canvas, 45);
            break;
        case 'happy':
            drawClosedEye(canvas, 416, 456, 58);
            drawClosedEye(canvas, 608, 456, 58);
            drawSmile(canvas, 512, 572, 126, 86, 15);
            drawBlush(canvas, 90);
            break;
        case 'focused':
            drawOpenEye(canvas, 416, 462, 'focused');
            drawOpenEye(canvas, 608, 462, 'focused');
            canvas.line(442, 604, 585, 592, 14, COLORS.ink, 245);
            canvas.line(356, 394, 466, 420, 14, COLORS.inkSoft, 210);
            canvas.line(668, 394, 558, 420, 14, COLORS.inkSoft, 210);
            break;
        case 'overwhelmed':
            drawSpiralEye(canvas, 414, 456);
            drawSpiralEye(canvas, 610, 456);
            canvas.line(434, 615, 470, 590, 12, COLORS.ink, 245);
            canvas.line(470, 590, 512, 622, 12, COLORS.ink, 245);
            canvas.line(512, 622, 552, 590, 12, COLORS.ink, 245);
            canvas.line(552, 590, 590, 615, 12, COLORS.ink, 245);
            canvas.ellipse(708, 378, 18, 38, COLORS.sky, { alpha: 210, rotation: -0.25 });
            canvas.ellipse(704, 390, 9, 18, COLORS.white, { alpha: 120, rotation: -0.25 });
            break;
        case 'encouraging':
            drawOpenEye(canvas, 410, 454);
            drawOpenEye(canvas, 604, 448);
            drawSmile(canvas, 506, 580, 94, 58, 14);
            drawBlush(canvas, 60);
            canvas.arc(400, 392, 50, 24, Math.PI * 1.08, Math.PI * 1.88, 11, COLORS.inkSoft, 180);
            break;
        case 'proud':
            drawOpenEye(canvas, 416, 450);
            drawOpenEye(canvas, 608, 450);
            canvas.arc(512, 568, 102, 56, 0.08, Math.PI - 0.08, 15, COLORS.ink, 245);
            canvas.line(370, 404, 462, 392, 13, COLORS.inkSoft, 180);
            canvas.line(562, 392, 654, 404, 13, COLORS.inkSoft, 180);
            drawBlush(canvas, 52);
            break;
        case 'celebration':
            drawConfetti(canvas);
            drawClosedEye(canvas, 416, 452, 62);
            drawClosedEye(canvas, 608, 452, 62);
            drawSmile(canvas, 512, 570, 136, 94, 16);
            drawBlush(canvas, 100);
            break;
        case 'calm':
            drawClosedEye(canvas, 416, 460, 54, 205);
            drawClosedEye(canvas, 608, 460, 54, 205);
            drawSmile(canvas, 512, 592, 82, 42, 12, 190);
            canvas.ellipse(350, 544, 46, 23, COLORS.blush, { alpha: 38, rotation: -0.18 });
            canvas.ellipse(674, 544, 46, 23, COLORS.blush, { alpha: 38, rotation: 0.18 });
            break;
        default:
            throw new Error(`Unknown mood: ${mood}`);
    }
}

function writePng(filePath, width, height, rgba) {
    const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
    const ihdr = Buffer.alloc(13);
    ihdr.writeUInt32BE(width, 0);
    ihdr.writeUInt32BE(height, 4);
    ihdr[8] = 8;
    ihdr[9] = 6;
    ihdr[10] = 0;
    ihdr[11] = 0;
    ihdr[12] = 0;

    const stride = width * 4;
    const raw = Buffer.alloc((stride + 1) * height);
    for (let y = 0; y < height; y += 1) {
        const rowStart = y * (stride + 1);
        raw[rowStart] = 0;
        rgba.copy(raw, rowStart + 1, y * stride, y * stride + stride);
    }

    const png = Buffer.concat([
        signature,
        chunk('IHDR', ihdr),
        chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
        chunk('IEND', Buffer.alloc(0)),
    ]);

    fs.writeFileSync(filePath, png);
}

function chunk(type, data) {
    const typeBuffer = Buffer.from(type, 'ascii');
    const length = Buffer.alloc(4);
    length.writeUInt32BE(data.length, 0);
    const crc = Buffer.alloc(4);
    crc.writeUInt32BE(crc32(Buffer.concat([typeBuffer, data])), 0);
    return Buffer.concat([length, typeBuffer, data, crc]);
}

const CRC_TABLE = (() => {
    const table = new Uint32Array(256);
    for (let n = 0; n < 256; n += 1) {
        let c = n;
        for (let k = 0; k < 8; k += 1) {
            c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
        }
        table[n] = c >>> 0;
    }
    return table;
})();

function crc32(buffer) {
    let crc = 0xffffffff;
    for (let i = 0; i < buffer.length; i += 1) {
        crc = CRC_TABLE[(crc ^ buffer[i]) & 0xff] ^ (crc >>> 8);
    }
    return (crc ^ 0xffffffff) >>> 0;
}

function main() {
    ensureDir(OUT_DIR);

    for (const size of OUTPUT_SIZES) {
        const dir = size === 1024 ? OUT_DIR : path.join(OUT_DIR, `${size}`);
        ensureDir(dir);

        for (const mood of MOODS) {
            const canvas = new Canvas(size);
            drawMood(canvas, mood);
            const filePath = path.join(dir, `${mood}.png`);
            writePng(filePath, size, size, canvas.data);
        }
    }

    console.log(`Generated ${MOODS.length} Dope-i avatar moods at ${OUT_DIR}`);
    console.log(`Top-level files are 1024x1024 masters. Downscale exports: ${OUTPUT_SIZES.slice(1).join(', ')}.`);
}

main();