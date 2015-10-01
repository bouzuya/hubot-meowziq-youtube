fs = require 'fs'
exec = require './exec'

fetchMetaData = (url) ->
  exec "youtube-dl --dump-json '#{url}'"
  .then ({ stdout }) ->
    { uploader, title, ext } = JSON.parse stdout
    { title, ext, artist: uploader }

fetchAudioData = (url, path) ->
  exec "youtube-dl --extract-audio -o '#{path}' '#{url}'"

normalizeAudioData = (path) ->
  exec "aacgain -r -k -p -d 10.0 '#{path}'"

deleteAudioData = (file) ->
  new Promise (resolve, reject) ->
    fs.unlinkSync file, (err) ->
      return reject(err) if err?
      resolve()

module.exports = (url, proc) ->
  dir = './'
  timestamp = new Date().getTime()

  result =
    artist: null
    title: null
    file: null

  fetchMetaData url
  .then ({ title, ext, artist }) ->
    # console.log 'meta-data downloaded'
    # console.log 'Artist: ' + artist
    # console.log 'Title:  ' + title + ' ' + url
    result.artist = artist
    result.title = title
    fetchAudioData url, dir + timestamp + '.' + ext
  .then ->
    # console.log 'video-data downloaded'
    exts = ['.ogg', '.mp3', '.mp4', '.m4a', '.wav']
    ext = exts.filter((i) -> fs.existsSync dir + timestamp + i)[0]
    audioFile = dir + timestamp + ext
    # console.log audioFile
    result.artist = 'YouTube: ' + result.artist
    result.title = result.title + ' ' + url
    result.file = audioFile
  .then ->
    # console.log 'video-data converted'
    normalizeAudioData result.file
    .then (-> result), (-> result)
    .then proc
    .then (-> deleteAudioData(result.file)), (-> deleteAudioData(result.file))
