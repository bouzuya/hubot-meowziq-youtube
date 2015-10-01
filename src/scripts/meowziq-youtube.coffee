# Description
#   A Hubot script
#
# Configuration:
#   HUBOT_MEOWZIQ_YOUTUBE_BASE_URL
#
# Commands:
#   hubot meowziq youtube <url or id> - send youtube video to meowziq
#
# Author:
#   bouzuya <m@bouzuya.net>
#

fetch = require '../fetch'
post = require '../post'

module.exports = (robot) ->
  baseUrl = process.env.HUBOT_MEOWZIQ_YOUTUBE_BASE_URL

  robot.respond /meowziq.youtube (.+)$/, (res) ->
    u = res.match[1]
    u = if u.match /^www\.youtube\.com/ then 'https://' + u else u
    u = if u.match /^https?:/ then u else 'https://www.youtube.com/watch?v=' + u
    fetch u, (song) ->
      post baseUrl, song
    .then ->
      res.send 'OK'
    .catch (e) ->
      robot.logger.error e
      res.send 'ERROR'
