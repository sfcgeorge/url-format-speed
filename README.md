# Minimal Reproduction of URL format slowdown Rails bug

If you load a JS view using the Accept header only (aka as an AJAX/UJS request) there is a mysterious ~10x slowdown. But if you add .js to the URL the speed is what you'd expect (with or without Accept header).


## Very minimal repro

Check `TestsController#test_nothing` for a basic view, nothing dynamic, no nested partials. The slowdown is present but not so drastic.

### Tortastic 🐢

```sh
curl 'http://localhost:3000/test_nothing' -H 'Accept: */*;q=0.5, text/javascript, application/javascript, application/ecmascript, application/x-ecmascript'
```

```log
Started GET "/test_nothing" for 127.0.0.1 at 2017-09-01 16:35:33 +0100
Processing by TestsController#test_nothing as JS
  Rendering tests/test_nothing.js.erb
  Rendered tests/test_nothing.js.erb (0.3ms)
Completed 200 OK in 30ms (Views: 17.1ms)
```

### Usual Rails speed 🐇

Note the .js on the URL - this is all that's changed yet the perf issue goes away.

```sh
curl 'http://localhost:3000/test_nothing.js' -H 'Accept: */*;q=0.5, text/javascript, application/javascript, application/ecmascript, application/x-ecmascript'
```

```log
Started GET "/test_nothing.js" for 127.0.0.1 at 2017-09-01 16:36:44 +0100
Processing by TestsController#test_nothing as JS
  Rendering tests/test_nothing.js.erb
  Rendered tests/test_nothing.js.erb (0.3ms)
Completed 200 OK in 7ms (Views: 5.1ms)
```


## Quite drastic repro

Check `TestsController#test_nested` for a view with nested partial in a loop to really demonstrate the issue. There appears to be a 10x delay for every partial rendered beyond the time Rails reports (you can see the partials don't appear to take any longer in the slow case, but they don't add up as the overall view takes way longer).

### Hella slow 🛴

```sh
curl 'http://localhost:3000/test_nested' -H 'Accept: */*;q=0.5, text/javascript, application/javascript, application/ecmascript, application/x-ecmascript'
```

```log
Started GET "/test_nested" for 127.0.0.1 at 2017-09-01 16:38:23 +0100
Processing by TestsController#test_nested as JS
  Rendering tests/test_nested.js.erb
  Rendered tests/_partial.html.erb (0.3ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.1ms)
  Rendered tests/_partial.html.erb (0.8ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.1ms)
  Rendered tests/_partial.html.erb (0.1ms)
  Rendered tests/test_nested.js.erb (129.4ms)
Completed 200 OK in 160ms (Views: 145.3ms)
```

### Hella acceptable 🛵

```sh
curl 'http://localhost:3000/test_nested.js' -H 'Accept: */*;q=0.5, text/javascript, application/javascript, application/ecmascript, application/x-ecmascript'
```

```log
Started GET "/test_nested.js" for 127.0.0.1 at 2017-09-01 16:39:11 +0100
Processing by TestsController#test_nested as JS
  Rendering tests/test_nested.js.erb
  Rendered tests/_partial.html.erb (0.3ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.0ms)
  Rendered tests/_partial.html.erb (0.1ms)
  Rendered tests/test_nested.js.erb (17.2ms)
Completed 200 OK in 24ms (Views: 22.0ms)
```
