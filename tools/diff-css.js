function diff(a, b, filter = (k,a,b) => true) {
    if (a === b) { return }

    if (typeof a !== typeof(b)) {
        return [a,b]
    }
    if (typeof a !== "object") {
        return [a,b]
    }
    if (a === null || b === null) {
        return [a,b]
    }

    // a and b are objects
    var ret = a instanceof Array && b instanceof Array ? [] : {}
    var found = false;
    for (var k in a) {
        if (!filter(k, a[k], b[k])) { continue }
        let dk = diff(a[k], b[k], filter)
        if (dk !== undefined) {
            ret[k] = dk
            found = true
        }
    }
    for (var k in b) {
        if (!filter(k, undefined, b[k])) { continue }
        if (!(k in a)) {
            ret[k] = [undefined, b[k]]
            found = true
         }
    }
    return found ? ret : undefined
}

function captureStyle(style) {
    if (style instanceof HTMLElement) {
        style = window.getComputedStyle(style)
    }

    var ret = {}
    for (var k in style) {
        if (k === 'length') continue
        if (k.match(/^\d+$/)) continue
        if (k.match(/[A-Z]/)) continue
        ret[k] = style[k]
    }

    return ret
}

function findConveyer(element, styleName, undefinedValue = undefined) {
    for (var el = element; el; el = el.parentElement) {
        var style = window.getComputedStyle(element);
        if (style !== undefinedValue) {
            return el
        }
    }
}

let findBackgroundColorProvider = element => findConveyer(element, "background-color", "rgba(0, 0, 0, 0)")
