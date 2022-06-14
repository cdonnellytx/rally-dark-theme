## Vendor-specific

```regex
^\s+-(?:o|ms|moz|webkit)-.*\n
^\s+[\w-]+: -(?:o|ms|moz|webkit)-.*\n
```

## Non-color names

Build from this

```regex
^\s+
(?:
  (?:(?:min|max|line)-)?height
  (?:(?:min|max)-)?width
  align-items
  background-(?:position(?:-[xy])?|repeat|size)
  behavior
  border(?:-(?:top|left|bottom|right))*-(collapse|radius|style|width)
  bottom
  clear
  cursor
  display
  filter
  float
  font
  justify-content
  left
  list
  margin
  opacity
  overflow
  padding
  pointer
  position
  right
  table
  text-(align|decoration|overflow|transform)
  top
  trans\w*
  vertical-align
  visibility
  white
  word
  z-index
  zoom
)
(?:-[^:]*)*
:.*\n
```

Final:

```regex
^\s+(?:(?:(?:min|max|line)-)?height|(?:(?:min|max)-)?width|align-items|background-(?:position(?:-[xy])?|repeat|size)|behavior|border(?:-(?:top|left|bottom|right))*-(collapse|radius|style|width)|bottom|clear|cursor|display|filter|float|font|justify-content|left|list|margin|opacity|overflow|padding|pointer|position|right|table|text-(align|decoration|overflow|transform)|top|trans\w*|vertical-align|visibility|white|word|z-index|zoom)(?:-[^:]*)*:.*\n
```


## Delete non-color by value

```regex
^\s+(background|border|outline)(?:-[^:]*)*: (\d+(?:px|em)?);\n
^\s+(border|outline)(?:-(?:top|left|bottom|right))?: (\d+(?:px|em)?)(?: (solid|dashed|dotted|none))?(?: !important)?;\n
^\s+(border|outline)(?:-(?:top|left|bottom|right))?: (solid|dashed|dotted|none)(?: (\d+(?:px|em)?))?(?: !important)?;\n
```

## Replace non-color

### border: solid color 1px;

Will cover:

- `border: solid color 1px;`
- `border: solid color 1px !important;`
- `border: 1px color solid;`
- `border: 1px color solid !important;`

```regex
^(\s+(?:border|outline)(?:-(?:top|left|bottom|right))?):(?: (?:\d+(?:px|em)?|solid|dashed|dotted|none))+ (.+?)(?: (?:\d+(?:px|em)?|solid|dashed|dotted|none))+
```

```replace
$1-color: $2
```

### border: 1px solid color;

Will cover:

- `border: 1px solid color;`
- `border: 1px solid color !important;`
- `border: solid 1px color;`
- `border: solid 1px color !important;`

```regex
^(\s+(?:border|outline)(?:-(?:top|left|bottom|right))?):(?: (?:\d+(?:px|em)?|solid|dashed|dotted|none))*(?= [\S^!;])
```

```replace
$1-color:
```

### background: color url(...)

Will cover:

- `backround: color url(...);`
- `backround: color url(...) !important;`
- `background: color url(...) top right;`
- `background: color url(...) repeat-x;`
- ...

```regex
^(\s+background): ([#\w]\w*) (url\([^)]*\))(?: (?:\d+(?:px|%)?|right|top|bottom|left|center|(?:no-)?repeat(?:-[xy])?))*
```

```replace
$1-image: $3;\n$1: $2
```


### background: url(...)

Will cover:

- `backround: url(...);`
- `backround: url(...) !important;`
- `background: url(...) top right;`
- `background: url(...) repeat-x;`
- ...

```regex
^(\s+background): (url\([^)]*\))(?: (?:\d+(?:px|%)?|right|top|bottom|left|center|scroll|(?:no-)?repeat(?:-[xy])?))*
```

```replace
$1-image: $2;
```

### background: color right top no-repeat;

Will cover:

- `backround: color;`
- `backround: color !important;`
- `background: color top right;`
- `background: color repeat-x;`
- ...

```regex
^(\s+background): ([#\w]\w*)(?: (?:\d+(?:px|%)?|right|top|bottom|left|center|scroll|(?:no-)?repeat(?:-[xy])?))*
```

```replace
$1-color: $2
```

## Selectors

Search for `@media` queries first

```regex
@
```

### Empty selectors

```regex
^((?:[\w.][^,{]*,\n){0,10})((?:[\w.][^,{]* \{\n\}\n))
```


## Colors

### `#rgb` short hex format

```regex
color: #(\w)(\w)(\w)\b
```

```replace
color: #$1$1$2$2$3$3
```
