import atomb
import gleam/option.{None, Some}
import gleam/string
import gleam/string_tree
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn rfc_example_2_test() {
  atomb.Feed(
    title: "dive into mark",
    id: "tag:example.org,2003:3",
    updated: timestamp.from_calendar(
      calendar.Date(2005, calendar.July, 31),
      calendar.TimeOfDay(12, 29, 29, 0),
      calendar.utc_offset,
    ),
    subtitle: Some(atomb.TextContent(
      atomb.Html,
      "A <em>lot</em> of effort went into making this effortless",
    )),
    rights: Some(atomb.TextContent(
      atomb.Text,
      "Copyright (c) 2003, Mark Pilgrim",
    )),
    icon: None,
    logo: None,
    authors: [],
    links: [atomb.Link(href: "http://example.org/feed.atom", rel: Some("self"))],
    categories: [],
    contributors: [],
    generator: Some(atomb.Generator(
      text: "Example Toolkit",
      uri: Some("http://example.com/"),
      version: Some("1.0"),
    )),
    entries: [
      atomb.Entry(
        id: "tag:example.org,2003:3.2397",
        title: "Atom draft-07 snapshot",
        updated: timestamp.from_calendar(
          calendar.Date(2005, calendar.July, 31),
          calendar.TimeOfDay(12, 29, 29, 0),
          calendar.utc_offset,
        ),
        content: Some(atomb.InlineText(
          atomb.Xhtml,
          "<div xmlns=\"http://www.w3.org/1999/xhtml\">
  <p><i>[Update: The Atom draft is finished.]</i></p>
</div>",
        )),
        summary: None,
        categories: [],
        links: [
          atomb.Link(
            href: "http://example.org/2005/04/02/atom",
            rel: option.Some("alternate"),
          ),
          atomb.Link(
            href: "http://example.org/audio/ph34r_my_podcast.mp3",
            rel: option.Some("enclosure"),
          ),
        ],
        authors: [
          atomb.Person(
            name: "Mark Pilgrim",
            uri: Some("http://example.org/"),
            email: Some("f8dy@example.com"),
          ),
        ],
        contributors: [
          atomb.Person(name: "Sam Ruby", uri: None, email: None),
          atomb.Person(name: "Jeo Gregorio", uri: None, email: None),
        ],
        published: Some(timestamp.from_calendar(
          calendar.Date(2003, calendar.December, 13),
          calendar.TimeOfDay(8, 29, 29, 0),
          duration.seconds(-60 * 60 * 4),
        )),
        rights: None,
      ),
    ],
  )
  |> atomb.render
  |> string_tree.to_string
  |> string.replace("><", ">\n<")
  |> should.equal(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<feed xmlns=\"http://www.w3.org/2005/Atom\">
<title>dive into mark</title>
<id>tag:example.org,2003:3</id>
<updated>2005-07-31T12:29:29Z</updated>
<subtitle type=\"html\">
<![CDATA[A <em>lot</em> of effort went into making this effortless]]>
</subtitle>
<rights type=\"text\">Copyright (c) 2003, Mark Pilgrim</rights>
<generator uri=\"http://example.com/\" version=\"1.0\">Example Toolkit</generator>
<link href=\"http://example.org/feed.atom\" rel=\"self\" />
<entry>
<title>Atom draft-07 snapshot</title>
<id>tag:example.org,2003:3.2397</id>
<updated>2005-07-31T12:29:29Z</updated>
<published>2003-12-13T12:29:29Z</published>
<author>
<name>Mark Pilgrim</name>
<uri>http://example.org/</uri>
<email>f8dy@example.com</email>
</author>
<contributor>
<name>Sam Ruby</name>
</contributor>
<contributor>
<name>Jeo Gregorio</name>
</contributor>
<link href=\"http://example.org/2005/04/02/atom\" rel=\"alternate\" />
<link href=\"http://example.org/audio/ph34r_my_podcast.mp3\" rel=\"enclosure\" />
<content type=\"xhtml\">
<div xmlns=\"http://www.w3.org/1999/xhtml\">
  <p>
<i>[Update: The Atom draft is finished.]</i>
</p>
</div>
</content>
</entry>
</feed>",
  )
}
