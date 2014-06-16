$ ->
  # templateの準備
  source = $('#template').html()
  template = Handlebars.compile source

  # module,DBの準備
  async = require 'async'
  Datastore = require 'nedb'
  db = new Datastore
    filename: './city.db'
    autoload: true

  # DBから保存済場所の取得
  findCity = (query, cb) ->
    db.find query, (err, result) ->
      cb err, result
      return
    return

  # DBに場所を保存
  insertCity = (name, cb) ->
    data =
      name: name
      date: new Date()
    db.insert data, (err, result) ->
      cb err, result
      return
    return

  # DBから場所を削除
  removeCity = (_id, cb) ->
    query =
      _id: _id
    db.remove query, {}, (err, result) ->
      cb err, result
      return
    return

  # 現在の天気の取得
  getWeather = (name, cb) ->
    url = 'http://api.openweathermap.org/data/2.5/weather?'
    data =
      q: name
    $.ajax
      type: 'GET'
      url: url
      data: data
    .done (data, textStatus, jqXHR) ->
      cb null, data
      return
    .fail (jqXHR, textStatus, errorThrown) ->
      cb errorThrown, null
      return
    return

  # 画面初期描画処理
  reloadWeather = () ->
    async.waterfall [
      (cb) ->
        findCity {}, (err, result)->
          if err 
            cb err
          else if result.length is 0 or !result
            cb result
          else
            cb null, result
          return
        return
      (cities, cb) ->
        $('#list').empty()
        async.each cities, (city, cb) ->
          getWeather city.name, (error, data) ->
            if error
              $('body').html error
            else
              $('#list').append template
                  id: city._id
                  icon: "http://openweathermap.org/img/w/#{data.weather[0].icon}.png"
                  name: data.name
                  country: data.sys.country
                  temp: "#{(data.main.temp - 273.15 + '').split('.')[0]}℃"
                  description: data.weather[0].description
            cb()
            return
          return
        cb()
        return
    ], (err) ->
      if err
        console.log err
      return
    return

  # 場所登録ボタン処理
  $('#add').click ->
    name = $('#input').val()
    if name
      async.waterfall [
        (cb) ->
          getWeather name, (err, data) ->
            if err
              cb err
            else
              cb null, data
            return
          return
        (data, cb) ->
          insertCity name, (err, city) ->
            if err
              cb err
            else
              cb null, data, city
            return
          return
        (data, city, cb) ->
          $('#list').append template
            id: city._id
            icon: "http://openweathermap.org/img/w/#{data.weather[0].icon}.png"
            name: data.name
            country: data.sys.country
            temp: "#{(data.main.temp - 273.15 + '').split('.')[0]}℃"
            description: data.weather[0].description
          return
          cb()
      ], (err) ->
        if err
          console.log err
        return
    return

  # 場所登録フォームでエンター操作
  $('#input').keydown (e) ->
    if e.keyCode is 13
      $('#add').click()
    return

  # removeボタンのクリック
  $(document).on 'click', '.remove', ->
    _id = $(@).data 'id'
    parent = $(@).parent()
    removeCity _id, (err, result) ->
      if result is 1
        $(parent).remove()
      return
    return

  # 自動更新
  setInterval ()->
    reloadWeather()
    return
  , 1000 * 60 * 15
  reloadWeather()

  return
