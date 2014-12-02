# Put here Angular.js configuration
# Angular.js variable
# Load ngResource in the app to query Rails controllers
@app = angular.module("Pantry", ["ngResource", "textFilters"])

# Making it work with CSRF protection
@app.config ['$httpProvider', ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]

