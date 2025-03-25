//// Atom feeds! See the RFC for details:
//// <https://www.ietf.org/rfc/rfc4287.txt>

import gleam/list
import gleam/option.{type Option}
import gleam/string_tree
import gleam/time/calendar
import gleam/time/timestamp.{type Timestamp}
import xmb.{type Xml, text, x}

/// The "atom:feed" element is the document (i.e., top-level) element of
/// an Atom Feed Document, acting as a container for metadata and data
/// associated with the feed.  Its element children consist of metadata
/// elements followed by zero or more atom:entry child elements.
pub type Feed {
  Feed(
    title: String,
    id: String,
    updated: Timestamp,
    subtitle: Option(TextContent),
    rights: Option(TextContent),
    icon: Option(String),
    logo: Option(String),
    authors: List(Person),
    links: List(Link),
    categories: List(Category),
    contributors: List(Person),
    generator: Option(Generator),
    entries: List(Entry),
  )
}

pub type Generator {
  Generator(text: String, uri: Option(String), version: Option(String))
}

pub type Person {
  Person(name: String, uri: Option(String), email: Option(String))
}

pub type Link {
  Link(href: String, rel: Option(String))
}

pub type Category {
  Category(term: String, scheme: Option(String), label: Option(String))
}

pub type Entry {
  Entry(
    id: String,
    title: String,
    updated: Timestamp,
    /// Must be present if there is no link with a `rel` attribute of
    /// `alternate`.
    content: Option(Content),
    summary: Option(TextContent),
    categories: List(Category),
    links: List(Link),
    /// At least 1 author must be present if the feed does not have an author.
    authors: List(Person),
    contributors: List(Person),
    published: Option(Timestamp),
    rights: Option(String),
  )
}

pub type TextMediaType {
  Text
  Html
  Xhtml
}

pub type TextContent {
  TextContent(media_type: TextMediaType, content: String)
}

pub type Content {
  InlineText(media_type: TextMediaType, content: String)
  OutOfLine(
    /// Must be in the format */*, e.g. text/json
    media_type: String,
    src_uri: String,
  )
}

pub fn render(feed: Feed) -> string_tree.StringTree {
  let Feed(
    title:,
    id:,
    updated:,
    subtitle:,
    rights:,
    icon:,
    logo:,
    authors:,
    links:,
    categories:,
    contributors:,
    entries:,
    generator: gen,
  ) = feed

  x("feed", [#("xmlns", "http://www.w3.org/2005/Atom")], [
    x("title", [], [text(title)]),
    x("id", [], [text(id)]),
    x("updated", [], [text(timestamp.to_rfc3339(updated, calendar.utc_offset))]),
    maybe(subtitle, text_content("subtitle", _)),
    maybe(rights, text_content("rights", _)),
    maybe(icon, text_element("icon", _)),
    maybe(logo, text_element("logo", _)),
    maybe(gen, generator),
    many(authors, person("author", _)),
    many(contributors, person("contributor", _)),
    many(links, link),
    many(categories, category),
    many(entries, entry),
  ])
  |> list.wrap
  |> xmb.render
}

fn generator(generator: Generator) -> Xml {
  let Generator(text: t, uri:, version:) = generator
  let values = [
    option.map(uri, fn(s) { #("uri", s) }),
    option.map(version, fn(s) { #("version", s) }),
  ]
  x("generator", option.values(values), [text(t)])
}

fn entry(entry: Entry) -> Xml {
  let Entry(
    id:,
    title:,
    updated:,
    content:,
    summary:,
    categories:,
    links:,
    authors:,
    contributors:,
    published:,
    rights:,
  ) = entry
  x("entry", [], [
    x("title", [], [text(title)]),
    x("id", [], [text(id)]),
    timestamp_element("updated", updated),
    maybe(summary, text_content("summary", _)),
    maybe(rights, text_element("rights", _)),
    maybe(published, timestamp_element("published", _)),
    many(categories, category),
    many(authors, person("author", _)),
    many(contributors, person("contributor", _)),
    many(links, link),
    maybe(content, content_element),
  ])
}

fn content_element(content: Content) -> Xml {
  case content {
    InlineText(media_type:, content:) ->
      text_content("content", TextContent(media_type, content))
    OutOfLine(media_type:, src_uri:) ->
      x("content", [#("type", media_type), #("src", src_uri)], [])
  }
}

fn timestamp_element(tag: String, timestamp: Timestamp) -> Xml {
  x(tag, [], [text(timestamp.to_rfc3339(timestamp, calendar.utc_offset))])
}

fn category(category: Category) -> Xml {
  let Category(term:, scheme:, label:) = category
  let values = [
    option.Some(#("term", term)),
    option.map(scheme, fn(s) { #("scheme", s) }),
    option.map(label, fn(s) { #("label", s) }),
  ]
  x("category", option.values(values), [])
}

fn link(link: Link) -> Xml {
  let Link(href:, rel:) = link
  let values = [
    option.Some(#("href", href)),
    option.map(rel, fn(s) { #("rel", s) }),
  ]
  x("link", option.values(values), [])
}

fn person(tag: String, person: Person) -> Xml {
  let Person(name:, uri:, email:) = person
  x(tag, [], [
    x("name", [], [text(name)]),
    maybe(uri, text_element("uri", _)),
    maybe(email, text_element("email", _)),
  ])
}

fn text_element(name: String, content: String) -> Xml {
  x(name, [], [text(content)])
}

fn text_content(name: String, content: TextContent) -> Xml {
  let #(media_type, content) = case content.media_type {
    Html -> #("html", xmb.cdata(content.content))
    Text -> #("text", xmb.text(content.content))
    Xhtml -> #(
      "xhtml",
      content.content
        |> string_tree.from_string
        |> xmb.dangerous_unescaped_fragment,
    )
  }
  x(name, [#("type", media_type)], [content])
}

fn maybe(item: Option(a), render: fn(a) -> Xml) -> Xml {
  case item {
    option.Some(value) -> render(value)
    option.None -> xmb.nothing()
  }
}

fn many(items: List(a), render: fn(a) -> Xml) -> Xml {
  list.map(items, render) |> xmb.fragment
}
