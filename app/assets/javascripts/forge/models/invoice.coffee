App.Invoice = DS.Model.extend
  date: DS.attr('number')
  period_start: DS.attr('number')
  period_end: DS.attr('number')
  lines: DS.attr('raw')
  subtotal: DS.attr('number')
  total: DS.attr('number')
  paid: DS.attr('boolean')

  invoiceLines: (->
    @get('lines.data')
  ).property('lines')

  startDate: (->
    new Date(@get('period_start'))
  ).property('period_start')

  endDate: (->
    new Date(@get('period_end'))
  ).property('period_end')