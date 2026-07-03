-- Convert citeproc's #refs div (a stack of <p>s) into a real ordered list,
-- so DOCX -> tagged PDF produces L / LI / Lbl / LBody instead of bare <P>s.
-- The per-entry bookmark id (ref-KEY) is preserved so in-text [n] links still resolve.
function Div(div)
  if div.identifier ~= "refs" then return nil end
  local items = {}
  for _, entry in ipairs(div.content) do
    -- each reference is an inner Div: ("ref-KEY", ["csl-entry"]) wrapping a Para
    if entry.t == "Div" then
      local id = entry.identifier
      local body = nil
      for _, blk in ipairs(entry.content) do
        if blk.t == "Para" or blk.t == "Plain" then
          for _, il in ipairs(blk.content) do
            if il.t == "Span" and il.classes:includes("csl-right-inline") then
              body = il.content       -- the reference text, minus the [n] label
            end
          end
        end
      end
      body = body or {}
      -- re-anchor the bookmark on the list item so in-text links keep working
      local anchored = pandoc.Span(body, pandoc.Attr(id or "", {}, {}))
      items[#items + 1] = { pandoc.Plain({ anchored }) }
    end
  end
  -- Decimal "1." numbering supplies the accessible <Lbl>
  return pandoc.OrderedList(items, pandoc.ListAttributes(1, "Decimal", "Period"))
end
