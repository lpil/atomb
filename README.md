# atomb

An Atom feed builder for Gleam!

[![Package Version](https://img.shields.io/hexpm/v/atomb)](https://hex.pm/packages/atomb)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/atomb/)

```sh
gleam add atomb@1
```
```gleam
import atomb

pub fn main() {
  let feed = atomb.Feed(
    // ... fill in the data structure
  )

  // Render it!
  atomb.render(feed)
}
```

Further documentation can be found at <https://hexdocs.pm/atomb> and
<https://www.ietf.org/rfc/rfc4287.txt>.
