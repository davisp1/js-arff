module.exports = {
  relation: 'foo',
  description: '\n\nComments starts a %.\nA relation MAY be named.',
  attributes: [
    {
      name: 'numeric',
      type: 'numeric'
    },
    {
      name: 'date',
      type: 'date'
    },
    {
      name: 'dateWithFormat',
      type: 'date',
      format: 'MM/DD/YY'
    },
    {
      name: 'string',
      type: 'string'
    },
    {
      name: 'enumerate',
      type: 'enum',
      values: [
        'foo',
        'bar',
        'baz',
        'dfgdfgdg',
        'sdgsdgsgds'
      ]
    },
    {
      name: 'rawStringAtTheEndOfEnumerate',
      type: 'enum',
      values: [
        'rawString'
      ]
    }
  ],
  data: [
    {
      date: new Date(Date.UTC(2014, 11, 16, 19, 42, 1)),
      dateWithFormat: new Date(Date.UTC(2015, 5, 23)),
      string: 'can have spaces',
      enumerate: 'bar'
    },
    {
      date: new Date(Date.UTC(2014, 11, 16, 19, 42, 1)),
      numeric: 42,
      string: 'another example'
    },
    {
      numeric: 3.259
    }
  ]
}
