request = require 'request'
parser  = require './parser'

gid_provided = (params) ->
  'name' not of params

gatherer_url = 'http://gatherer.wizards.com/Pages/'

build_card_url = (params) ->
  url = gatherer_url + 'Card/Details.aspx'
  if gid_provided params
    [id, part] = params
    url += '?multiverseid=' + id
    url += '&part=' + encodeURIComponent part if part
  else
    url += '?name=' + encodeURIComponent params.name
  url

build_set_url = (name, page) ->
  gatherer_url +
  'Search/Default.aspx?set=[%22' +
  encodeURIComponent(name) +
  '%22]&page=' +
  (page - 1)

exports.fetch_card = (params, callback) ->
  url = build_card_url(params)
  request {url, followRedirect: no}, (error, response, body) ->
    if error or (status = response.statusCode) isnt 200
      # Gatherer does a 302 redirect if the requested id does not exist.
      # In such cases, we respond with the more appropriate status code.
      callback error, {error, status}
      return
    parser.card body, {gid_attributes: gid_provided(params), url}, callback
  return

exports.fetch_set = (params, callback) ->
  page = +(params.page ? 1)
  url = build_set_url(params.name, page)
  request {url}, (error, response, body) ->
    parser.set body, {page}, callback
  return