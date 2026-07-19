classDiagram
class App
App : +build() Widget
StatelessWidget <|-- App

class AppNavigationBar
AppNavigationBar : +createState() State<AppNavigationBar>
StatefulWidget <|-- AppNavigationBar

class _AppNavigationBarState
_AppNavigationBarState : +selectedIndex int
_AppNavigationBarState : +pages List~Widget~
_AppNavigationBarState : +appBarTitle List~String?~
_AppNavigationBarState : +build() Widget
State <|-- _AppNavigationBarState

class AppSpacingStyle
AppSpacingStyle : +paddingWithAppBarHeight$ EdgeInsetsGeometry
AppSpacingStyle o-- EdgeInsetsGeometry

class Env
<<abstract>> Env
Env : +hf_apiKey$ String

class _Env
_Env : -_enviedkeyhf_apiKey$ List~int~
_Env : -_envieddatahf_apiKey$ List~int~
_Env : +hf_apiKey$ String

class AuthController
AuthController : +deviceStorage GetStorage
AuthController o-- GetStorage
AuthController : -_auth FirebaseAuth
AuthController o-- FirebaseAuth
AuthController : -_googleSignIn GoogleSignIn
AuthController o-- GoogleSignIn
AuthController : +instance$ AuthController
AuthController o-- AuthController
AuthController : +onReady() void
AuthController : +screenRedirect() void
AuthController : +loginWithEmailAndPassword() dynamic
AuthController : +registerWithEmailAndPassword() dynamic
AuthController : +forgotPassword() dynamic
AuthController : +signInWithGoogle() dynamic
GetxController <|-- AuthController

class ForgotPasswordController
ForgotPasswordController : +email TextEditingController
ForgotPasswordController o-- TextEditingController
ForgotPasswordController : +forgotPasswordFormKey GlobalKey~FormState~
ForgotPasswordController o-- GlobalKey~FormState~
ForgotPasswordController : +instance$ ForgotPasswordController
ForgotPasswordController o-- ForgotPasswordController
ForgotPasswordController : +sendPasswordResetEmail() dynamic
GetxController <|-- ForgotPasswordController

class LoginController
LoginController : +hidePassword RxBool
LoginController o-- RxBool
LoginController : +rememberMe RxBool
LoginController o-- RxBool
LoginController : +email TextEditingController
LoginController o-- TextEditingController
LoginController : +password TextEditingController
LoginController o-- TextEditingController
LoginController : +loginFormKey GlobalKey~FormState~
LoginController o-- GlobalKey~FormState~
LoginController : +localStorage GetStorage
LoginController o-- GetStorage
LoginController : +userRepository UserRepository
LoginController o-- UserRepository
LoginController : +userController UserController
LoginController o-- UserController
LoginController : +mealHistoryController MealHistoryController
LoginController o-- MealHistoryController
LoginController : +signIn() dynamic
LoginController : +googleSignIn() dynamic
GetxController <|-- LoginController

class OnboardingController
OnboardingController : +pageController PageController
OnboardingController o-- PageController
OnboardingController : +currentPageIndex Rx~int~
OnboardingController o-- Rx~int~
OnboardingController : +physicalMetricsFormKey GlobalKey~FormState~
OnboardingController o-- GlobalKey~FormState~
OnboardingController : +heightController TextEditingController
OnboardingController o-- TextEditingController
OnboardingController : +weightController TextEditingController
OnboardingController o-- TextEditingController
OnboardingController : +ageController TextEditingController
OnboardingController o-- TextEditingController
OnboardingController : +activityLevel RxString
OnboardingController o-- RxString
OnboardingController : +selectedDietaryPreferences RxSet~String~
OnboardingController o-- RxSet~String~
OnboardingController : +selectedHealthGoals RxSet~String~
OnboardingController o-- RxSet~String~
OnboardingController : +selectedNutritionalFocus RxSet~String~
OnboardingController o-- RxSet~String~
OnboardingController : +selectedRestrictions RxList~String~
OnboardingController o-- RxList~String~
OnboardingController : +customRestrictionController TextEditingController
OnboardingController o-- TextEditingController
OnboardingController : +dietaryPreferences List~String~
OnboardingController : +healthGoals List~String~
OnboardingController : +nutritionalFocus List~String~
OnboardingController : +dietaryRestrictions List~String~
OnboardingController : +activityLevels List~Map~String, String~~
OnboardingController : +instance$ OnboardingController
OnboardingController o-- OnboardingController
OnboardingController : +updatePageIndicator() void
OnboardingController : +dotNavigationClick() void
OnboardingController : +nextPage() void
OnboardingController : +previousPage() void
OnboardingController : +toggleDietaryPreferences() void
OnboardingController : +toggleHealthGoals() void
OnboardingController : +toggleNutritionalFocus() void
OnboardingController : +toggleRestriction() void
OnboardingController : +addCustomRestriction() void
OnboardingController : +removeRestriction() void
OnboardingController : +saveOnboardingDetails() dynamic
OnboardingController : +onClose() void
GetxController <|-- OnboardingController

class SignupController
SignupController : +hidePassword RxBool
SignupController o-- RxBool
SignupController : +username TextEditingController
SignupController o-- TextEditingController
SignupController : +email TextEditingController
SignupController o-- TextEditingController
SignupController : +password TextEditingController
SignupController o-- TextEditingController
SignupController : +confirmPassword TextEditingController
SignupController o-- TextEditingController
SignupController : +signupFormKey GlobalKey~FormState~
SignupController o-- GlobalKey~FormState~
SignupController : +signup() dynamic
GetxController <|-- SignupController

class CameraScreenController
CameraScreenController : +cameraController CameraController
CameraScreenController o-- CameraController
CameraScreenController : +initializeControllerFuture dynamic
CameraScreenController : +initCamera() dynamic
CameraScreenController : +uploadCameraImage() dynamic

class ImageAnalysisController
ImageAnalysisController : +gemini GeminiController
ImageAnalysisController o-- GeminiController
ImageAnalysisController : +sentimentAnalysis SentimentAnalysis
ImageAnalysisController o-- SentimentAnalysis
ImageAnalysisController : +response RxString
ImageAnalysisController o-- RxString
ImageAnalysisController : +imageUrl RxString
ImageAnalysisController o-- RxString
ImageAnalysisController : +errorMessage Rxn~String~
ImageAnalysisController o-- Rxn~String~
ImageAnalysisController : +isLoading RxBool
ImageAnalysisController o-- RxBool
ImageAnalysisController : +picker ImagePicker
ImageAnalysisController o-- ImagePicker
ImageAnalysisController : +foodImage Rxn~XFile~
ImageAnalysisController o-- Rxn~XFile~
ImageAnalysisController : -_db FirebaseFirestore
ImageAnalysisController o-- FirebaseFirestore
ImageAnalysisController : -_auth FirebaseAuth
ImageAnalysisController o-- FirebaseAuth
ImageAnalysisController : +deviceStorage GetStorage
ImageAnalysisController o-- GetStorage
ImageAnalysisController : +originalMealName String
ImageAnalysisController : +originalCarbsCount String
ImageAnalysisController : +originalProteinCount String
ImageAnalysisController : +originalFatsCount String
ImageAnalysisController : +originalCategory String
ImageAnalysisController : +userTextInput String
ImageAnalysisController : +mealNameController TextEditingController
ImageAnalysisController o-- TextEditingController
ImageAnalysisController : +sentimentController TextEditingController
ImageAnalysisController o-- TextEditingController
ImageAnalysisController : -_hasSetMealName bool
ImageAnalysisController : -_hasSetCarbs bool
ImageAnalysisController : -_hasSetProtein bool
ImageAnalysisController : -_hasSetFats bool
ImageAnalysisController : -_hasSetCategory bool
ImageAnalysisController : +carbsMacro RxString
ImageAnalysisController o-- RxString
ImageAnalysisController : +proteinMacro RxString
ImageAnalysisController o-- RxString
ImageAnalysisController : +fatMacro RxString
ImageAnalysisController o-- RxString
ImageAnalysisController : +category RxString
ImageAnalysisController o-- RxString
ImageAnalysisController : +briefSummary RxString
ImageAnalysisController o-- RxString
ImageAnalysisController : +ingredients RxList~String~
ImageAnalysisController o-- RxList~String~
ImageAnalysisController : +isSummaryLoading RxBool
ImageAnalysisController o-- RxBool
ImageAnalysisController : +macroOptions List~String~
ImageAnalysisController : +categoryOptions List~String~
ImageAnalysisController : +uploadImage() dynamic
ImageAnalysisController : +validateImage() dynamic
ImageAnalysisController : +deleteImage() dynamic
ImageAnalysisController : +pickImage() dynamic
ImageAnalysisController : +analyseFoodImage() dynamic
ImageAnalysisController : +analyseFoodText() dynamic
ImageAnalysisController : +regenerateMealSummary() dynamic
ImageAnalysisController : +saveMealRecord() dynamic

class IndividualMealController
IndividualMealController : -_db FirebaseFirestore
IndividualMealController o-- FirebaseFirestore
IndividualMealController : -_auth FirebaseAuth
IndividualMealController o-- FirebaseAuth
IndividualMealController : +repo ImageAnalysisController
IndividualMealController o-- ImageAnalysisController
IndividualMealController : +instance$ IndividualMealController
IndividualMealController o-- IndividualMealController
IndividualMealController : +user User?
IndividualMealController o-- User
IndividualMealController : +getIndividualMeal() dynamic
IndividualMealController : +deleteMeal() dynamic
GetxController <|-- IndividualMealController

class MealHistoryController
MealHistoryController : +imageAnalysisController ImageAnalysisController
MealHistoryController o-- ImageAnalysisController
MealHistoryController : -_auth FirebaseAuth
MealHistoryController o-- FirebaseAuth
MealHistoryController : -_db FirebaseFirestore
MealHistoryController o-- FirebaseFirestore
MealHistoryController : +instance$ MealHistoryController
MealHistoryController o-- MealHistoryController
MealHistoryController : +displayCurrentUserMeals() Stream<QuerySnapshot<Map<String, dynamic>>>
MealHistoryController : +deleteAllMeals() dynamic
GetxController <|-- MealHistoryController

class MealRecommendationController
MealRecommendationController : +userProfile UserProfileController
MealRecommendationController o-- UserProfileController
MealRecommendationController : -_db FirebaseFirestore
MealRecommendationController o-- FirebaseFirestore
MealRecommendationController : -_auth FirebaseAuth
MealRecommendationController o-- FirebaseAuth
MealRecommendationController : +todayMeals List~Map~String, dynamic~~
MealRecommendationController : +isLoading RxBool
MealRecommendationController o-- RxBool
MealRecommendationController : +gemini GeminiController
MealRecommendationController o-- GeminiController
MealRecommendationController : +response RxString
MealRecommendationController o-- RxString
MealRecommendationController : +preferredCategories RxList~String~
MealRecommendationController o-- RxList~String~
MealRecommendationController : +avoidCategories RxList~String~
MealRecommendationController o-- RxList~String~
MealRecommendationController : +selectedMealType RxString
MealRecommendationController o-- RxString
MealRecommendationController : +selectedMealCuisine RxString
MealRecommendationController o-- RxString
MealRecommendationController : +instance$ MealRecommendationController
MealRecommendationController o-- MealRecommendationController
MealRecommendationController : +onInit() void
MealRecommendationController : +autoSelectMealType() void
MealRecommendationController : +displayTodayMeals() dynamic
MealRecommendationController : +userMealPreferences() dynamic
MealRecommendationController : +generateMealRecs() dynamic
MealRecommendationController : +saveMealRecommendations() dynamic
GetxController <|-- MealRecommendationController

class MealRecommendationHistoryController
MealRecommendationHistoryController : +instance$ MealRecommendationHistoryController
MealRecommendationHistoryController o-- MealRecommendationHistoryController
MealRecommendationHistoryController : +getRecommendations() Stream<QuerySnapshot<Map<String, dynamic>>>
GetxController <|-- MealRecommendationHistoryController

class MealTextInputController
MealTextInputController : +gemini GeminiController
MealTextInputController o-- GeminiController
MealTextInputController : +sentimentAnalysis SentimentAnalysis
MealTextInputController o-- SentimentAnalysis
MealTextInputController : +mealDetailsController TextEditingController
MealTextInputController o-- TextEditingController
MealTextInputController : +FormKey GlobalKey~FormState~
MealTextInputController o-- GlobalKey~FormState~
MealTextInputController : +dispose() void
MealTextInputController : +manualInputMeal() dynamic
GetxController <|-- MealTextInputController

class SentimentResult
SentimentResult : +label String
SentimentResult : +score double
SentimentResult : +rawText String

class SentimentAnalysis
SentimentAnalysis : +modelUrl$ String
SentimentAnalysis : +analyse() dynamic

class UserController
UserController : +user Rx~UserModel~
UserController o-- Rx~UserModel~
UserController : +userRepository UserRepository
UserController o-- UserRepository
UserController : -_auth FirebaseAuth
UserController o-- FirebaseAuth
UserController : +instance$ UserController
UserController o-- UserController
UserController : +onInit() void
UserController : +fetchUserRecord() dynamic
UserController : +saveUserRecord() dynamic
UserController : +signOut() dynamic
GetxController <|-- UserController

class UserModel
UserModel : +id String
UserModel : +username String
UserModel : +email String
UserModel : +height double?
UserModel : +weight double?
UserModel : +age int?
UserModel : +activityLevel String?
UserModel : +hasCompletedOnboarding bool
UserModel : +empty()$ UserModel
UserModel : +toJson() Map<String, dynamic>

class UserProfileController
UserProfileController : -_db FirebaseFirestore
UserProfileController o-- FirebaseFirestore
UserProfileController : -_auth FirebaseAuth
UserProfileController o-- FirebaseAuth
UserProfileController : +cachedData Map~String, dynamic~?
UserProfileController : +weightHistory RxList~Map~String, dynamic~~
UserProfileController o-- RxList~Map~String, dynamic~~
UserProfileController : +userController UserController
UserProfileController o-- UserController
UserProfileController : +instance$ UserProfileController
UserProfileController o-- UserProfileController
UserProfileController : +user User?
UserProfileController o-- User
UserProfileController : +saveChanges() dynamic
UserProfileController : +saveOnboardingDetails() dynamic
UserProfileController : +updateActivityLevel() dynamic
UserProfileController : +updatePhysicalMetrics() dynamic
UserProfileController : +getUserDetails() dynamic
UserProfileController : +fetchWeightHistory() dynamic
UserProfileController : -_rebuildWeightHistoryList() void
UserProfileController : +resetPreferences() dynamic
UserProfileController : +clearCache() void
UserProfileController : +deleteAccount() dynamic
GetxController <|-- UserProfileController

class UserRepository
UserRepository : -_db FirebaseFirestore
UserRepository o-- FirebaseFirestore
UserRepository : -_auth FirebaseAuth
UserRepository o-- FirebaseAuth
UserRepository : +instance$ UserRepository
UserRepository o-- UserRepository
UserRepository : +saveUserRecord() dynamic
UserRepository : +fetchUserDetails() dynamic
UserRepository : +updateSingleField() dynamic
UserRepository : +deleteUser() dynamic
GetxController <|-- UserRepository

class DefaultFirebaseOptions
DefaultFirebaseOptions : +web$ FirebaseOptions
DefaultFirebaseOptions o-- FirebaseOptions
DefaultFirebaseOptions : +android$ FirebaseOptions
DefaultFirebaseOptions o-- FirebaseOptions
DefaultFirebaseOptions : +ios$ FirebaseOptions
DefaultFirebaseOptions o-- FirebaseOptions
DefaultFirebaseOptions : +currentPlatform$ FirebaseOptions
DefaultFirebaseOptions o-- FirebaseOptions

class ActivityLevel
ActivityLevel : +createState() State<ActivityLevel>
StatefulWidget <|-- ActivityLevel

class _ActivityLevelState
_ActivityLevelState : +build() Widget
_ActivityLevelState : -_getActivityIcon() IconData
State <|-- _ActivityLevelState

class CameraScreen
CameraScreen : +camera CameraDescription
CameraScreen o-- CameraDescription
CameraScreen : +createState() State<CameraScreen>
StatefulWidget <|-- CameraScreen

class _CameraScreenState
_CameraScreenState : +controller CameraScreenController
_CameraScreenState o-- CameraScreenController
_CameraScreenState : +imageAnalysisController ImageAnalysisController
_CameraScreenState o-- ImageAnalysisController
_CameraScreenState : +initState() void
_CameraScreenState : +dispose() void
_CameraScreenState : +build() Widget
State <|-- _CameraScreenState

class FoodAnalysisResults
FoodAnalysisResults : +createState() State<FoodAnalysisResults>
StatefulWidget <|-- FoodAnalysisResults

class _FoodAnalysisResultsState
_FoodAnalysisResultsState : +categoryController TextEditingController
_FoodAnalysisResultsState o-- TextEditingController
_FoodAnalysisResultsState : +ingredientsController TextEditingController
_FoodAnalysisResultsState o-- TextEditingController
_FoodAnalysisResultsState : +addCustomCategory() void
_FoodAnalysisResultsState : +addCustomIngredient() void
_FoodAnalysisResultsState : +build() Widget
State <|-- _FoodAnalysisResultsState

class ForgotPasswordSheet
ForgotPasswordSheet : +email String
ForgotPasswordSheet : +build() Widget
StatelessWidget <|-- ForgotPasswordSheet

class Home
Home : +isSameDay()$ bool
Home : +greetingForTime()$ String
Home : +macroRank()$ int
Home : +aggregateMacro()$ String
Home : +build() Widget
StatelessWidget <|-- Home

class MacroPill
MacroPill : +label String
MacroPill : +value String
MacroPill : +icon IconData
MacroPill o-- IconData
MacroPill : +accent Color
MacroPill o-- Color
MacroPill : +dark bool
MacroPill : +build() Widget
StatelessWidget <|-- MacroPill

class ImageAnalysis
ImageAnalysis : +build() Widget
StatelessWidget <|-- ImageAnalysis

class IndividualMeal
IndividualMeal : +mealId String
IndividualMeal : +imageUrl String?
IndividualMeal : +createState() State<IndividualMeal>
StatefulWidget <|-- IndividualMeal

class _IndividualMealState
_IndividualMealState : +build() Widget
State <|-- _IndividualMealState

class LoginScreen
LoginScreen : +build() Widget
StatelessWidget <|-- LoginScreen

class MealHistory
MealHistory : +build() Widget
StatelessWidget <|-- MealHistory

class MealHistoryPage
MealHistoryPage : +build() Widget
StatelessWidget <|-- MealHistoryPage

class MealRecommendation
MealRecommendation : +createState() State<MealRecommendation>
StatefulWidget <|-- MealRecommendation

class _MealRecommendationState
_MealRecommendationState : +mealType List~String~
_MealRecommendationState : +cuisine List~DropdownMenuEntry~String~~
_MealRecommendationState : +todayMeals dynamic
_MealRecommendationState : +initState() void
_MealRecommendationState : +build() Widget
State <|-- _MealRecommendationState

class MealRecommendationHistory
MealRecommendationHistory : +createState() State<MealRecommendationHistory>
StatefulWidget <|-- MealRecommendationHistory

class _MealRecommendationHistoryState
_MealRecommendationHistoryState : +build() Widget
State <|-- _MealRecommendationHistoryState

class MealRecommendationResults
MealRecommendationResults : +createState() State<MealRecommendationResults>
StatefulWidget <|-- MealRecommendationResults

class _MealRecommendationResultsState
_MealRecommendationResultsState : +build() Widget
State <|-- _MealRecommendationResultsState

class OnboardingScreen
OnboardingScreen : +createState() State<OnboardingScreen>
StatefulWidget <|-- OnboardingScreen

class _OnboardingScreenState
_OnboardingScreenState : +build() Widget
_OnboardingScreenState : -_getActivityIcon() IconData
State <|-- _OnboardingScreenState

class PhysicalMetrics
PhysicalMetrics : +createState() State<PhysicalMetrics>
StatefulWidget <|-- PhysicalMetrics

class _PhysicalMetricsState
_PhysicalMetricsState : +userProfileController UserProfileController
_PhysicalMetricsState o-- UserProfileController
_PhysicalMetricsState : +heightController TextEditingController
_PhysicalMetricsState o-- TextEditingController
_PhysicalMetricsState : +weightController TextEditingController
_PhysicalMetricsState o-- TextEditingController
_PhysicalMetricsState : +ageController TextEditingController
_PhysicalMetricsState o-- TextEditingController
_PhysicalMetricsState : +initState() void
_PhysicalMetricsState : +dispose() void
_PhysicalMetricsState : +loadUserData() dynamic
_PhysicalMetricsState : +build() Widget
State <|-- _PhysicalMetricsState

class ProfileSettings
ProfileSettings : +createState() State<ProfileSettings>
StatefulWidget <|-- ProfileSettings

class _ProfileSettingsState
_ProfileSettingsState : +userProfileController UserProfileController
_ProfileSettingsState o-- UserProfileController
_ProfileSettingsState : +forgotPasswordController ForgotPasswordController
_ProfileSettingsState o-- ForgotPasswordController
_ProfileSettingsState : +selectedDietaryPreferences List~String~
_ProfileSettingsState : +selectedHealthGoals List~String~
_ProfileSettingsState : +selectedRestrictions List~String~
_ProfileSettingsState : +selectedNutritionalFocus List~String~
_ProfileSettingsState : -_isDietaryPreferencesExpanded bool
_ProfileSettingsState : -_isHealthGoalsExpanded bool
_ProfileSettingsState : -_isNutritionalFocusExpanded bool
_ProfileSettingsState : -_isDietaryRestrictionsExpanded bool
_ProfileSettingsState : +usernameController TextEditingController
_ProfileSettingsState o-- TextEditingController
_ProfileSettingsState : +preferencesController TextEditingController
_ProfileSettingsState o-- TextEditingController
_ProfileSettingsState : +healthGoalsController TextEditingController
_ProfileSettingsState o-- TextEditingController
_ProfileSettingsState : +restrictionController TextEditingController
_ProfileSettingsState o-- TextEditingController
_ProfileSettingsState : +nutritionalFocusController TextEditingController
_ProfileSettingsState o-- TextEditingController
_ProfileSettingsState : +dietaryPreferences List~String~
_ProfileSettingsState : +healthGoals List~String~
_ProfileSettingsState : +nutritionalFocus List~String~
_ProfileSettingsState : +dietaryRestrictions List~String~
_ProfileSettingsState : +initState() void
_ProfileSettingsState : +dispose() void
_ProfileSettingsState : +loadUserData() dynamic
_ProfileSettingsState : +addCustomDietaryPreferences() void
_ProfileSettingsState : +addCustomHealthGoals() void
_ProfileSettingsState : +addCustomRestriction() void
_ProfileSettingsState : +addCustomNutritionalFocus() void
_ProfileSettingsState : +build() Widget
State <|-- _ProfileSettingsState

class SignUpScreen
SignUpScreen : +build() Widget
StatelessWidget <|-- SignUpScreen

class TextInput
TextInput : +build() Widget
StatelessWidget <|-- TextInput

class UserProfile
UserProfile : +createState() State<UserProfile>
StatefulWidget <|-- UserProfile

class _UserProfileState
_UserProfileState : +controller UserProfileController
_UserProfileState o-- UserProfileController
_UserProfileState : +email String
_UserProfileState : +id String
_UserProfileState : +username String
_UserProfileState : +initState() void
_UserProfileState : +loadUserData() void
_UserProfileState : +build() Widget
_UserProfileState : -_buildShimmerLoader() Widget
State <|-- _UserProfileState

class WeightHistoryChart
WeightHistoryChart : +showUpdateButton bool
WeightHistoryChart : +createState() State<WeightHistoryChart>
StatefulWidget <|-- WeightHistoryChart

class _WeightHistoryChartState
_WeightHistoryChartState : +entries List~Map~String, dynamic~~
_WeightHistoryChartState : +initState() void
_WeightHistoryChartState : +build() Widget
State <|-- _WeightHistoryChartState

class GeminiController
GeminiController : +validationJsonSchema$ Schema
GeminiController o-- Schema
GeminiController : +analysisJsonSchema$ Schema
GeminiController o-- Schema
GeminiController : +recommendationJsonSchema_PreviousMeals$ Schema
GeminiController o-- Schema
GeminiController : +recommendationJsonSchema_NoPreviousMeals$ Schema
GeminiController o-- Schema
GeminiController : +summaryJsonSchema$ Schema
GeminiController o-- Schema
GeminiController : +analysisModel GenerativeModel
GeminiController o-- GenerativeModel
GeminiController : +validationModel GenerativeModel
GeminiController o-- GenerativeModel
GeminiController : +recommendationModel_PreviousMeals GenerativeModel
GeminiController o-- GenerativeModel
GeminiController : +recommendationModel_NoPreviousMeals GenerativeModel
GeminiController o-- GenerativeModel
GeminiController : +summaryModel GenerativeModel
GeminiController o-- GenerativeModel

class NetworkManager
NetworkManager : -_connectivity Connectivity
NetworkManager o-- Connectivity
NetworkManager : -_connectivitySubscription StreamSubscription~ConnectivityResult~
NetworkManager o-- StreamSubscription~ConnectivityResult~
NetworkManager : +instance$ NetworkManager
NetworkManager o-- NetworkManager
NetworkManager : +isConnected() dynamic
GetxController <|-- NetworkManager

class AppColors
AppColors : +celadon50$ Color
AppColors o-- Color
AppColors : +celadon100$ Color
AppColors o-- Color
AppColors : +celadon200$ Color
AppColors o-- Color
AppColors : +celadon300$ Color
AppColors o-- Color
AppColors : +celadon400$ Color
AppColors o-- Color
AppColors : +celadon500$ Color
AppColors o-- Color
AppColors : +celadon600$ Color
AppColors o-- Color
AppColors : +celadon700$ Color
AppColors o-- Color
AppColors : +celadon800$ Color
AppColors o-- Color
AppColors : +celadon900$ Color
AppColors o-- Color
AppColors : +celadon950$ Color
AppColors o-- Color
AppColors : +apricotCream50$ Color
AppColors o-- Color
AppColors : +apricotCream100$ Color
AppColors o-- Color
AppColors : +apricotCream200$ Color
AppColors o-- Color
AppColors : +apricotCream300$ Color
AppColors o-- Color
AppColors : +apricotCream400$ Color
AppColors o-- Color
AppColors : +apricotCream500$ Color
AppColors o-- Color
AppColors : +apricotCream600$ Color
AppColors o-- Color
AppColors : +apricotCream700$ Color
AppColors o-- Color
AppColors : +apricotCream800$ Color
AppColors o-- Color
AppColors : +apricotCream900$ Color
AppColors o-- Color
AppColors : +apricotCream950$ Color
AppColors o-- Color
AppColors : +primary$ Color
AppColors o-- Color
AppColors : +secondary$ Color
AppColors o-- Color
AppColors : +accent$ Color
AppColors o-- Color
AppColors : +textPrimary$ Color
AppColors o-- Color
AppColors : +textSecondary$ Color
AppColors o-- Color
AppColors : +textWhite$ Color
AppColors o-- Color
AppColors : +lightBackground$ Color
AppColors o-- Color
AppColors : +darkBackground$ Color
AppColors o-- Color
AppColors : +primaryBackground$ Color
AppColors o-- Color
AppColors : +lightContainer$ Color
AppColors o-- Color
AppColors : +darkContainer$ Color
AppColors o-- Color
AppColors : +primaryButton$ Color
AppColors o-- Color
AppColors : +secondaryButton$ Color
AppColors o-- Color
AppColors : +disabledButton$ Color
AppColors o-- Color
AppColors : +primaryBorder$ Color
AppColors o-- Color
AppColors : +secondaryBorder$ Color
AppColors o-- Color
AppColors : +error$ Color
AppColors o-- Color
AppColors : +success$ Color
AppColors o-- Color
AppColors : +black$ Color
AppColors o-- Color
AppColors : +darkerGrey$ Color
AppColors o-- Color
AppColors : +darkGrey$ Color
AppColors o-- Color
AppColors : +grey$ Color
AppColors o-- Color
AppColors : +softGrey$ Color
AppColors o-- Color
AppColors : +lightGrey$ Color
AppColors o-- Color
AppColors : +white$ Color
AppColors o-- Color

class AppImages
AppImages : +darkAppLogo$ String
AppImages : +lightAppLogo$ String
AppImages : +googleLogo$ String

class AppSizes
AppSizes : +xs$ double
AppSizes : +sm$ double
AppSizes : +md$ double
AppSizes : +lg$ double
AppSizes : +xl$ double
AppSizes : +iconXs$ double
AppSizes : +iconSm$ double
AppSizes : +iconMd$ double
AppSizes : +iconLg$ double
AppSizes : +fontSizeSm$ double
AppSizes : +fontSizeMd$ double
AppSizes : +fontSizeLg$ double
AppSizes : +appBarHeight$ double
AppSizes : +defaultSpace$ double
AppSizes : +spaceBtwItems$ double
AppSizes : +spaceBtwSections$ double
AppSizes : +borderRadiusSm$ double
AppSizes : +borderRadiusMd$ double
AppSizes : +borderRadiusLg$ double
AppSizes : +inputFieldRadius$ double
AppSizes : +spaceBtwInputFields$ double
AppSizes : +cardRadiusLg$ double
AppSizes : +cardRadiusMd$ double
AppSizes : +cardRadiusSm$ double
AppSizes : +cardRadiusXs$ double
AppSizes : +cardElevation$ double
AppSizes : +buttonTextSize$ double

class AppDeviceUtils
AppDeviceUtils : +getBottomNavigationBarHeight()$ double

class AppHelperFunctions
AppHelperFunctions : +isDarkMode()$ bool
AppHelperFunctions : +isAndroid13OrAbove()$ dynamic

class AppLoaders
AppLoaders : +showSnackBar()$ void

class AppAppBarTheme
AppAppBarTheme : +lightAppBarTheme$ AppBarTheme
AppAppBarTheme o-- AppBarTheme
AppAppBarTheme : +darkAppBarTheme$ AppBarTheme
AppAppBarTheme o-- AppBarTheme

class AppBottomSheetTheme
AppBottomSheetTheme : +lightBottomSheetTheme$ BottomSheetThemeData
AppBottomSheetTheme o-- BottomSheetThemeData
AppBottomSheetTheme : +darkBottomSheetTheme$ BottomSheetThemeData
AppBottomSheetTheme o-- BottomSheetThemeData

class AppCheckboxTheme
AppCheckboxTheme : +lightCheckboxTheme$ CheckboxThemeData
AppCheckboxTheme o-- CheckboxThemeData
AppCheckboxTheme : +darkCheckboxTheme$ CheckboxThemeData
AppCheckboxTheme o-- CheckboxThemeData

class AppChipTheme
AppChipTheme : +lightChipTheme$ ChipThemeData
AppChipTheme o-- ChipThemeData
AppChipTheme : +darkChipTheme$ ChipThemeData
AppChipTheme o-- ChipThemeData

class AppElevatedButtonTheme
AppElevatedButtonTheme : +lightElevatedButtonTheme$ ElevatedButtonThemeData
AppElevatedButtonTheme o-- ElevatedButtonThemeData
AppElevatedButtonTheme : +darkElevatedButtonTheme$ ElevatedButtonThemeData
AppElevatedButtonTheme o-- ElevatedButtonThemeData

class AppNavBarTheme
AppNavBarTheme : +lightNavBarTheme$ NavigationBarThemeData
AppNavBarTheme o-- NavigationBarThemeData
AppNavBarTheme : +darkNavBarTheme$ NavigationBarThemeData
AppNavBarTheme o-- NavigationBarThemeData

class AppOutlinedButtonTheme
AppOutlinedButtonTheme : +lightOutlinedButtonTheme$ OutlinedButtonThemeData
AppOutlinedButtonTheme o-- OutlinedButtonThemeData
AppOutlinedButtonTheme : +darkOutlinedButtonTheme$ OutlinedButtonThemeData
AppOutlinedButtonTheme o-- OutlinedButtonThemeData

class AppProgressIndicatorTheme
AppProgressIndicatorTheme : +lightProgressIndicatorTheme$ ProgressIndicatorThemeData
AppProgressIndicatorTheme o-- ProgressIndicatorThemeData
AppProgressIndicatorTheme : +darkProgressIndicatorTheme$ ProgressIndicatorThemeData
AppProgressIndicatorTheme o-- ProgressIndicatorThemeData

class AppTextFieldName
AppTextFieldName : +lightInputDecorationTheme$ InputDecorationTheme
AppTextFieldName o-- InputDecorationTheme
AppTextFieldName : +darkInputDecorationTheme$ InputDecorationTheme
AppTextFieldName o-- InputDecorationTheme

class AppTextTheme
AppTextTheme : +lightTextTheme$ TextTheme
AppTextTheme o-- TextTheme
AppTextTheme : +darkTextTheme$ TextTheme
AppTextTheme o-- TextTheme

class AppTheme
AppTheme : +lightMode$ ThemeData
AppTheme o-- ThemeData
AppTheme : +darkMode$ ThemeData
AppTheme o-- ThemeData

class AppValidator
AppValidator : +validateEmptyText()$ String?
AppValidator : +validateUsername()$ String?
AppValidator : +validateEmail()$ String?
AppValidator : +validateSignUpPassword()$ String?
AppValidator : +validateSignInPassword()$ String?
AppValidator : +validateWeight()$ String?
AppValidator : +validateHeight()$ String?
AppValidator : +validateAge()$ String?
