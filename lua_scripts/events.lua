module(..., package.seeall)

-- MK1212 Custom Events

FactionReligionConverted = {}
FactionUnvassalized = {}
FactionVassalized = {}
RegionResettled = {}
UnitDisbanded = {}

-- Event tables

AdviceDismissed = {}
AdviceFinishedTrigger = {}
AdviceIssued = {}
AdviceSuperseded = {}
AreaCameraEntered = {}
AreaEntered = {}
AreaExited = {}
ArmyBribeAttemptFailure = {}
ArmySabotageAttemptFailure = {}
ArmySabotageAttemptSuccess = {}
AssassinationAttemptCriticalSuccess = {}
AssassinationAttemptFailure = {}
AssassinationAttemptSuccess = {}
BattleBoardingActionCommenced = {}
BattleCommandingShipRouts = {}
BattleCommandingUnitRouts = {}
BattleCompleted = {}
BattleConflictPhaseCommenced = {}
BattleDeploymentPhaseCommenced = {}
BattleFortPlazaCaptureCommenced = {}
BattleShipAttacksEnemyShip = {}
BattleShipCaughtFire = {}
BattleShipMagazineExplosion = {}
BattleShipRouts = {}
BattleShipRunAground = {}
BattleShipSailingIntoWind = {}
BattleShipSurrendered = {}
BattleUnitAttacksBuilding = {}
BattleUnitAttacksEnemyUnit = {}
BattleUnitAttacksWalls = {}
BattleUnitCapturesBuilding = {}
BattleUnitDestroysBuilding = {}
BattleUnitRouts = {}
BattleUnitUsingBuilding = {}
BattleUnitUsingWall = {}
BuildingCardSelected = {}
BuildingCompleted = {}
BuildingConstructionIssuedByPlayer = {}
BuildingInfoPanelOpenedCampaign = {}
CameraMoverCancelled = {}
CameraMoverFinished = {}
CampaignArmiesMerge = {}
CampaignBuildingDamaged = {}
CampaignCoastalAssaultOnCharacter = {}
CampaignCoastalAssaultOnGarrison = {}
CampaignEffectsBundleAwarded = {}
CampaignSettlementAttacked = {}
CharacterAttacksAlly = {}
CharacterBecomesFactionLeader = {}
CharacterBesiegesSettlement = {}
CharacterBlockadedPort = {}
CharacterBrokePortBlockade = {}
CharacterBuildingCompleted = {}
CharacterCanLiberate = {}
CharacterCandidateBecomesMinister = {}
CharacterCharacterTargetAction = {}
CharacterComesOfAge = {}
CharacterCompletedBattle = {}
CharacterCreated = {}
CharacterDamagedByDisaster = {}
CharacterDeselected = {}
CharacterDiscovered = {}
CharacterDisembarksNavy = {}
CharacterEmbarksNavy = {}
CharacterEntersAttritionalArea = {}
CharacterEntersGarrison = {}
CharacterFactionCompletesResearch = {}
CharacterFamilyRelationDied = {}
CharacterGarrisonTargetAction = {}
CharacterInfoPanelOpened = {}
CharacterLeavesGarrison = {}
CharacterLootedSettlement = {}
CharacterMarriage = {}
CharacterMilitaryForceTraditionPointAllocated = {}
CharacterMilitaryForceTraditionPointAvailable = {}
CharacterParticipatedAsSecondaryGeneralInBattle = {}
CharacterPerformsActionAgainstFriendlyTarget = {}
CharacterPerformsOccupationDecisionLoot = {}
CharacterPerformsOccupationDecisionOccupy = {}
CharacterPerformsOccupationDecisionRaze = {}
CharacterPerformsOccupationDecisionResettle = {}
CharacterPerformsOccupationDecisionSack = {}
CharacterPostBattleEnslave = {}
CharacterPostBattleRelease = {}
CharacterPostBattleSlaughter = {}
CharacterPromoted = {}
CharacterRankUp = {}
CharacterRankUpNeedsAncillary = {}
CharacterRelativeKilled = {}
CharacterSelected = {}
CharacterSettlementBesieged = {}
CharacterSettlementBlockaded = {}
CharacterSkillPointAllocated = {}
CharacterSuccessfulArmyBribe = {}
CharacterSuccessfulConvert = {}
CharacterSuccessfulDemoralise = {}
CharacterSuccessfulInciteRevolt = {}
CharacterSurvivesAssassinationAttempt = {}
CharacterTurnEnd = {}
CharacterTurnStart = {}
CharacterWoundedInAssassinationAttempt = {}
ClanBecomesVassal = {}
ClimatePhaseChange = {}
ComponentCreated = {}
ComponentLClickUp = {}
ComponentLinkClicked = {}
ComponentMouseOn = {}
ComponentMoved = {}
ConvertAttemptFailure = {}
DemoraliseAttemptFailure = {}
DilemmaChoiceMadeEvent = {}
DilemmaEvent = {}
DilemmaIssuedEvent = {}
DillemaOrIncidentStarted = {}
DiplomacyNegotiationStarted = {}
DiplomaticOfferRejected = {}
DuelDemanded = {}
DummyEvent = {}
EncylopediaEntryRequested = {}
EventMessageOpenedBattle = {}
EventMessageOpenedCampaign = {}
FactionAboutToEndTurn = {}
FactionBecomesLiberationProtectorate = {}
FactionBecomesLiberationVassal = {}
FactionBecomesShogun = {}
FactionBecomesWorldLeader = {}
FactionBeginTurnPhaseNormal = {}
FactionCapturesKyoto = {}
FactionCapturesWorldCapital = {}
FactionEncountersOtherFaction = {}
FactionFameLevelUp = {}
FactionGovernmentTypeChanged = {}
FactionHordeStatusChange = {}
FactionLeaderDeclaresWar = {}
FactionLeaderSignsPeaceTreaty = {}
FactionRoundStart = {}
FactionSubjugatesOtherFaction = {}
FactionTurnEnd = {}
FactionTurnStart = {}
FirstTickAfterNewCampaignStarted = {}
FirstTickAfterWorldCreated = {}
ForceAdoptsStance = {}
FortSelected = {}
FrontendScreenTransition = {}
GarrisonAttackedEvent = {}
GarrisonOccupiedEvent = {}
GarrisonResidenceCaptured = {}
GovernorAssignedCharacterEvent = {}
GovernorshipTaxRateChanged = {}
HistoricBattleEvent = {}
HistoricalCharacters = {}
HistoricalEvents = {}
HudRefresh = {}
IncidentOccuredEvent = {}
InciteRevoltAttemptFailure = {}
IncomingMessage = {}
LandTradeRouteRaided = {}
LoadingGame = {}
LoadingScreenDismissed = {}
LocationEntered = {}
LocationUnveiled = {}
MPLobbyChatCreated = {}
MapIconMoved = {}
MissionCancelled = {}
MissionCheckAssassination = {}
MissionCheckBlockadePort = {}
MissionCheckBuild = {}
MissionCheckCaptureCity = {}
MissionCheckDuel = {}
MissionCheckEngageCharacter = {}
MissionCheckEngageFaction = {}
MissionCheckGainMilitaryAccess = {}
MissionCheckMakeAlliance = {}
MissionCheckMakeTradeAgreement = {}
MissionCheckRecruit = {}
MissionCheckResearch = {}
MissionCheckSpyOnCity = {}
MissionEvaluateAssassination = {}
MissionEvaluateBlockadePort = {}
MissionEvaluateBuild = {}
MissionEvaluateCaptureCity = {}
MissionEvaluateDuel = {}
MissionEvaluateEngageCharacter = {}
MissionEvaluateEngageFaction = {}
MissionEvaluateGainMilitaryAccess = {}
MissionEvaluateMakeAlliance = {}
MissionEvaluateMakeTradeAgreement = {}
MissionEvaluateRecruit = {}
MissionEvaluateResearch = {}
MissionEvaluateSpyOnCity = {}
MissionFailed = {}
MissionIssued = {}
MissionNearingExpiry = {}
MissionSucceeded = {}
ModelCreated = {}
MovementPointsExhausted = {}
MultiTurnMove = {}
NewCampaignStarted = {}
NewSession = {}
PanelAdviceRequestedBattle = {}
PanelAdviceRequestedCampaign = {}
PanelClosedBattle = {}
PanelClosedCampaign = {}
PanelOpenedBattle = {}
PanelOpenedCampaign = {}
PendingBankruptcy = {}
PendingBattle = {}
PositiveDiplomaticEvent = {}
PreBattle = {}
RecruitmentItemIssuedByPlayer = {}
RegionGainedDevlopmentPoint = {}
RegionIssuesDemands = {}
RegionRebels = {}
RegionRiots = {}
RegionSelected = {}
RegionStrikes = {}
RegionTurnEnd = {}
RegionTurnStart = {}
ResearchCompleted = {}
ResearchStarted = {}
SabotageAttemptFailure = {}
SabotageAttemptSuccess = {}
SavingGame = {}
ScriptedAgentCreated = {}
ScriptedAgentCreationFailed = {}
ScriptedCharacterUnhidden = {}
ScriptedCharacterUnhiddenFailed = {}
ScriptedForceCreated = {}
SeaTradeRouteRaided = {}
SettlementDeselected = {}
SettlementOccupied = {}
SettlementSelected = {}
ShortcutTriggered = {}
SiegeLifted = {}
SlotOpens = {}
SlotRoundStart = {}
SlotSelected = {}
SlotTurnStart = {}
StartRegionPopupVisible = {}
StartRegionSelected = {}
TechnologyInfoPanelOpenedCampaign = {}
TestEvent = {}
TimeTrigger = {}
TooltipAdvice = {}
TradeLinkEstablished = {}
TradeNodeConnected = {}
TradeRouteEstablished = {}
UICreated = {}
UIDestroyed = {}
UngarrisonedFort = {}
UnitCompletedBattle = {}
UnitCreated = {}
UnitDisembarkCompleted = {}
UnitSelectedCampaign = {}
UnitTrained = {}
UnitTurnEnd = {}
VictoryConditionFailed = {}
VictoryConditionMet = {}
WorldCreated = {}
historical_events = {}
