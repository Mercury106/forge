class ForgeAdmin.Map
  graph: (element) ->
    @element = element
    @setupElement()
    @loadData()
  parseDate: (dateStr) ->
    pattern = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}.\d{3})Z$/
    match = pattern.exec(dateStr);
    if (!match) 
      throw new Error('::Error, #dp could not parse dateStr '+dateStr)
    return new Date(match[1], match[2]-1, match[3], match[4], match[5], match[6]);

# window.Map = Map