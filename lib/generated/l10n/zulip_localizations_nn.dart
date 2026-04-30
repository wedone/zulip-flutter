// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'zulip_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Nynorsk (`nn`).
class ZulipLocalizationsNn extends ZulipLocalizations {
  ZulipLocalizationsNn([String locale = 'nn']) : super(locale);

  @override
  String get aboutPageTitle => 'Om Zulip';

  @override
  String get aboutPageAppVersion => 'Appversjon';

  @override
  String get aboutPageOpenSourceLicenses => 'Lisensar for open kjeldekode';

  @override
  String get aboutPageTapToView => 'Tæpp for å sjå';

  @override
  String get upgradeWelcomeDialogTitle => 'Velkomen til den nye Zulip-appen!';

  @override
  String get upgradeWelcomeDialogMessage =>
      'Du finn eit kjent miljø i ei raskare og meir straumlineforma pakke.';

  @override
  String get upgradeWelcomeDialogLinkText => 'Sjekk kunngjeringsbloggposten!';

  @override
  String get upgradeWelcomeDialogDismiss => 'La oss starta';

  @override
  String get chooseAccountPageTitle => 'Vel konto';

  @override
  String get settingsPageTitle => 'Innstillingar';

  @override
  String get switchAccountButtonTooltip => 'Byt konto';

  @override
  String tryAnotherAccountMessage(Object url) {
    return 'Det tek ei stund å lasta inn kontoen din på $url.';
  }

  @override
  String get tryAnotherAccountButton => 'Prøv ein annan konto';

  @override
  String get chooseAccountPageLogOutButton => 'Logg ut';

  @override
  String get logOutConfirmationDialogTitle => 'Logg ut?';

  @override
  String get logOutConfirmationDialogMessage =>
      'For å nytta denne kontoen i framtida må du skriva inn URL-en for organisasjonen på nytt, i lag med kontoinformasjonen din.';

  @override
  String get logOutConfirmationDialogConfirmButton => 'Logg ut';

  @override
  String get chooseAccountButtonAddAnAccount => 'Legg til konto';

  @override
  String get navButtonAllChannels => 'Alle kanalar';

  @override
  String get allChannelsPageTitle => 'Alle kanalar';

  @override
  String get allChannelsEmptyPlaceholderHeader =>
      'Det finst ingen kanalar du kan sjå i denne organisasjonen.';

  @override
  String get profileButtonSendDirectMessage => 'Send direktemelding';

  @override
  String get errorCouldNotShowUserProfile => 'Kunne ikkje visa brukarprofil.';

  @override
  String get permissionsNeededTitle => 'Treng løyve';

  @override
  String get permissionsNeededOpenSettings => 'Opne innstillingane';

  @override
  String get permissionsDeniedCameraAccess =>
      'Gje Zulip ekstra løyve i Innstillingane for å lasta opp eit bilete.';

  @override
  String get permissionsDeniedReadExternalStorage =>
      'Gje Zulip ekstra løyve i Innstillingane for å lasta opp filer.';

  @override
  String get actionSheetOptionSubscribe => 'Abonner';

  @override
  String get subscribeFailedTitle => 'Kunne ikkje abonnera';

  @override
  String get actionSheetOptionMarkChannelAsRead => 'Merk kanalen som lesen';

  @override
  String get actionSheetOptionCopyChannelLink => 'Kopier lenke til kanal';

  @override
  String get actionSheetOptionListOfTopics => 'Liste over emne';

  @override
  String get actionSheetOptionChannelFeed => 'Kanalstraumen';

  @override
  String get actionSheetOptionUnsubscribe => 'Avabonner';

  @override
  String unsubscribeConfirmationDialogTitle(String channelName) {
    return 'Slutt å abonnera på $channelName?';
  }

  @override
  String get unsubscribeConfirmationDialogMessageCannotResubscribe =>
      'Når du går ut av denne kanalen kan du ikkje seinare bli med.';

  @override
  String get unsubscribeConfirmationDialogConfirmButton => 'Avabonner';

  @override
  String get unsubscribeFailedTitle => 'Kunne ikkje avslutta abonnementet';

  @override
  String get actionSheetOptionPinChannel => 'Fest til toppen';

  @override
  String get actionSheetOptionUnpinChannel => 'Løsne frå toppen';

  @override
  String get errorPinChannelFailedTitle => 'Kunne ikkje festa kanalen';

  @override
  String get errorUnpinChannelFailedTitle => 'Kunne ikkje løsna kanalen';

  @override
  String get actionSheetOptionMuteTopic => 'Demp emnet';

  @override
  String get actionSheetOptionUnmuteTopic => 'Avdemp emnet';

  @override
  String get actionSheetOptionFollowTopic => 'Fylg emnet';

  @override
  String get actionSheetOptionUnfollowTopic => 'Ikkje fylg emnet';

  @override
  String get actionSheetOptionResolveTopic => 'Merk som løyst';

  @override
  String get actionSheetOptionUnresolveTopic => 'Merk som uløyst';

  @override
  String get errorResolveTopicFailedTitle =>
      'Kunne ikkje merka emnet som løyst';

  @override
  String get errorUnresolveTopicFailedTitle =>
      'Kunne ikkje merka emnet som uløyst';

  @override
  String get actionSheetOptionSeeWhoReacted => 'Sjå kven som reagerte';

  @override
  String get seeWhoReactedSheetNoReactions =>
      'Denne meldinga har ingen reaksjonar.';

  @override
  String seeWhoReactedSheetHeaderLabel(int num) {
    return 'Emoji-reaksjonar ($num i alt)';
  }

  @override
  String seeWhoReactedSheetEmojiNameWithVoteCount(String emojiName, int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num røyster',
      one: '1 røyst',
    );
    return '$emojiName: $_temp0';
  }

  @override
  String seeWhoReactedSheetUserListLabel(String emojiName, int num) {
    return 'Røyster for $emojiName ($num)';
  }

  @override
  String get actionSheetOptionViewReadReceipts => 'Sjå lesekvitteringar';

  @override
  String get actionSheetReadReceipts => 'Lesekvitteringar';

  @override
  String actionSheetReadReceiptsReadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Denne meldinga har vorte <z-link>lesen</z-link> av $count personar:',
      one: 'Denne meldinga har vorte <z-link>lesen</z-link> av $count person:',
    );
    return '$_temp0';
  }

  @override
  String get actionSheetReadReceiptsZeroReadCount =>
      'Ingen har lese denne meldinga enno.';

  @override
  String get actionSheetReadReceiptsErrorReadCount =>
      'Kunne ikkje henta lesekvitteringane.';

  @override
  String get actionSheetOptionCopyMessageText => 'Kopier meldingstekst';

  @override
  String get actionSheetOptionCopyMessageLink => 'Kopier lenke til meldina';

  @override
  String get actionSheetOptionMarkAsUnread => 'Merk som ulese herifrå';

  @override
  String get actionSheetOptionHideMutedMessage => 'Gøym dempa melding på nytt';

  @override
  String get actionSheetOptionShare => 'Del';

  @override
  String get actionSheetOptionQuoteMessage => 'Siter meldinga';

  @override
  String get actionSheetOptionStarMessage => 'Stjernemerk meldinga';

  @override
  String get actionSheetOptionUnstarMessage => 'Fjern stjernemerkinga';

  @override
  String get actionSheetOptionEditMessage => 'Endre melding';

  @override
  String get actionSheetOptionDeleteMessage => 'Slett melding';

  @override
  String get deleteMessageConfirmationDialogTitle => 'Slett meldinga?';

  @override
  String get deleteMessageConfirmationDialogMessage =>
      'Når du slettar ei melding permanent forsvinn ho for alle.';

  @override
  String get deleteMessageConfirmationDialogConfirmButton => 'Slett';

  @override
  String get errorDeleteMessageFailedTitle => 'Kunne ikkje sletta meldinga';

  @override
  String get actionSheetOptionReportMessage => 'Meld melding';

  @override
  String get reportMessageDialogTitle => 'Meld meldinga';

  @override
  String get reportMessageDescription =>
      'Rapporten din vil bli sendt til den private kanalen for moderatorspørsmål for denne organisasjonen.';

  @override
  String get messageReportTypeSpam => 'Søppel';

  @override
  String get messageReportTypeHarassment => 'Trakassering';

  @override
  String get messageReportTypeInappropriate => 'Upassande innhald';

  @override
  String get messageReportTypeNorms => 'Bryt samfunnsnormene';

  @override
  String get messageReportTypeOther => 'Annan grunn';

  @override
  String get reportMessageReasonLabel => 'Kva er problemet med denne meldinga?';

  @override
  String get reportMessageDescriptionLabel => 'Kan du gje fleire detaljar?';

  @override
  String get reportMessageDescriptionRequired => 'Gje detaljar.';

  @override
  String get reportMessageSubmitButton => 'Send inn';

  @override
  String get reportMessageSuccess => 'Meldinga er meldt';

  @override
  String get errorReportMessageFailedTitle => 'Kunne ikkje rapportera meldinga';

  @override
  String get actionSheetOptionMarkTopicAsRead => 'Merk emnet som lese';

  @override
  String get actionSheetOptionCopyTopicLink => 'Kopier lenke til emnet';

  @override
  String actionSheetTitleDm(String user) {
    return 'DM-ar med $user';
  }

  @override
  String get actionSheetTitleSelfDm => 'DM-ar med deg sjølv';

  @override
  String get actionSheetTitleGroupDm => 'Gruppe-DM';

  @override
  String get actionSheetOptionViewProfile => 'Vis profil';

  @override
  String get actionSheetOptionMarkDmConversationAsRead =>
      'Merk samtalen som lesen';

  @override
  String get errorWebAuthOperationalErrorTitle => 'Noko gjekk gale';

  @override
  String get errorWebAuthOperationalError => 'Det hende noko uventa.';

  @override
  String get errorAccountLoggedInTitle => 'Kontoen er allereie innlogga';

  @override
  String errorAccountLoggedIn(String email, String server) {
    return 'Kontoen $email ved $server finst allereie i kontolista di.';
  }

  @override
  String get errorCouldNotFetchMessageSource =>
      'Kunne ikkje henta meldingskjelda.';

  @override
  String get errorCouldNotAccessUploadedFileTitle =>
      'Kunne ikkje få tak i opplasta fil';

  @override
  String get errorCopyingFailed => 'Kunne ikkje kopiera';

  @override
  String errorFailedToUploadFileTitle(String filename) {
    return 'Kunne ikkje lasta opp: $filename';
  }

  @override
  String filenameAndSizeInMiB(String filename, String size) {
    return '$filename: $size MiB';
  }

  @override
  String errorFilesTooLarge(
    int num,
    int maxFileUploadSizeMib,
    String listMessage,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num filene',
      one: 'Fila',
    );
    return '$_temp0 er større enn servergrensa på $maxFileUploadSizeMib MiB og vil ikkje bli lasta opp:\n\n$listMessage';
  }

  @override
  String errorFilesTooLargeTitle(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'Filene for store',
      one: 'Fila for stor',
    );
    return '$_temp0';
  }

  @override
  String get errorLoginInvalidInputTitle => 'Ugyldige inndata';

  @override
  String get errorLoginFailedTitle => 'Innlogginga feila';

  @override
  String get errorMessageNotSent => 'Meldinga ikkje send';

  @override
  String get errorMessageEditNotSaved => 'Meldinga ikkje lagra';

  @override
  String errorLoginCouldNotConnect(String url) {
    return 'Kunne ikkje kopla til server:\n$url';
  }

  @override
  String get errorCouldNotConnectTitle => 'Kunne ikkje kopla til';

  @override
  String get errorMessageDoesNotSeemToExist =>
      'Det ser ikkje ut til at meldinga finst.';

  @override
  String get errorQuotationFailed => 'Siteringa feila';

  @override
  String errorServerMessage(String message) {
    return 'Serveren sa:\n\n$message';
  }

  @override
  String get errorConnectingToServerShort =>
      'Feil når eg kopla til Zulip. Prøver på nytt…';

  @override
  String errorConnectingToServerDetails(String serverUrl, String error) {
    return 'Feil når eg kopla til Zulip på $serverUrl. Prøver på nytt:\n\n$error';
  }

  @override
  String get errorHandlingEventTitle =>
      'Feil når eg handsama Zulip-hending. Prøver koplinga på nytt…';

  @override
  String errorHandlingEventDetails(
    String serverUrl,
    String error,
    String event,
  ) {
    return 'Feil når eg handsama Zulip-hending frå $serverUrl; prøver på nytt.\n\nFeil: $error\n\nHending: $event';
  }

  @override
  String get errorCouldNotOpenLinkTitle => 'Kunne ikkje opna lenke';

  @override
  String errorCouldNotOpenLink(String url) {
    return 'Kunne ikkje opna lenka: $url';
  }

  @override
  String get errorMuteTopicFailed => 'Kunne ikkje dempa emnet';

  @override
  String get errorUnmuteTopicFailed => 'Kunne ikkje avdempa emnet';

  @override
  String get errorFollowTopicFailed => 'Kunne ikkje fylgja emnet';

  @override
  String get errorUnfollowTopicFailed => 'Kunne ikkje slutta å fylgja emnet';

  @override
  String get errorSharingFailed => 'Kunne ikkje dela';

  @override
  String get errorStarMessageFailedTitle => 'Kunne ikkje stjernemerka meldinga';

  @override
  String get errorUnstarMessageFailedTitle => 'Failed to unstar message';

  @override
  String get errorCouldNotEditMessageTitle => 'Could not edit message';

  @override
  String get successLinkCopied => 'Link copied';

  @override
  String get successMessageTextCopied => 'Message text copied';

  @override
  String get successMessageLinkCopied => 'Message link copied';

  @override
  String get successTopicLinkCopied => 'Topic link copied';

  @override
  String get successChannelLinkCopied => 'Channel link copied';

  @override
  String get composeBoxBannerLabelDeactivatedDmRecipient =>
      'You cannot send messages to deactivated users.';

  @override
  String get composeBoxBannerLabelUnknownDmRecipient =>
      'You cannot send messages to unknown users.';

  @override
  String get composeBoxBannerLabelCannotSendUnspecifiedReason =>
      'You cannot send messages here.';

  @override
  String get composeBoxBannerLabelCannotSendInChannel =>
      'You do not have permission to post in this channel.';

  @override
  String get composeBoxBannerLabelUnsubscribed =>
      'Replies to your messages will not appear automatically.';

  @override
  String get composeBoxBannerLabelUnsubscribedWhenCannotSend =>
      'New messages will not appear automatically.';

  @override
  String get composeBoxBannerButtonRefresh => 'Refresh';

  @override
  String get composeBoxBannerButtonSubscribe => 'Subscribe';

  @override
  String get composeBoxBannerLabelEditMessage => 'Edit message';

  @override
  String get composeBoxBannerButtonCancel => 'Cancel';

  @override
  String get composeBoxBannerButtonSave => 'Save';

  @override
  String get editAlreadyInProgressTitle => 'Cannot edit message';

  @override
  String get editAlreadyInProgressMessage =>
      'An edit is already in progress. Please wait for it to complete.';

  @override
  String get savingMessageEditLabel => 'SAVING EDIT…';

  @override
  String get savingMessageEditFailedLabel => 'EDIT NOT SAVED';

  @override
  String get discardDraftConfirmationDialogTitle =>
      'Discard the message you’re writing?';

  @override
  String get discardDraftForEditConfirmationDialogMessage =>
      'When you edit a message, the content that was previously in the compose box is discarded.';

  @override
  String get discardDraftForOutboxConfirmationDialogMessage =>
      'When you restore an unsent message, the content that was previously in the compose box is discarded.';

  @override
  String get discardDraftConfirmationDialogConfirmButton => 'Discard';

  @override
  String get composeBoxAttachFilesTooltip => 'Attach files';

  @override
  String get composeBoxAttachMediaTooltip => 'Attach images or videos';

  @override
  String get composeBoxAttachFromCameraTooltip => 'Take a photo';

  @override
  String get composeBoxGenericContentHint => 'Type a message';

  @override
  String get newDmSheetComposeButtonLabel => 'Compose';

  @override
  String get newDmSheetScreenTitle => 'New DM';

  @override
  String get newDmFabButtonLabel => 'New DM';

  @override
  String get newDmSheetSearchHintEmpty => 'Add one or more users';

  @override
  String get newDmSheetSearchHintSomeSelected => 'Add another user…';

  @override
  String get newDmSheetNoUsersFound => 'No users found';

  @override
  String composeBoxDmContentHint(String user) {
    return 'Message @$user';
  }

  @override
  String get composeBoxGroupDmContentHint => 'Message group';

  @override
  String get composeBoxSelfDmContentHint => 'Write yourself a note';

  @override
  String composeBoxChannelContentHint(String destination) {
    return 'Message $destination';
  }

  @override
  String get preparingEditMessageContentInput => 'Preparing…';

  @override
  String get composeBoxSendTooltip => 'Send';

  @override
  String get unknownChannelName => '(unknown channel)';

  @override
  String get composeBoxTopicHintText => 'Topic';

  @override
  String composeBoxEnterTopicOrSkipHintText(String defaultTopicName) {
    return 'Enter a topic (skip for “$defaultTopicName”)';
  }

  @override
  String composeBoxUploadingFilename(String filename) {
    return 'Uploading $filename…';
  }

  @override
  String composeBoxLoadingMessage(int messageId) {
    return '(loading message $messageId)';
  }

  @override
  String get unknownUserName => '(unknown user)';

  @override
  String get dmsWithYourselfPageTitle => 'DMs with yourself';

  @override
  String messageListGroupYouAndOthers(String others) {
    return 'You and $others';
  }

  @override
  String dmsWithOthersPageTitle(String others) {
    return 'DMs with $others';
  }

  @override
  String get emptyMessageList => 'There are no messages here.';

  @override
  String get emptyMessageListCombinedFeed =>
      'There are no messages in your combined feed.';

  @override
  String get emptyMessageListChannelWithoutContentAccess =>
      'You don’t have <z-link>content access</z-link> to this channel.';

  @override
  String get emptyMessageListChannelUnavailable =>
      'This channel doesn’t exist, or you are not allowed to view it.';

  @override
  String get emptyMessageListSelfDmHeader =>
      'You have not sent any direct messages to yourself yet!';

  @override
  String get emptyMessageListSelfDmMessage =>
      'Use this space for personal notes, or to test out Zulip features.';

  @override
  String emptyMessageListDm(String person) {
    return 'You have no direct messages with $person yet.';
  }

  @override
  String emptyMessageListDmDeactivatedUser(String person) {
    return 'You have no direct messages with $person.';
  }

  @override
  String get emptyMessageListDmUnknownUser =>
      'You have no direct messages with this user.';

  @override
  String get emptyMessageListGroupDm =>
      'You have no direct messages with these users yet.';

  @override
  String get emptyMessageListGroupDmDeactivatedUser =>
      'You have no direct messages with these users.';

  @override
  String get emptyMessageListDmStartConversation =>
      'Why not start the conversation?';

  @override
  String get emptyMessageListMentionsHeader =>
      'This view will show messages where you are <z-link>mentioned</z-link>.';

  @override
  String get emptyMessageListMentionsMessage =>
      'To call attention to a message, you can mention a user, a group, topic participants, or all subscribers to a channel. Type @ in the compose box, and choose who you’d like to mention from the list of suggestions.';

  @override
  String get emptyMessageListStarredHeader => 'You have no starred messages.';

  @override
  String emptyMessageListStarredMessage(String button) {
    return '<z-link>Starring</z-link> is a good way to keep track of important messages, such as tasks you need to go back to, or useful references. To star a message, long-press it and tap “$button.”';
  }

  @override
  String get emptyMessageListSearch => 'No search results.';

  @override
  String get messageListGroupYouWithYourself => 'Messages with yourself';

  @override
  String get contentValidationErrorTooLong =>
      'Message length shouldn\'t be greater than 10000 characters.';

  @override
  String get contentValidationErrorEmpty => 'You have nothing to send!';

  @override
  String get contentValidationErrorQuoteAndReplyInProgress =>
      'Please wait for the quotation to complete.';

  @override
  String get contentValidationErrorUploadInProgress =>
      'Please wait for the upload to complete.';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogContinue => 'Continue';

  @override
  String get dialogClose => 'Close';

  @override
  String get errorDialogLearnMore => 'Learn more';

  @override
  String get errorDialogContinue => 'OK';

  @override
  String get errorDialogTitle => 'Error';

  @override
  String get snackBarDetails => 'Details';

  @override
  String get lightboxCopyLinkTooltip => 'Copy link';

  @override
  String get lightboxVideoCurrentPosition => 'Current position';

  @override
  String get lightboxVideoDuration => 'Video duration';

  @override
  String get loginPageTitle => 'Log in';

  @override
  String get loginFormSubmitLabel => 'Log in';

  @override
  String get loginMethodDivider => 'OR';

  @override
  String get loginMethodDividerSemanticLabel => 'Log-in alternatives';

  @override
  String signInWithFoo(String method) {
    return 'Sign in with $method';
  }

  @override
  String get loginAddAnAccountPageTitle => 'Add an account';

  @override
  String get loginRealmUrlLabel => 'Your Zulip organization URL';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginErrorMissingEmail => 'Please enter your email.';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginErrorMissingPassword => 'Please enter your password.';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginErrorMissingUsername => 'Please enter your username.';

  @override
  String topicValidationErrorTooLong(int maxLength) {
    String _temp0 = intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: '$maxLength characters',
      one: '1 character',
    );
    return 'Topic length shouldn\'t be greater than $_temp0.';
  }

  @override
  String get topicValidationErrorMandatoryButEmpty =>
      'Topics are required in this organization.';

  @override
  String get errorContentNotInsertedTitle => 'Content not inserted';

  @override
  String get errorContentToInsertIsEmpty =>
      'The file to be inserted is empty or cannot be accessed.';

  @override
  String errorServerVersionNotAllowedMessage(
    String url,
    String zulipVersion,
    String minAllowedZulipVersion,
  ) {
    return '$url is running Zulip Server $zulipVersion, which is unsupported. The minimum supported version is Zulip Server $minAllowedZulipVersion.';
  }

  @override
  String serverCompatBannerAdminMessage(String url, String zulipVersion) {
    return '$url is running Zulip Server $zulipVersion, which is unsupported. Please upgrade your server as soon as possible.';
  }

  @override
  String serverCompatBannerUserMessage(String url, String zulipVersion) {
    return '$url is running Zulip Server $zulipVersion, which is unsupported. Please contact your server administrator about upgrading.';
  }

  @override
  String get serverCompatBannerDismissLabel => 'Dismiss';

  @override
  String get serverCompatBannerLearnMoreLabel => 'Learn more';

  @override
  String errorInvalidApiKeyMessage(String url) {
    return 'Your account at $url could not be authenticated. Please try logging in again or use another account.';
  }

  @override
  String get errorInvalidResponse => 'The server sent an invalid response.';

  @override
  String get errorNetworkRequestFailed => 'Network request failed';

  @override
  String errorMalformedResponse(int httpStatus) {
    return 'Server gave malformed response; HTTP status $httpStatus';
  }

  @override
  String errorMalformedResponseWithCause(int httpStatus, String details) {
    return 'Server gave malformed response; HTTP status $httpStatus; $details';
  }

  @override
  String errorRequestFailed(int httpStatus) {
    return 'Network request failed: HTTP status $httpStatus';
  }

  @override
  String get errorVideoPlayerFailed => 'Unable to play the video.';

  @override
  String get errorVideoPlayerFailedTryBrowser =>
      'Try opening it in your browser instead.';

  @override
  String get dialogOpenInBrowser => 'Open in browser';

  @override
  String get serverUrlValidationErrorEmpty => 'Please enter a URL.';

  @override
  String get serverUrlValidationErrorInvalidUrl => 'Please enter a valid URL.';

  @override
  String get serverUrlValidationErrorNoUseEmail =>
      'Please enter the server URL, not your email.';

  @override
  String get serverUrlValidationErrorUnsupportedScheme =>
      'The server URL must start with http:// or https://.';

  @override
  String get spoilerDefaultHeaderText => 'Spoiler';

  @override
  String get markAllAsReadLabel => 'Mark all messages as read';

  @override
  String markAsReadComplete(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num messages',
      one: '1 message',
    );
    return 'Marked $_temp0 as read.';
  }

  @override
  String get markAsReadInProgress => 'Marking messages as read…';

  @override
  String get errorMarkAsReadFailedTitle => 'Mark as read failed';

  @override
  String markAsUnreadComplete(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num messages',
      one: '1 message',
    );
    return 'Marked $_temp0 as unread.';
  }

  @override
  String get markAsUnreadInProgress => 'Marking messages as unread…';

  @override
  String get errorMarkAsUnreadFailedTitle => 'Mark as unread failed';

  @override
  String markAllAsReadConfirmationDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mark $count+ messages as read?',
      one: 'Mark $count+ messages as read?',
    );
    return '$_temp0';
  }

  @override
  String get markAllAsReadConfirmationDialogTitleNoCount =>
      'Mark messages as read?';

  @override
  String get markAllAsReadConfirmationDialogMessage =>
      'Messages in multiple conversations may be affected.';

  @override
  String get markAllAsReadConfirmationDialogConfirmButton => 'Mark as read';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get userActiveNow => 'Active now';

  @override
  String get userIdle => 'Idle';

  @override
  String userActiveMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Active $_temp0 ago';
  }

  @override
  String userActiveHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return 'Active $_temp0 ago';
  }

  @override
  String get userActiveYesterday => 'Active yesterday';

  @override
  String userActiveDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Active $_temp0 ago';
  }

  @override
  String userActiveDate(String date) {
    return 'Active $date';
  }

  @override
  String get userNotActiveInYear => 'Not active in the last year';

  @override
  String get invisibleMode => 'Invisible mode';

  @override
  String get turnOnInvisibleModeErrorTitle =>
      'Error turning on invisible mode. Please try again.';

  @override
  String get turnOffInvisibleModeErrorTitle =>
      'Error turning off invisible mode. Please try again.';

  @override
  String get userRoleOwner => 'Owner';

  @override
  String get userRoleAdministrator => 'Administrator';

  @override
  String get userRoleModerator => 'Moderator';

  @override
  String get userRoleMember => 'Member';

  @override
  String get userRoleGuest => 'Guest';

  @override
  String get userRoleUnknown => 'Unknown';

  @override
  String get statusButtonLabelStatusSet => 'Status';

  @override
  String get statusButtonLabelStatusUnset => 'Set status';

  @override
  String get noStatusText => 'No status text';

  @override
  String get setStatusPageTitle => 'Set status';

  @override
  String get statusClearButtonLabel => 'Clear';

  @override
  String get statusSaveButtonLabel => 'Save';

  @override
  String get statusTextHint => 'Your status';

  @override
  String get userStatusBusy => 'Busy';

  @override
  String get userStatusInAMeeting => 'In a meeting';

  @override
  String get userStatusCommuting => 'Commuting';

  @override
  String get userStatusOutSick => 'Out sick';

  @override
  String get userStatusVacationing => 'Vacationing';

  @override
  String get userStatusWorkingRemotely => 'Working remotely';

  @override
  String get userStatusAtTheOffice => 'At the office';

  @override
  String get updateStatusErrorTitle =>
      'Error updating user status. Please try again.';

  @override
  String get searchMessagesPageTitle => 'Search';

  @override
  String get searchMessagesHintText => 'Search';

  @override
  String get searchMessagesClearButtonTooltip => 'Clear';

  @override
  String get inboxPageTitle => 'Inbox';

  @override
  String get inboxEmptyPlaceholderHeader =>
      'There are no unread messages in your inbox.';

  @override
  String get inboxEmptyPlaceholderMessage =>
      'Use the buttons below to view the combined feed or list of channels.';

  @override
  String get pinnedChannelsFolderName => 'Pinned channels';

  @override
  String get otherChannelsFolderName => 'Other channels';

  @override
  String get recentDmConversationsPageTitle => 'Direct messages';

  @override
  String get recentDmConversationsPageShortLabel => 'DMs';

  @override
  String get recentDmConversationsSectionHeader => 'Direct messages';

  @override
  String get recentDmConversationsEmptyPlaceholderHeader =>
      'You have no direct messages yet!';

  @override
  String get recentDmConversationsEmptyPlaceholderMessage =>
      'Why not start a conversation?';

  @override
  String get combinedFeedPageTitle => 'Combined feed';

  @override
  String get mentionsPageTitle => 'Mentions';

  @override
  String get starredMessagesPageTitle => 'Starred messages';

  @override
  String get channelsPageTitle => 'Channels';

  @override
  String get channelsEmptyPlaceholderHeader =>
      'You’re not subscribed to any channels yet.';

  @override
  String channelsEmptyPlaceholderMessage(String allChannelsPageTitle) {
    return 'Try going to <z-link>$allChannelsPageTitle</z-link> and joining some of them.';
  }

  @override
  String get shareChooseAccountModalTitle => 'Choose an account';

  @override
  String get mainMenuMyProfile => 'My profile';

  @override
  String get topicsButtonTooltip => 'Topics';

  @override
  String get channelFeedButtonTooltip => 'Channel feed';

  @override
  String notifGroupDmConversationLabel(String senderFullName, int numOthers) {
    String _temp0 = intl.Intl.pluralLogic(
      numOthers,
      locale: localeName,
      other: '$numOthers others',
      one: '1 other',
    );
    return '$senderFullName to you and $_temp0';
  }

  @override
  String get pinnedSubscriptionsLabel => 'Pinned';

  @override
  String get unpinnedSubscriptionsLabel => 'Unpinned';

  @override
  String get notifSelfUser => 'You';

  @override
  String get reactedEmojiSelfUser => 'You';

  @override
  String get reactionChipsLabel => 'Reactions';

  @override
  String reactionChipLabel(String emojiName, String votes) {
    return '$emojiName: $votes';
  }

  @override
  String reactionChipVotesYouAndOthers(int otherUsersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      otherUsersCount,
      locale: localeName,
      other: 'You and $otherUsersCount others',
      one: 'You and 1 other',
    );
    return '$_temp0';
  }

  @override
  String onePersonTyping(String typist) {
    return '$typist is typing…';
  }

  @override
  String twoPeopleTyping(String typist, String otherTypist) {
    return '$typist and $otherTypist are typing…';
  }

  @override
  String get manyPeopleTyping => 'Several people are typing…';

  @override
  String get wildcardMentionAll => 'all';

  @override
  String get wildcardMentionEveryone => 'everyone';

  @override
  String get wildcardMentionChannel => 'channel';

  @override
  String get wildcardMentionStream => 'stream';

  @override
  String get wildcardMentionTopic => 'topic';

  @override
  String get wildcardMentionChannelDescription => 'Notify channel';

  @override
  String get wildcardMentionStreamDescription => 'Notify stream';

  @override
  String get wildcardMentionAllDmDescription => 'Notify recipients';

  @override
  String get wildcardMentionTopicDescription => 'Notify topic';

  @override
  String get systemGroupNameEveryoneOnInternet => 'Everyone on the internet';

  @override
  String get systemGroupNameEveryone => 'Everyone including guests';

  @override
  String get systemGroupNameMembers => 'Everyone except guests';

  @override
  String get systemGroupNameFullMembers => 'Full members';

  @override
  String get systemGroupNameModerators => 'Moderators';

  @override
  String get systemGroupNameAdministrators => 'Administrators';

  @override
  String get systemGroupNameOwners => 'Owners';

  @override
  String get systemGroupNameNobody => 'Nobody';

  @override
  String get navBarFeedLabel => 'Feed';

  @override
  String get navBarMenuLabel => 'Menu';

  @override
  String get messageIsEditedLabel => 'EDITED';

  @override
  String get messageIsMovedLabel => 'MOVED';

  @override
  String get messageNotSentLabel => 'MESSAGE NOT SENT';

  @override
  String pollVoterNames(String voterNames) {
    return '($voterNames)';
  }

  @override
  String get themeSettingTitle => 'THEME';

  @override
  String get themeSettingDark => 'Dark';

  @override
  String get themeSettingLight => 'Light';

  @override
  String get themeSettingSystem => 'System';

  @override
  String get openLinksWithInAppBrowser => 'Open links with in-app browser';

  @override
  String get pollWidgetQuestionMissing => 'No question.';

  @override
  String get pollWidgetOptionsMissing => 'This poll has no options yet.';

  @override
  String get initialAnchorSettingTitle => 'Open message feeds at';

  @override
  String get initialAnchorSettingDescription =>
      'You can choose whether message feeds open at your first unread message or at the newest messages.';

  @override
  String get initialAnchorSettingFirstUnreadAlways => 'First unread message';

  @override
  String get initialAnchorSettingFirstUnreadConversations =>
      'First unread message in conversation views, newest message elsewhere';

  @override
  String get initialAnchorSettingNewestAlways => 'Newest message';

  @override
  String get markReadOnScrollSettingTitle => 'Mark messages as read on scroll';

  @override
  String get markReadOnScrollSettingDescription =>
      'When scrolling through messages, should they automatically be marked as read?';

  @override
  String get markReadOnScrollSettingAlways => 'Always';

  @override
  String get markReadOnScrollSettingNever => 'Never';

  @override
  String get markReadOnScrollSettingConversations =>
      'Only in conversation views';

  @override
  String get markReadOnScrollSettingConversationsDescription =>
      'Messages will be automatically marked as read only when viewing a single topic or direct message conversation.';

  @override
  String get experimentalFeatureSettingsPageTitle => 'Experimental features';

  @override
  String get experimentalFeatureSettingsWarning =>
      'These options enable features which are still under development and not ready. They may not work, and may cause issues in other areas of the app.\n\nThe purpose of these settings is for experimentation by people working on developing Zulip.';

  @override
  String get errorNotificationOpenTitle => 'Failed to open notification';

  @override
  String get errorNotificationOpenAccountNotFound =>
      'The account associated with this notification could not be found.';

  @override
  String get errorReactionAddingFailedTitle => 'Adding reaction failed';

  @override
  String get errorReactionRemovingFailedTitle => 'Removing reaction failed';

  @override
  String get errorSharingTitle => 'Failed to share content';

  @override
  String get errorSharingAccountNotLoggedIn =>
      'There is no account logged in. Please log in to an account and try again.';

  @override
  String get emojiReactionsMore => 'more';

  @override
  String get emojiPickerSearchEmoji => 'Search emoji';

  @override
  String get noEarlierMessages => 'No earlier messages';

  @override
  String get revealButtonLabel => 'Reveal message';

  @override
  String get mutedUser => 'Muted user';

  @override
  String get scrollToBottomTooltip => 'Scroll to bottom';

  @override
  String get appVersionUnknownPlaceholder => '(…)';

  @override
  String get zulipAppTitle => 'Zulip';

  @override
  String get topicListEmptyPlaceholderHeader => 'There are no topics here yet.';
}
