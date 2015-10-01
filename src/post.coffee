request = require './exec'

module.exports = (baseUrl, song) ->
  request
    method: 'POST',
    url: baseUrl + '/songs',
    formData:
      artist: song.artist,
      title: song.title,
      file: fs.createReadStream(song.file)
