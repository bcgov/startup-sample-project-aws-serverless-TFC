/**
 * Define db schema rules including collection names and indexes
 */

const collections = {
  GREETINGS: 'lambda-ssp-greetings',
};

const schema = [
  {
    collection: collections.GREETINGS,
    indexes: [
      { key: 'greetings', options: { unique: true } },
    ],
  },
];

module.exports = {
  collections,
  schema,
};
