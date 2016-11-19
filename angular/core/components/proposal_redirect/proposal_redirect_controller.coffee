angular.module('loomioApp').controller 'ProposalRedirectController', ($timeout, $rootScope, $routeParams, $location, Records, LmoUrlService) ->
  $rootScope.$broadcast('currentComponent', 'proposalRedirect')

  errorCallback = (error) ->
    $rootScope.$broadcast 'pageError', error

  Records.proposals.findOrFetchById($routeParams.key).then (proposal) =>
    Records.discussions.findOrFetchById(proposal.discussionId).then (discussion) =>
      $timeout ->
        $location.path LmoUrlService.proposal Records.proposals.find($routeParams.key),
          position: $location.search().position
    , errorCallback
  , errorCallback

  return
