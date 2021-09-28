process.env.NODE_ENV = process.env.NODE_ENV || 'sandbox'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
