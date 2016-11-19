angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, $window, $timeout, $mdMedia, Records, MessageChannelService, KeyEventService, ModalService, ScrollService, AbilityService, Session, PaginationService, LmoUrlService, TranslationService, ProposalOutcomeForm) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage'})

  @windowIsLarge = $mdMedia('gt-sm')

  @performScroll = ->
    ScrollService.scrollTo @elementToFocus(), 150
    $rootScope.$broadcast 'triggerVoteForm', $location.search().position if @openVoteModal()
    (ModalService.open ProposalOutcomeForm, proposal: => @proposal) if @openOutcomeModal()
    $location.url($location.path())

  @openVoteModal = ->
    $location.search().position and
    @discussion.hasActiveProposal() and
    @discussion.activeProposal().key == ($routeParams.proposal or $location.search().proposal or $routeParams.proposal) and
    AbilityService.canVoteOn(@discussion.activeProposal())

  @openOutcomeModal = ->
    AbilityService.canCreateOutcomeFor(@proposal) and
    $routeParams.outcome? and
    (delete $routeParams.outcome)

  @elementToFocus = ->
    if @proposal
      "#proposal-#{@proposal.key}"
    else if @comment
      "#comment-#{@comment.id}"
    else if Records.events.findByDiscussionAndSequenceId(@discussion, @sequenceIdToFocus)
      '.activity-card__last-read-activity'
    else
      '.context-panel'

  $scope.$on 'threadPageEventsLoaded', (e, event) =>
    $window.location.reload() if @discussion.requireReloadFor(event)
    requestedCommentId = parseInt($routeParams.comment or $location.search().comment)
    @comment = Records.comments.find(requestedCommentId) unless isNaN(requestedCommentId)
    @performScroll() if @proposalsLoaded or !@discussion.anyClosedProposals()
    @eventsLoaded = true

  $scope.$on 'threadPageProposalsLoaded', (event) =>
    requestedProposalKey = $routeParams.proposal or $location.search().proposal
    @proposal = Records.proposals.find(requestedProposalKey)
    $rootScope.$broadcast 'setSelectedProposal', @proposal
    @performScroll() if @eventsLoaded
    @proposalsLoaded = true

  @canStartProposal = ->
    AbilityService.canStartProposal(@discussion)

  @proposalInView = ($inview) ->
    $rootScope.$broadcast 'proposalInView', $inview

  @proposalButtonInView = ($inview) ->
    $rootScope.$broadcast 'proposalButtonInView', $inview

  TranslationService.listenForTranslations($scope, @)

  checkInView = ->
    angular.element(window).triggerHandler('checkInView')

  KeyEventService.registerKeyEvent $scope, 'pressedUpArrow', checkInView
  KeyEventService.registerKeyEvent $scope, 'pressedDownArrow', checkInView

  Records.discussions.findOrFetchById($routeParams.key).then (discussion) =>
    return unless discussion
    @discussion = discussion
    @sequenceIdToFocus = parseInt($location.search().from or @discussion.lastReadSequenceId)
    @pageWindow = PaginationService.windowFor
      current:  @sequenceIdToFocus
      min:      @discussion.firstSequenceId
      max:      @discussion.lastSequenceId
      pageType: 'activityItems'

    $rootScope.$broadcast 'viewingThread', @discussion
    $rootScope.$broadcast 'setTitle', @discussion.title
    $rootScope.$broadcast 'analyticsSetGroup', @discussion.group()
    $rootScope.$broadcast 'currentComponent',
      page: 'threadPage'
      group: @discussion.group()
      links:
        canonical:   LmoUrlService.discussion(@discussion, {}, absolute: true)
        rss:         LmoUrlService.discussion(@discussion) + '.xml' if !@discussion.private
        prev:        LmoUrlService.discussion(@discussion, from: @pageWindow.prev) if @pageWindow.prev?
        next:        LmoUrlService.discussion(@discussion, from: @pageWindow.next) if @pageWindow.next?
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  return
